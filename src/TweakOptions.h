#import <Foundation/Foundation.h>

@interface TweakOptions: NSObject
@property (nonatomic) BOOL VapourEnabled;
@property (nonatomic) CGFloat VapourOpacity;
@property (nonatomic) BOOL VapourOverrideColours;
@property (nonatomic) BOOL VapourDisableBorder;
@property (nonatomic) BOOL VapourDebug;
+ (instancetype)sharedInstance;
@end