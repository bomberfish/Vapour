#import <Foundation/Foundation.h>
#import "ZKSwizzle.h"

__attribute__((constructor))
static void init_tweak(void) {
    // NSLog(@"[Vapour] Vapour constructor called!\n");
    // NSLog(@"[Vapour] %@",  [[NSBundle mainBundle] bundleIdentifier]);
}

__attribute__((visibility("default")))
void LoadFunction(void *gum_interceptor) {
    // NSLog(@"[Vapour] LoadFunction called with gum interceptor %p\n", gum_interceptor);
}