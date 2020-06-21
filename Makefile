THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WorldEditforiOS

WorldEditforiOS_FILES = Tweak.xm
SYSROOT = $(THEOS)/sdks/iPhoneOS11.2.sdk/
WorldEditforiOS_CFLAGS = -fobjc-arc
WorldEditforiOS_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG

ARCHS = arm64

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/aggregate.mk

after-install::
	install.exec "killall -9 '-'"