@import Preferences;

@interface PSListController (Private)
- (BOOL)containsSpecifier:(PSSpecifier *)specifier;
@end

@interface FARRootListController : PSListController
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
- (void)updateSpecifierVisibility:(BOOL)animated;
@end
