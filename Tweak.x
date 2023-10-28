@import UIKit;
#import "Headers.h"

// Prefs handling
static BOOL tweakEnabled = false;
static CGFloat borderWidth = 0;
static int backgroundType = 0;

// Update prefs in order to apply changes without a respring
static void loadWithoutRespring() {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.folderartworkremadeprefs"];

	tweakEnabled = [prefs objectForKey:@"tweakEnabled"] ? [prefs boolForKey:@"tweakEnabled"] : true;
	borderWidth = [prefs objectForKey:@"borderWidth"] ? [prefs floatForKey:@"borderWidth"] : 0;
	backgroundType = [prefs objectForKey:@"backgroundType"] ? [prefs integerForKey:@"backgroundType"] : 0;
}

%hook SBFolderBackgroundView
// Add custom property `fa_imageView` for the background image
%property (nonatomic, strong) UIImageView *fa_imageView;

- (void)didMoveToWindow {
	%orig;

	loadWithoutRespring();

	MTMaterialView *_blurView = [self safeValueForKey:@"_blurView"];

	// Initially set up the design
	if (tweakEnabled) {
		_blurView.layer.borderWidth = borderWidth;
		_blurView.layer.borderColor = [colorForKey(@"borderColor", @"00000000") CGColor];
		_blurView.layer.masksToBounds = true;
		_blurView.backgroundColor = colorForKey(@"backgroundColor", @"00000000");
	} else {
		_blurView.layer.borderWidth = 0;
		_blurView.layer.borderColor = [[UIColor clearColor] CGColor];
		_blurView.layer.masksToBounds = false;
		_blurView.backgroundColor = [UIColor clearColor];
	}

	// Don't re-add the `imageView` subview if it was previously added
	if ([_blurView.subviews containsObject:self.fa_imageView]) return;

	self.fa_imageView = [UIImageView new];
	self.fa_imageView.image = imageForKey(@"backgroundImage");
	self.fa_imageView.clipsToBounds = true;
	self.fa_imageView.layer.masksToBounds = true;
	self.fa_imageView.translatesAutoresizingMaskIntoConstraints = false;
	self.fa_imageView.hidden = backgroundType == 0 || !tweakEnabled ? true : false;
	[_blurView addSubview:self.fa_imageView];

	[NSLayoutConstraint activateConstraints:@[
		[self.fa_imageView.widthAnchor constraintEqualToAnchor:_blurView.widthAnchor],
		[self.fa_imageView.heightAnchor constraintEqualToAnchor:_blurView.heightAnchor],
		[self.fa_imageView.centerXAnchor constraintEqualToAnchor:_blurView.centerXAnchor],
		[self.fa_imageView.centerYAnchor constraintEqualToAnchor:_blurView.centerYAnchor]
	]];

	// Add self as an observer for when prefs are changed
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(far_tweakEnabledStateWasChanged) name:@"far_tweakEnabledStateWasChanged" object:nil];
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(far_borderColorWasUpdated) name:@"far_borderColorWasUpdated" object:nil];
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(far_borderWidthWasUpdated) name:@"far_borderWidthWasUpdated" object:nil];

	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(far_backgroundTypeWasUpdated) name:@"far_backgroundTypeWasUpdated" object:nil];
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(far_backgroundColorWasUpdated) name:@"far_backgroundColorWasUpdated" object:nil];
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(far_backgroundImageWasUpdated) name:@"far_backgroundImageWasUpdated" object:nil];
}

%new
- (void)far_borderColorWasUpdated {
	loadWithoutRespring();

	// Update the border color
	MTMaterialView *_blurView = [self safeValueForKey:@"_blurView"];
	_blurView.layer.borderColor = tweakEnabled ? [colorForKey(@"borderColor", @"00000000") CGColor] : [[UIColor clearColor] CGColor];
}

%new
- (void)far_borderWidthWasUpdated {
	loadWithoutRespring();

	// Update the border width
	MTMaterialView *_blurView = [self safeValueForKey:@"_blurView"];
	_blurView.layer.borderWidth = tweakEnabled ? borderWidth : 0;
}

%new
- (void)far_backgroundTypeWasUpdated {
	loadWithoutRespring();

	MTMaterialView *_blurView = [self safeValueForKey:@"_blurView"];

	// Reset look to original if the tweak is disabled
	if (!tweakEnabled) {
		_blurView.backgroundColor = [UIColor clearColor];
		self.fa_imageView.hidden = true;
	}

	// Handling of the background image
	if (backgroundType == 0) {
		// If the background type is "Background Color"
		_blurView.backgroundColor = colorForKey(@"backgroundColor", @"00000000");
		self.fa_imageView.hidden = true;
	} else {
		// If the background type is "Background Image"
		self.fa_imageView.hidden = false;
		self.fa_imageView.image = imageForKey(@"backgroundImage");
	}
}

%new
- (void)far_backgroundColorWasUpdated {
	loadWithoutRespring();

	// Handle a change in the background color
	if (backgroundType == 0) {
		MTMaterialView *_blurView = [self safeValueForKey:@"_blurView"];
		_blurView.backgroundColor = tweakEnabled ? colorForKey(@"backgroundColor", @"00000000") : [UIColor clearColor];
	}
}

%new
- (void)far_backgroundImageWasUpdated {
	loadWithoutRespring();

	// Handle a change in the background image by the user
	if (backgroundType == 0) {
		self.fa_imageView.image = tweakEnabled ? imageForKey(@"backgroundImage") : nil;
	}
}

%end

%ctor {
	loadWithoutRespring();
}