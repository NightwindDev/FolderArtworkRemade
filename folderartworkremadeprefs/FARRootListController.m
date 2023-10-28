@import Foundation;
#import <rootless.h>
#import "FARRootListController.h"

/*
 * Reference: https://github.com/LacertosusRepo/Preference-Cell-Examples/tree/449774e8f6c3d5eaf899a484e884ec16066cd1f1/Dynamic%20Specifiers
 * This controller has an implementation for dynamic specifiers taken from Lacertosus's examples.
 */

#define kTintColor [UIColor colorWithRed:255.0/255.0 green:98.0/255.0 blue:0.0/255.0 alpha:1.0]

// Declare function at top and then implement it at the bottom for cleaner a file
static void performResetPrefsWithController(PSListController *controller);

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
@end

@implementation FARRootListController {
	NSDictionary *_notificationNames;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

		// Declare all notification names
		_notificationNames = @{
			@"tweakEnabled": @"far_tweakEnabledStateWasChanged",
			@"borderWidth": @"far_borderWidthWasUpdated",
			@"borderColor": @"far_borderColorWasUpdated",
			@"backgroundType": @"far_backgroundTypeWasUpdated",
			@"backgroundColor": @"far_backgroundColorWasUpdated",
			@"backgroundImage": @"far_backgroundImageWasUpdated",
		};

		NSArray *chosenIDs = @[
			@"backgroundColor",
			@"backgroundImage"
		];

		self.savedSpecifiers = (self.savedSpecifiers) ?: @{}.mutableCopy;

		for (PSSpecifier *specifier in [self specifiersForIDs:chosenIDs]) {
			[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
		}
	}

	return _specifiers;
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.folderartworkremadeprefs"];
	[prefs setValue:value forKey:specifier.properties[@"key"]];

	[NSDistributedNotificationCenter.defaultCenter postNotificationName:_notificationNames[specifier.identifier] object:nil];

	[super setPreferenceValue:value specifier:specifier];

	[self updateSpecifierVisibility:true];
}

-(void)updateSpecifierVisibility:(BOOL)animated {
	PSSpecifier *backgroundTypeSpecifier = [self specifierForID:@"backgroundType"];
	int backgroundType = [[self readPreferenceValue:backgroundTypeSpecifier] intValue];

	[self removeSpecifier:self.savedSpecifiers[@"backgroundImage"] animated:animated];
	[self removeSpecifier:self.savedSpecifiers[@"backgroundColor"] animated:animated];

	if (backgroundType == 0) {
		[self insertSpecifier:self.savedSpecifiers[@"backgroundColor"] afterSpecifierID:@"backgroundType" animated:animated];
		[self removeSpecifier:self.savedSpecifiers[@"backgroundImage"] animated:animated];
	} else if (backgroundType == 1 && ![self containsSpecifier:self.savedSpecifiers[@"backgroundImage"]]) {
		[self insertSpecifier:self.savedSpecifiers[@"backgroundImage"] afterSpecifierID:@"backgroundType" animated:animated];
		[self removeSpecifier:self.savedSpecifiers[@"backgroundColor"] animated:animated];
	}
}

-(void)reloadSpecifiers {
	[super reloadSpecifiers];

	[self updateSpecifierVisibility:false];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self reloadSpecifiers];
	[self updateSpecifierVisibility:false];

	[self initTopMenu];
}

- (void)open:(PSSpecifier *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[sender propertyForKey:@"url"]] options:@{} completionHandler:nil];
}

- (void)initTopMenu {
	UIButton *topMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	topMenuButton.frame = CGRectMake(0,0,26,26);
	[topMenuButton setImage:[[UIImage systemImageNamed:@"gearshape.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	topMenuButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	topMenuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	topMenuButton.tintColor = kTintColor;

	UIAction *resetPrefs = [UIAction actionWithTitle:@"Reset Preferences"
										       image:[UIImage systemImageNamed:@"arrow.triangle.2.circlepath.circle.fill"]
										  identifier:nil
										     handler:^(UIAction *action) {
		performResetPrefsWithController(self);
	}];

	resetPrefs.attributes = UIMenuElementAttributesDestructive;

	NSArray *items = @[resetPrefs];

	topMenuButton.menu = [UIMenu menuWithTitle:@"" children: items];
	topMenuButton.showsMenuAsPrimaryAction = true;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:topMenuButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Set navbar text tint color to `kTintColor` when the controller is opened
	self.navigationController.navigationBar.tintColor = kTintColor;
	self.navigationController.navigationController.navigationBar.tintColor = kTintColor;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Reset the original navbar text tint color when the controller is closed
	self.navigationController.navigationBar.tintColor = UIColor.systemBlueColor;
	self.navigationController.navigationController.navigationBar.tintColor = UIColor.systemBlueColor;
}

@end

void performResetPrefsWithController(PSListController *controller) {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Preferences?" message:@"This cannot be undone" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:cancelAction];

	[alert addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		// Reset prefs
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.nightwind.folderartworkremadeprefs"];
		NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.folderartworkremadeprefs"];

		// Reset the selected images from LibGcUniversal
		NSArray *const images = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.nightwind.folderartworkremadeprefs")] includingPropertiesForKeys:@[] options:0 error:nil];

		for (NSURL *url in images) {
			NSError *error = nil;
			[[NSFileManager defaultManager] removeItemAtPath:[[url absoluteString] stringByReplacingOccurrencesOfString:@"file://"  withString:@""] error:&error];
		}

		// Re-enable the tweak after the reset
		[userDefaults setObject:@true forKey:@"tweakEnabled"];
		[userDefaults synchronize];

		// Refresh the cells after resetting the prefs
		[controller reloadSpecifiers];
	}]];

	[controller presentViewController:alert animated:true completion:nil];
}