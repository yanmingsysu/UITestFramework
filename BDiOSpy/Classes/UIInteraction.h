//
//  UIInteraction.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIInteraction : NSObject

+ (instancetype)shareInteraction;

- (void)tapScreenAtX:(float)x andY:(float)y;

- (void)longPressScreenAtX:(float)x andY:(float)y withDuration:(float)duration;

- (void)twoFingerTapAtX:(float)x andY:(float)y;

- (void) dragStartAtX:(float)startX andY:(float)startY endAtX:(float)endX andY:(float)endY;

- (void) dragStartAtX:(float)startX andY:(float)startY endAtX:(float)endX andY:(float)endY withDuration:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
