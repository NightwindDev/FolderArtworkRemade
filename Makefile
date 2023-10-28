export TARGET := iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk/

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FolderArtworkRemade

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_LIBRARIES = gcuniversal
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += folderartworkremadeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
