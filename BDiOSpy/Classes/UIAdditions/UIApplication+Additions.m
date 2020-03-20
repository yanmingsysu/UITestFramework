//
//  UIApplication+Additions.m
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "UIApplication+Additions.h"
#import <objc/runtime.h>
#import <objc/message.h>

static const void *RunLoopModesKey = &RunLoopModesKey;

SInt32 RunLoopRunInModeRelativeToAnimationSpeed(CFStringRef mode, CFTimeInterval seconds, Boolean returnAfterSourceHandled)
{
    CFTimeInterval scaledSeconds = seconds / [UIApplication sharedApplication].animationSpeed;
    return CFRunLoopRunInMode(mode, scaledSeconds, returnAfterSourceHandled);
}

@implementation UIApplication (Additions)

- (NSArray *)windowsWithKeyWindow {
    NSMutableArray *windows = self.windows.mutableCopy;
    UIWindow *keyWindow = [[self windows] objectAtIndex:0];
    if (keyWindow && ![windows containsObject:keyWindow]) {
        [windows addObject:keyWindow];
    }
    return windows;
}

- (float)animationSpeed
{
    if (!self.keyWindow) {
        return 1.0f;
    }
    return self.keyWindow.layer.speed;
}

#pragma mark - Run loop monitoring

- (CFStringRef)currentRunLoopMode {
    return (__bridge CFStringRef)[self runLoopModes].lastObject;
}

- (NSMutableArray *)runLoopModes;
{
    NSMutableArray *modes = objc_getAssociatedObject(self, RunLoopModesKey);
    if (!modes) {
        modes = [NSMutableArray arrayWithObject:(id)kCFRunLoopDefaultMode];
        objc_setAssociatedObject(self, RunLoopModesKey, modes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return modes;
}

@end
