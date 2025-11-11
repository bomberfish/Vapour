#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <CoreGraphics/CGWindowLevel.h>
#import "TweakOptions.h"
#import "ZKSwizzle.h"

void VPLog(NSString *format, ...) {
    if ([[TweakOptions sharedInstance] VapourDebug]) {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"[Vapour] %@", message);
        va_end(args);
    }
}