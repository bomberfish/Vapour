#include "SkyLight.h"
#include "TweakOptions.h"
#import "common.h"
#include <sys/types.h>
#include <stdint.h>

ZKSwizzleInterface(WindowOverride, NSWindow, NSObject);

void OnWindowOpened(NSWindow *window) {
    if ([[TweakOptions sharedInstance] VapourEnabled]) {
        CGFloat opacity = [[TweakOptions sharedInstance] VapourOpacity];
        VPLog(@"Setting window opacity to %f", opacity);
        [window setAlphaValue:opacity];

        // the code formatting of doom and despair 
        if (
                [[TweakOptions sharedInstance] VapourOverrideColours] 
                && 
                (
                    [window backgroundColor] == nil ||
                    [[window backgroundColor] alphaComponent] == 1.0
                )
                && (
                    [window level] != kCGTornOffMenuWindowLevel &&
                    [window level] != kCGScreenSaverWindowLevel &&
                    [window level] != kCGModalPanelWindowLevel &&
                    [window level] != kCGDesktopIconWindowLevel &&
                    [window level] != kCGMinimumWindowLevel &&
                    [window level] != kCGStatusWindowLevel &&
                    [window level] != kCGDockWindowLevel
                )
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
            CGFloat opacity = [[TweakOptions sharedInstance] VapourOpacity];
            VPLog(@"Setting window opacity to %f", opacity);
            _orig(void, opacity);
    } else {
            _orig(void, alphaValue);
    }

    return;
}
@end