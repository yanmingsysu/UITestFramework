//
//  UIEvent+Additions.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIEvent (AdditionsPrivateHeaders)
- (void)_addTouch:(UITouch *)touch forDelayedDelivery:(BOOL)arg2;
- (void)_clearTouches;
@end

@interface UIEvent (Additions)
- (void)setEventWithTouches:(NSArray *)touches;
@end

NS_ASSUME_NONNULL_END
