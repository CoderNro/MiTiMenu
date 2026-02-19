TARGET_NAME = MiTiMenu
SOURCES     = MiTiMenu.m
OUTPUT      = $(TARGET_NAME).dylib

SDK         = $(shell xcrun --sdk iphoneos --show-sdk-path)
MIN_IOS     = 14.0

ARCHS       = arm64

CLANG       = $(shell xcrun -f clang)

CFLAGS = \
    -fobjc-arc \
    -fmodules \
    -isysroot $(SDK) \
    -miphoneos-version-min=$(MIN_IOS) \
    $(addprefix -arch ,$(ARCHS)) \
    -O2

LDFLAGS = \
    -dynamiclib \
    -isysroot $(SDK) \
    -miphoneos-version-min=$(MIN_IOS) \
    $(addprefix -arch ,$(ARCHS)) \
    -framework UIKit \
    -framework Foundation \
    -Xlinker -install_name \
    -Xlinker @rpath/$(OUTPUT)

all: $(OUTPUT)

$(OUTPUT): $(SOURCES)
	$(CLANG) $(CFLAGS) $(LDFLAGS) -o $@ $^
	@echo "✅ Build thành công: $@"

clean:
	rm -f $(OUTPUT) *.o
