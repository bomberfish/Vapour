#include "SkyLight.h"
#include "TweakOptions.h"
#import "common.h"
#include <AppKit/NSWindow.h>
#include <AppKit/AppKit.h>
#include <sys/types.h>
#include <stdint.h>

static BOOL VapourIsForbiddenWindowLevel(NSWindowLevel level) {
    NSWindowLevel levels[] = {
        kCGTornOffMenuWindowLevel,
        kCGScreenSaverWindowLevel,
        kCGModalPanelWindowLevel,
        kCGDesktopIconWindowLevel,
        kCGMinimumWindowLevel,
        kCGStatusWindowLevel,
        kCGDockWindowLevel,
        kCGFloatingWindowLevel,
        NSTornOffMenuWindowLevel,
        NSScreenSaverWindowLevel,
        NSModalPanelWindowLevel,
        NSStatusWindowLevel,
        NSFloatingWindowLevel,
        NSMainMenuWindowLevel,
    };
    size_t cnt = sizeof(levels)/sizeof(levels[0]);
    for (size_t i = 0; i < cnt; ++i) {
        if (levels[i] == level) return YES;
    }
    return NO;
}

ZKSwizzleInterface(WindowOverride, NSWindow, NSObject);

void OnWindowOpened(NSWindow *window) {
    if ([[TweakOptions sharedInstance] VapourEnabled]) {
        CGFloat opacity = [[TweakOptions sharedInstance] VapourOpacity];
        VPLog (@"Window %d opened with level %d and style mask %lu", (int)[window windowNumber], (int)[window level], (unsigned long)[window styleMask]);

        VPLog(@"Setting window opacity to %f", opacity);
        [window setAlphaValue:opacity];

        VPLog(@"executable's at %@", [[NSBundle mainBundle] executablePath]);

        // the code formatting of doom and despair 
        if (
                [[TweakOptions sharedInstance] VapourOverrideColours] 
                && 
                (
                    [window backgroundColor] == nil ||
                    [[window backgroundColor] alphaComponent] == 1.0
                )
                && ([window respondsToSelector:@selector(level)] ? !VapourIsForbiddenWindowLevel([window level]) : YES)
            ) {
            VPLog(@"Overriding window background color on opened window");
            [window setBackgroundColor:[NSColor colorWithRed:0 green:0 blue:0 alpha:0.875]];
        }

        uint32_t rad = [[TweakOptions sharedInstance] VapourBlur];
        if (rad > 0.0) {
            VPLog(@"Applying blur effect to window with radius %d", rad);

            uint32_t cid = CGSMainConnectionID();
            NSInteger wid = [window windowNumber];
            VPLog(@"cid: %d, wid: %f -> %d", cid, (double)wid, (uint32_t)wid);

            CGError error = SLSSetWindowBackgroundBlurRadius(cid, wid, rad);
            if (error != kCGErrorSuccess) {
                VPLog(@"Failed to set window background blur radius: %d", error);
            }
        }
    }
    return;
}

@implementation WindowOverride
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    VPLog(@"NSWindow initWithContentRect:styleMask:backing:defer: called!");
    id result = _orig(id, contentRect, style, backingStoreType, flag);
    dispatch_async(dispatch_get_main_queue(), ^{
        OnWindowOpened(result);
    });
    return result;
}
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag screen:(nullable NSScreen *)screen {
    VPLog(@"NSWindow initWithContentRect:styleMask:backing:defer:screen: called!");
    id result = _orig(id, contentRect, style, backingStoreType, flag, screen);
    dispatch_async(dispatch_get_main_queue(), ^{
        OnWindowOpened(result);
    });
    return result;
}
- (id)initWithCoder:(NSCoder *)coder {
    VPLog(@"NSWindow initWithCoder: called!");
    id result = _orig(id, coder);
    if ([[TweakOptions sharedInstance] VapourEnabled]) {
       [result setAlphaValue: [[TweakOptions sharedInstance] VapourOpacity]];
    }
    return result;
}
- (void)setOpaque:(BOOL)opaque {
    VPLog(@"NSWindow IGNORING setOpaque: %d", opaque);
    if ([[TweakOptions sharedInstance] VapourEnabled]) {
            VPLog(@"Forcing window to be non-opaque");
            _orig(void, NO);
    } else {
            _orig(void, opaque);
    }
    return;
}
- (void)setAlphaValue:(CGFloat)alphaValue {
    if ([[TweakOptions sharedInstance] VapourEnabled]) {
            NSWindow* selfWindow = (NSWindow *)self;
            if (!VapourIsForbiddenWindowLevel([selfWindow level]) &&  [selfWindow styleMask] != NSWindowStyleMaskBorderless) {
            CGFloat opacity = [[TweakOptions sharedInstance] VapourOpacity];
            VPLog(@"Setting window opacity to %f", opacity);
            _orig(void, opacity);
        } else {
            VPLog(@"Not modifying alpha value for window level %d", (int)[selfWindow level]);
            _orig(void, alphaValue);
        }
    } else {
            _orig(void, alphaValue);
    }

    return;
}
@end