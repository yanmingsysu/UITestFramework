//
//  UIInteraction.m
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "UIInteraction.h"
#import <UIKit/UIKit.h>
#import "UIAdditions/UIApplication+Additions.h"
#import "UIAdditions/UIView+Addtions.h"
#import "UIAdditions/UITouch+Additions.h"
#import <WebKit/WebKit.h>
#import <pthread.h>
#import "Compact.h"
#import "UIPhraser.h"


@implementation UIInteraction

+ (instancetype)shareInteraction {
    static UIInteraction *_shareInteraction = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInteraction = [[UIInteraction alloc] init];
    });
    
    return _shareInteraction;
}

- (void)tapScreenAtX:(float)x andY:(float)y {
    CGFloat cgX = x;
    CGFloat cgY = y;
    [self tapScreenAtPoint:CGPointMake(cgX, cgY)];
}

- (void)tapScreenAtPoint:(CGPoint)screenPoint
{
    dispatch_main(^(){
        UIView *view = [self viewAtPoint:screenPoint];
        // This is mostly redundant of the test in _accessibilityElementWithLabel:
        CGPoint viewPoint = [view convertPoint:screenPoint fromView:nil];
        [view tapAtPoint:viewPoint];
    });
}

- (void)longPressScreenAtX:(float)x andY:(float)y withDuration:(float)duration {
    dispatch_main(^(){
        UIView *view = [self viewAtX:x andY:y];
        CGPoint viewPoint = [view convertPoint:CGPointMake(x, y) fromView:nil];
        NSTimeInterval timeDuration = duration;
        [view longPressAtPoint:viewPoint duration:timeDuration];
    });
}

- (void)twoFingerTapAtX:(float)x andY:(float)y {
    dispatch_main(^(){
        UIView *view = [self viewAtX:x andY:y];
        CGPoint viewPoint = [view convertPoint:CGPointMake(x, y) fromView:nil];
        [view twoFingerTapAtPoint:viewPoint];
    });
}

- (void) dragStartAtX:(float)startX andY:(float)startY endAtX:(float)endX andY:(float)endY {
    dispatch_main(^(){
        UIView *view = [self viewAtX:startX andY:startY];
        [view dragFromPoint:CGPointMake(startX, startY) toPoint:CGPointMake(endX, endY)];
        NSLog(@"[BDiOSpy] system drag");
    });
}

- (void) dragStartAtX:(float)startX andY:(float)startY endAtX:(float)endX andY:(float)endY withDuration:(NSInteger)count {
    dispatch_main(^(){
        UIView *view = [self viewAtX:startX andY:startY];
        [view dragFromPoint:CGPointMake(startX, startY) toPoint:CGPointMake(endX, endY) steps:count];
        NSLog(@"[BDiOSpy] system drag");
    });
}

#pragma mark - inline methods

- (UIView *)viewAtX:(float)x andY:(float)y {
    CGPoint screenPoint = CGPointMake(x, y);
    return [self viewAtPoint:screenPoint];
}

- (UIView *)viewAtPoint:(CGPoint)screenPoint {
    __block UIView *view = nil;
    dispatch_main(^(){
        for (UIWindow *window in [[[UIApplication sharedApplication] windowsWithKeyWindow] reverseObjectEnumerator]) {
            CGPoint windowPoint = [window convertPoint:screenPoint fromView:nil];
            view = [window hitTest:windowPoint withEvent:nil];
            
            // If we hit the window itself, then skip it.
            if ((view != window && view != nil) || [view.subviews[0] isKindOfClass:NSClassFromString(@"WKWebView")]) {
                break;
            }
        }
    });
    return view;
}

@end
