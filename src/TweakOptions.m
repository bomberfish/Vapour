#import "common.h"

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
    } else if ([key isEqualToString:@"VapourBlur"]) {
        CGFloat val = MAX([value floatValue], 0.0);
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
        [self updateOption:@"VapourBlur" withDefault:@0.0];
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