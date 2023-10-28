include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FolderArtworkRemadePrefs

FolderArtworkRemadePrefs_FILES = FARRootListController.m $(wildcard Cells/*.m)
FolderArtworkRemadePrefs_FRAMEWORKS = UIKit
FolderArtworkRemadePrefs_PRIVATE_FRAMEWORKS = Preferences
FolderArtworkRemadePrefs_LIBRARIES = gcuniversal
FolderArtworkRemadePrefs_INSTALL_PATH = /Library/PreferenceBundles
FolderArtworkRemadePrefs_CFLAGS  = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"'

include $(THEOS_MAKE_PATH)/bundle.mk
