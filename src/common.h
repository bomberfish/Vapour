#pragma once
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <CoreGraphics/CGWindowLevel.h>
#import "SkyLight.h"
#import "TweakOptions.h"
#import "ZKSwizzle.h"

#ifndef VPLog
#define VPLog(format, ...) \
    if ([[TweakOptions sharedInstance] VapourDebug]) { \
        NSLog(@"[Vapour] %@", [NSString stringWithFormat:format, ##__VA_ARGS__]); \
    }

#endif
