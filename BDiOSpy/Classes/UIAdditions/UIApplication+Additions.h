//
//  UIApplication+Additions.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//
#import <UIKit/UIKit.h>

#define UIApplicationCurrentRunMode ([[UIApplication sharedApplication] currentRunLoopMode])

NS_ASSUME_NONNULL_BEGIN

CF_EXPORT SInt32 RunLoopRunInModeRelativeToAnimationSpeed(CFStringRef mode, CFTimeInterval seconds, Boolean returnAfterSourceHandled);

@interface UIApplication (Additions)

@property (nonatomic, assign) float animationSpeed;

- (NSArray *)windowsWithKeyWindow;

- (CFStringRef)currentRunLoopMode;

@end

NS_ASSUME_NONNULL_END
