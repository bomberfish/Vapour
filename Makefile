CC = $(shell xcrun --find clang)
SDKROOT = $(shell xcrun --sdk macosx --show-sdk-path)
CFLAGS = -Wall -Wextra -O2 -fmodules -Wno-implicit-int \
			  -arch x86_64 -arch arm64 -arch arm64e \
			  -isysroot $(SDKROOT)  -iframework $(SDKROOT)/System/Library/Frameworks
LDFLAGS = -framework Foundation \
				-framework AppKit \
				-framework Cocoa \
				-framework QuartzCore \
				-framework CoreGraphics \
				-framework CoreFoundation \
				-framework ApplicationServices \
				-framework SkyLight \
    			-F$(SDKROOT)/System/Library/Frameworks \
				-F$(SDKROOT)/System/Library/PrivateFrameworks

all: build/libVapour.dylib

build:
	mkdir -p build

build/%.o: src/%.m | build
	$(CC) $(CFLAGS) -c $< -o $@

SRCS = $(wildcard src/*.m)
OBJS = $(patsubst src/%.m,build/%.o,$(SRCS))

build/libVapour.dylib: $(OBJS)
	$(CC) \
	-dynamiclib -install_name @rpath/$(DYLIB_NAME) -compatibility_version 1.0.0 -current_version 1.0.0 \
	-arch x86_64 -arch arm64 -arch arm64e \
	$(OBJS) -o build/libVapour.dylib $(LDFLAGS) -L$(SDKROOT)/usr/lib

clean:
	rm -rf build

install: all
	rm -f /var/ammonia/core/tweaks/libVapour.dylib
	rm -f /var/ammonia/core/tweaks/libVapour.dylib.blacklist
	cp build/libVapour.dylib /var/ammonia/core/tweaks/libVapour.dylib
	cp libVapour.dylib.blacklist /var/ammonia/core/tweaks/libVapour.dylib.blacklist