#import "common.h"

ZKSwizzleInterface(ColourOverride, NSColor, NSObject);

#define ApplyColor(r,g,b,a) \
if ([[TweakOptions sharedInstance] VapourOverrideColours] && [[TweakOptions sharedInstance] VapourEnabled]) { \
    return [NSColor colorWithRed:r green:g blue:b alpha:a]; \
} else { \
    return _orig(NSColor *); \
}

@implementation ColourOverride
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
