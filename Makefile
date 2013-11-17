GO_EASY_ON_ME=1

include theos/makefiles/common.mk

TWEAK_NAME = Sicarius
Sicarius_FILES = Tweak.xm
Sicarius_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
