//
//  UIView+Addtions.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Addtions)

/// tap screen
/// @param point cgpoint on the screen which will be tapped
- (void)tapAtPoint:(CGPoint)point;

- (void)longPressAtPoint:(CGPoint)point duration:(NSTimeInterval)duration;

- (void)twoFingerTapAtPoint:(CGPoint)point;

- (void)dragFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

- (void)dragFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint steps:(NSUInteger)stepCount;

- (void) viewResponseToCmdDict:(NSDictionary *)dict;

- (BOOL)isClickable;

- (BOOL)isVisible;

- (NSDictionary *) getRect;

- (NSString *)getElemText;

@end

NS_ASSUME_NONNULL_END
