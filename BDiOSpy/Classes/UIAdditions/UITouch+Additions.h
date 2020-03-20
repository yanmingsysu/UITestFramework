//
//  UITouch+Additions.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITouch (Additions)

- (id)initInView:(UIView *)view;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)view;

- (void)setLocationInWindow:(CGPoint)location;
- (void)setPhaseAndUpdateTimestamp:(UITouchPhase)phase;

@end

NS_ASSUME_NONNULL_END
