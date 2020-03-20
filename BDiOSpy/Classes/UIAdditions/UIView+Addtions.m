//
//  UIView+Addtions.m
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "UIApplication+Additions.h"
#import "UITouch+Additions.h"
#import "UIEvent+Additions.h"
#import "Compact.h"
#import "UIResponder+Additions.h"
#import "CGGeometry+Additions.h"
#import "JsonPhraser.h"
#import <pthread.h>
#import <UIKit/UIKit.h>


@interface UIApplication (AdditionsPrivate)
- (UIEvent *)_touchesEvent;
@end

@implementation UIView (Addtions)

- (UIEvent *)eventWithTouch:(UITouch *)touch;
{
    NSArray *touches = touch ? @[touch] : nil;
    return [self eventWithTouches:touches];
}

- (UIEvent *)eventWithTouches:(NSArray *)touches
{
    // _touchesEvent is a private selector, interface is exposed in UIApplication(AdditionsPrivate)
    UIEvent *event = [[UIApplication sharedApplication] _touchesEvent];
    
    [event _clearTouches];
    [event setEventWithTouches:touches];

    for (UITouch *aTouch in touches) {
        [event _addTouch:aTouch forDelayedDelivery:NO];
    }

    return event;
}

- (void) viewResponseToCmdDict:(NSDictionary *)dict{
    JsonPhraser *jsonPhraser = [[JsonPhraser alloc] init];
    JsonCommand cmd = [jsonPhraser phraseCommandFromDict:dict];
    CGRect frame = [self.window convertRect:self.bounds fromView:self];
    CGPoint point = [self convertPoint:CGPointCenteredInRect(frame) fromView:nil];
    switch (cmd) {
        case Click:
            [self tapAtPoint:point];
            break;
        case TwoFingerTap:
            [self twoFingerTapAtPoint:point];
            break;
        case LongPress:
            [self longPressAtPoint:point duration:[dict[@"duration"] integerValue]];
            break;
        case Drag: {
            NSString *direction = dict[@"direction"];
            if ([direction isEqualToString:@"Up"]) {
                [self dragFromPoint:point toPoint:CGPointMake(point.x, point.y - 40)];
            }
            if ([direction isEqualToString:@"Down"]) {
                [self dragFromPoint:point toPoint:CGPointMake(point.x, point.y + 40)];
            }
            if ([direction isEqualToString:@"Left"]) {
                [self dragFromPoint:point toPoint:CGPointMake(point.x - 40, point.y)];
            }
            if ([direction isEqualToString:@"Right"]) {
                [self dragFromPoint:point toPoint:CGPointMake(point.x + 40, point.y)];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -Gestures

- (void)tapAtPoint:(CGPoint)point {
    // Web views don't handle touches in a normal fashion, but they do have a method we can call to tap them
    // This may not be necessary anymore. We didn't properly support controls that used gesture recognizers
    // when this was added, but we now do. It needs to be tested before we can get rid of it.
//    id /*UIWebBrowserView*/ webBrowserView = nil;
//
//    if ([NSStringFromClass([self class]) isEqual:@"UIWebBrowserView"]) {
//        webBrowserView = self;
//    } else if ([self isKindOfClass:[UIWebView class]]) {
//        id webViewInternal = [self valueForKey:@"_internal"];
//        webBrowserView = [webViewInternal valueForKey:@"browserView"];
//    }
//
//    if (webBrowserView) {
//        [webBrowserView tapInteractionWithLocation:point];
//        return;
//    }
    
    // Handle touches in the normal way for other views
    UITouch *touch = [[UITouch alloc] initAtPoint:point inView:self];
    [touch setPhaseAndUpdateTimestamp:UITouchPhaseBegan];
    
    UIEvent *event = [self eventWithTouch:touch];

    [[UIApplication sharedApplication] sendEvent:event];
    
    [touch setPhaseAndUpdateTimestamp:UITouchPhaseEnded];
    [[UIApplication sharedApplication] sendEvent:event];

    // Dispatching the event doesn't actually update the first responder, so fake it
    if ([touch.view isDescendantOfView:self] && [self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
}

static CGFloat const kTwoFingerConstantWidth = 42; //42 is a magic number, which is the answer of the universe :)

- (void)twoFingerTapAtPoint:(CGPoint)point {
    CGPoint finger1 = CGPointMake(point.x - kTwoFingerConstantWidth, point.y - kTwoFingerConstantWidth);
    CGPoint finger2 = CGPointMake(point.x + kTwoFingerConstantWidth, point.y + kTwoFingerConstantWidth);
    UITouch *touch1 = [[UITouch alloc] initAtPoint:finger1 inView:self];
    UITouch *touch2 = [[UITouch alloc] initAtPoint:finger2 inView:self];
    [touch1 setPhaseAndUpdateTimestamp:UITouchPhaseBegan];
    [touch2 setPhaseAndUpdateTimestamp:UITouchPhaseBegan];

    UIEvent *event = [self eventWithTouches:@[touch1, touch2]];
    [[UIApplication sharedApplication] sendEvent:event];

    [touch1 setPhaseAndUpdateTimestamp:UITouchPhaseEnded];
    [touch2 setPhaseAndUpdateTimestamp:UITouchPhaseEnded];

    [[UIApplication sharedApplication] sendEvent:event];
}

#define DRAG_TOUCH_DELAY 0.01 //set the minimum time interval to 0.01s

- (void)longPressAtPoint:(CGPoint)point duration:(NSTimeInterval)duration {
    UITouch *touch = [[UITouch alloc] initAtPoint:point inView:self];
    [touch setPhaseAndUpdateTimestamp:UITouchPhaseBegan];
    
    UIEvent *eventDown = [self eventWithTouch:touch];
    [[UIApplication sharedApplication] sendEvent:eventDown];
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, DRAG_TOUCH_DELAY, false);
    
    for (NSTimeInterval timeSpent = DRAG_TOUCH_DELAY; timeSpent < duration; timeSpent += DRAG_TOUCH_DELAY)
    {
        [touch setPhaseAndUpdateTimestamp:UITouchPhaseStationary];
        
        UIEvent *eventStillDown = [self eventWithTouch:touch];
        [[UIApplication sharedApplication] sendEvent:eventStillDown];
        
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, DRAG_TOUCH_DELAY, false);
    }
    
    [touch setPhaseAndUpdateTimestamp:UITouchPhaseEnded];
    UIEvent *eventUp = [self eventWithTouch:touch];
    [[UIApplication sharedApplication] sendEvent:eventUp];
    
    // Dispatching the event doesn't actually update the first responder, so fake it
    if ([touch.view isDescendantOfView:self] && [self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
    
}

- (void)dragFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint {
    NSInteger distance = (NSInteger)sqrt(pow(startPoint.x - endPoint.x, 2)+pow(startPoint.y - endPoint.y, 2));
    NSInteger count = distance / 3 + 10; // don't modify this!
    [self dragFromPoint:startPoint toPoint:endPoint steps:count];
}


- (void)dragFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint steps:(NSUInteger)stepCount {
    NSArray<NSValue *> *path = [self pointsFromStartPoint:startPoint toPoint:endPoint steps:stepCount];
    [self dragPointsAlongPaths:@[path]];
}

- (void)dragAlongPathWithPoints:(CGPoint *)points count:(NSInteger)count {
    // convert point array into NSArray with NSValue
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++)
    {
        [array addObject:[NSValue valueWithCGPoint:points[i]]];
    }
    [self dragPointsAlongPaths:@[[array copy]]];
}

- (void)dragPointsAlongPaths:(NSArray<NSArray<NSValue *> *> *)arrayOfPaths {
    // There must be at least one path with at least one point
    if (arrayOfPaths.count == 0 || arrayOfPaths.firstObject.count == 0) {
        return;
    }

    // all paths must have the same number of points
    NSUInteger pointsInPath = [arrayOfPaths[0] count];
    for (NSArray *path in arrayOfPaths) {
        if (path.count != pointsInPath) {
            return;
        }
    }

    NSMutableArray<UITouch *> *touches = [NSMutableArray array];
    
    // Convert paths to be in window coordinates before we start, because the view may move relative to the window.
//    NSMutableArray<NSArray<NSValue *> *> *newPaths = [[NSMutableArray alloc] init];
    
//    for (NSArray * path in arrayOfPaths) {
//        NSMutableArray<NSValue *> *newPath = [[NSMutableArray alloc] init];
//        for (NSValue *pointValue in path) {
//            CGPoint point = [pointValue CGPointValue];
//            [newPath addObject:[NSValue valueWithCGPoint:point]];
//        }
//        [newPaths addObject:newPath];
//    }
    
//    arrayOfPaths = newPaths;

    for (NSUInteger pointIndex = 0; pointIndex < pointsInPath; pointIndex++) {
        // create initial touch event and send touch down event
        if (pointIndex == 0) {
            for (NSArray<NSValue *> *path in arrayOfPaths) {
                CGPoint point = [path[pointIndex] CGPointValue];
                // The starting point needs to be relative to the view receiving the UITouch event.
                point = [self convertPoint:point fromView:self.window];
                UITouch *touch = [[UITouch alloc] initAtPoint:point inView:self];
                [touch setPhaseAndUpdateTimestamp:UITouchPhaseBegan];
                [touches addObject:touch];
            }
            UIEvent *eventDown = [self eventWithTouches:[NSArray arrayWithArray:touches]];
            [[UIApplication sharedApplication] sendEvent:eventDown];
            
            CFRunLoopRunInMode(UIApplicationCurrentRunMode, DRAG_TOUCH_DELAY, false);
        }
        else {
            UITouch *touch;
            for (NSUInteger pathIndex = 0; pathIndex < arrayOfPaths.count; pathIndex++) {
                NSArray<NSValue *> *path = arrayOfPaths[pathIndex];
                CGPoint point = [path[pointIndex] CGPointValue];
                touch = touches[pathIndex];
                [touch setLocationInWindow:point];
                [touch setPhaseAndUpdateTimestamp:UITouchPhaseMoved];
            }
            UIEvent *event = [self eventWithTouches:[NSArray arrayWithArray:touches]];
            [[UIApplication sharedApplication] sendEvent:event];

            CFRunLoopRunInMode(UIApplicationCurrentRunMode, DRAG_TOUCH_DELAY, false);

            // The last point needs to also send a phase ended touch.
            if (pointIndex == pointsInPath - 1) {
                for (UITouch * touch in touches) {
                    [touch setPhaseAndUpdateTimestamp:UITouchPhaseEnded];
                    UIEvent *eventUp = [self eventWithTouch:touch];
                    [[UIApplication sharedApplication] sendEvent:eventUp];
                }
            }
        }
    }

    // Dispatching the event doesn't actually update the first responder, so fake it
    if ([touches.firstObject view] == self && [self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }

    while (UIApplicationCurrentRunMode != kCFRunLoopDefaultMode) {
        CFRunLoopRunInMode(UIApplicationCurrentRunMode, 0.1, false);
    }
}

- (NSArray<NSValue *> *)pointsFromStartPoint:(CGPoint)startPoint toPoint:(CGPoint)toPoint steps:(NSUInteger)stepCount {

    CGPoint displacement = CGPointMake(toPoint.x - startPoint.x, toPoint.y - startPoint.y);
    NSMutableArray<NSValue *> *points = [NSMutableArray array];

    for (NSUInteger i = 0; i < stepCount; i++) {
        CGFloat progress = ((CGFloat)i)/(stepCount - 1);
        CGPoint point = CGPointMake(startPoint.x + (progress * displacement.x),
                                    startPoint.y + (progress * displacement.y));
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    return [points copy];
}

- (BOOL)isVisible {
    if (self == nil) {
            return FALSE;
        }
    CGRect screenRect = [UIScreen mainScreen].bounds;
//    CGRect rect = [self convertRect:self.frame fromView:nil];
    CGRect rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return FALSE;
    }
    if (self.hidden) {
        return FALSE;
    }
    if (self.superview == nil) {
        return FALSE;
    }
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  FALSE;
    }
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return FALSE;
    }
    
    return TRUE;
}

- (NSDictionary *) getRect {
    __block CGRect rect;
    dispatch_main(^{
        rect = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    });
    return @{
        @"left":@(rect.origin.x),
        @"top":@(rect.origin.y),
        @"width":@(rect.size.width),
        @"height":@(rect.size.height),
    };
}

- (NSString *)getElemText {
    __block NSString *str = [[NSString alloc] init];
    dispatch_main(^{
        if (![self respondsToSelector:NSSelectorFromString(@"text")]) {
            str = @"";
        } else {
            str = [self valueForKey:@"text"];
        }
    });
    if (!str) {
        return @"";
    }
    return str;
}

- (BOOL)isClickable;
{
    return ([self hasTapGestureRecognizer] ||
            [self isTappableInRect:self.bounds]);
}

- (BOOL)hasTapGestureRecognizer
{
    __block BOOL hasTapGestureRecognizer = NO;
    
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj,
                                                          NSUInteger idx,
                                                          BOOL *stop) {
        if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
            hasTapGestureRecognizer = YES;
            
            if (stop != NULL) {
                *stop = YES;
            }
        }
    }];
    
    return hasTapGestureRecognizer;
}

- (BOOL)isTappableInRect:(CGRect)rect;
{
    CGPoint tappablePoint = [self tappablePointInRect:rect];
    return !isnan(tappablePoint.x);
}

- (CGPoint)tappablePointInRect:(CGRect)rect;
{
    // Start at the top and recurse down
    CGRect frame = [self.window convertRect:rect fromView:self];
    
    UIView *hitView = nil;
    CGPoint tapPoint = CGPointZero;
    
    // Mid point
    tapPoint = CGPointCenteredInRect(frame);
    hitView = [self.window hitTest:tapPoint withEvent:nil];
    if ([self isTappableWithHitTestResultView:hitView]) {
        return [self.window convertPoint:tapPoint toView:self];
    }
    
    // Top left
    tapPoint = CGPointMake(frame.origin.x + 1.0f, frame.origin.y + 1.0f);
    hitView = [self.window hitTest:tapPoint withEvent:nil];
    if ([self isTappableWithHitTestResultView:hitView]) {
        return [self.window convertPoint:tapPoint toView:self];
    }
    
    // Top right
    tapPoint = CGPointMake(frame.origin.x + frame.size.width - 1.0f, frame.origin.y + 1.0f);
    hitView = [self.window hitTest:tapPoint withEvent:nil];
    if ([self isTappableWithHitTestResultView:hitView]) {
        return [self.window convertPoint:tapPoint toView:self];
    }
    
    // Bottom left
    tapPoint = CGPointMake(frame.origin.x + 1.0f, frame.origin.y + frame.size.height - 1.0f);
    hitView = [self.window hitTest:tapPoint withEvent:nil];
    if ([self isTappableWithHitTestResultView:hitView]) {
        return [self.window convertPoint:tapPoint toView:self];
    }
    
    // Bottom right
    tapPoint = CGPointMake(frame.origin.x + frame.size.width - 1.0f, frame.origin.y + frame.size.height - 1.0f);
    hitView = [self.window hitTest:tapPoint withEvent:nil];
    if ([self isTappableWithHitTestResultView:hitView]) {
        return [self.window convertPoint:tapPoint toView:self];
    }
    
    return CGPointMake(NAN, NAN);
}

- (BOOL)isTappableWithHitTestResultView:(UIView *)hitView;
{
    // Special case for UIControls, which may have subviews which don't respond to -hitTest:,
    // but which are tappable. In this case the hit view will be the containing
    // UIControl, and it will forward the tap to the appropriate subview.
    // This applies with UISegmentedControl which contains UISegment views (a private UIView
    // representing a single segment).
    if ([hitView isKindOfClass:[UIControl class]] && [self isDescendantOfView:hitView]) {
        return YES;
    }
    
    // Button views in the nav bar (a private class derived from UINavigationItemView), do not return
    // themselves in a -hitTest:. Instead they return the nav bar.
    if ([hitView isKindOfClass:[UINavigationBar class]] && [self isNavigationItemView] && [self isDescendantOfView:hitView]) {
        return YES;
    }
    
    return [hitView isDescendantOfView:self];
}

- (BOOL)isNavigationItemView;
{
    return [self isKindOfClass:NSClassFromString(@"UINavigationItemView")] || [self isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")];
}

@end
