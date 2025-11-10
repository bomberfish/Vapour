#import <AppKit/AppKit.h>
#include <CoreGraphics/CGWindowLevel.h>
#import "ZKSwizzle.h"

ZKSwizzleInterface(WindowOverride, NSWindow, NSObject);
ZKSwizzleInterface(ColorOverride, NSColor, NSObject);

@interface TweakOptions: NSObject
@property (nonatomic) BOOL VapourEnabled;
@property (nonatomic) CGFloat VapourOpacity;
@property (nonatomic) BOOL VapourOverrideColours;
@property (nonatomic) BOOL VapourDisableBorder;
@property (nonatomic) BOOL VapourDebug;
+ (instancetype)sharedInstance;
@end

void VPLog(NSString *format, ...) {
    if ([[TweakOptions sharedInstance] VapourDebug]) {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"[Vapour] %@", message);
        va_end(args);
    }
}

@implementation TweakOptions
+ (instancetype)sharedInstance {
    static TweakOptions *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TweakOptions alloc] init];
    });
    return sharedInstance;
}
- (void)updateOption:(NSString *)key withDefault:(id)defaultValue {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSUserDefaults *appDefaults = [[NSUserDefaults alloc] initWithSuiteName:bundleId];
    NSUserDefaults *globalDefaults = [NSUserDefaults standardUserDefaults];
    id value = nil;
    if ([appDefaults objectForKey:key] != nil) {
        value = [appDefaults objectForKey:key];
    } else if ([globalDefaults objectForKey:key] != nil) {
        value = [globalDefaults objectForKey:key];
    } else {
        value = defaultValue;
    }
    if ([key isEqualToString:@"VapourOpacity"]) {
        CGFloat val = MAX([value floatValue], 0.01);
        [self setValue:@(val) forKey:key];
    } else {
        BOOL val = [value boolValue];
        [self setValue:@(val) forKey:key];
    }
}
- (instancetype)init {
    self = [super init];
    if (self) {
        // TODO: load stuff from userdefaults
        [self updateOption:@"VapourEnabled" withDefault:@YES];
        [self updateOption:@"VapourOpacity" withDefault:@0.9];
        [self updateOption:@"VapourOverrideColours" withDefault:@NO];
        [self updateOption:@"VapourDebug" withDefault:@NO];

        // TODO: figure out how to disable *just* the window border and not take the window decorations with it
        [self updateOption:@"VapourDisableBorder" withDefault:@NO]; 

        if (self.VapourDebug) {
            NSLog(@"[Vapour] TweakOptions initialized: VapourEnabled=%d, VapourOpacity=%f, VapourOverrideColours=%d, VapourDisableBorder=%d",
                self.VapourEnabled,
                self.VapourOpacity,
                self.VapourOverrideColours,
                self.VapourDisableBorder);
        }
    }
    return self;
}
@end

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

#define ApplyColor(r,g,b,a) \
if ([[TweakOptions sharedInstance] VapourOverrideColours] && [[TweakOptions sharedInstance] VapourEnabled]) { \
    VPLog(@"Overriding color"); \
    return [NSColor colorWithRed:r green:g blue:b alpha:a]; \
} else { \
    return _orig(NSColor *); \
}

@implementation ColorOverride
+ (NSColor *)windowBackgroundColor {
    ApplyColor(0,0,0,0.9)
}
+ (NSColor *)labelColor {
    ApplyColor(1,1,1,1.0)
}
+ (NSColor *)underPageBackgroundColor {
    ApplyColor(0,0,0,0.8)
}
+ (NSColor *)controlBackgroundColor {
    ApplyColor(0,0,0,0.7)
}
+ (NSColor *)systemFillColor {
    ApplyColor(0.4,0.4,0.4,0.2)
}
+(NSColor *)secondarySystemFillColor {
    ApplyColor(0.5,0.5,0.5,0.225)
}
+ (NSColor *)tertiarySystemFillColor {
    ApplyColor(0.55,0.55,0.55,0.275)
}
+ (NSColor *)quaternarySystemFillColor {
    ApplyColor(0.65,0.65,0.65,0.3)
}
@end
