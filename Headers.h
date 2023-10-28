@import GcUniversal;

@interface NSObject (Private)
- (id)safeValueForKey:(NSString *)key;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (instancetype)defaultCenter;
@end

@interface MTMaterialView : UIView
@end

@interface SBFolderBackgroundView : UIView
@property (nonatomic, strong) UIImageView *fa_imageView; // @new
- (void)far_borderColorWasUpdated;		 // @new
- (void)far_borderWidthWasUpdated;		 // @new
- (void)far_backgroundTypeWasUpdated;	 // @new
- (void)far_backgroundColorWasUpdated;	 // @new
- (void)far_backgroundImageWasUpdated;	 // @new
@end

static inline UIColor *colorForKey(NSString *key, NSString *fallback) {
	return [GcColorPickerUtils colorFromDefaults:@"com.nightwind.folderartworkremadeprefs" withKey:key fallback:fallback];
}

static inline UIImage *imageForKey(NSString *key) {
	return [GcImagePickerUtils imageFromDefaults:@"com.nightwind.folderartworkremadeprefs" withKey:key];
}