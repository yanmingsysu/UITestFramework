//
//  UIPhraser.m
//  testfrank
//
//  Created by yanming.sysu on 2019/11/11.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import "UIPhraser.h"
#import <UIKit/UIKit.h>
#import "ViewNode.h"
#import "Compact.h"
#import <pthread.h>

@implementation UIPhraser

+ (instancetype) sharePhraser {
    static UIPhraser *_sharePhraser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharePhraser = [[UIPhraser alloc] init];
    });
    
    return _sharePhraser;
}

// this method is from flex
- (NSArray<UIWindow *> *)allWindows {
    BOOL includeInternalWindows = YES;
    BOOL onlyVisibleWindows = NO;

    // Obfuscating selector allWindowsIncludingInternalWindows:onlyVisibleWindows:
    NSArray<NSString *> *allWindowsComponents = @[@"al", @"lWindo", @"wsIncl", @"udingInt", @"ernalWin", @"dows:o", @"nlyVisi", @"bleWin", @"dows:"];
    SEL allWindowsSelector = NSSelectorFromString([allWindowsComponents componentsJoinedByString:@""]);

    NSMethodSignature *methodSignature = [[UIWindow class] methodSignatureForSelector:allWindowsSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];

    invocation.target = [UIWindow class];
    invocation.selector = allWindowsSelector;
    [invocation setArgument:&includeInternalWindows atIndex:2];
    [invocation setArgument:&onlyVisibleWindows atIndex:3];
    [invocation invoke];

    __unsafe_unretained NSArray<UIWindow *> *windows = nil;
    [invocation getReturnValue:&windows];
    return windows;
}

- (NSArray<UIView *> *)allViewsInHierarchy
{
    NSMutableArray<UIView *> *allViews = [NSMutableArray array];
    NSArray<UIWindow *> *windows = [self allWindows];
    for (UIWindow *window in windows) {
        [allViews addObject:window];
        [allViews addObjectsFromArray:[self allRecursiveSubviewsInView:window]];
    }
    return allViews;
}

- (NSArray<UIView *> *)allRecursiveSubviewsInView:(UIView *)view
{
    __block NSMutableArray<UIView *> *subviews = [NSMutableArray array];
    dispatch_main(^{
        for (UIView *subview in view.subviews) {
            [subviews addObject:subview];
            [subviews addObjectsFromArray:[self allRecursiveSubviewsInView:subview]];
        }
    });
    return subviews;
}

- (NSDictionary<NSValue *, NSNumber *> *)hierarchyDepthsForViews:(NSArray<UIView *> *)views {
    NSMutableDictionary<NSValue *, NSNumber *> *hierarchyDepths = [NSMutableDictionary dictionary];
    for (UIView *view in views) {
        NSInteger depth = 0;
        UIView *tryView = view;
        while (tryView.superview) {
            tryView = tryView.superview;
            depth++;
        }
        [hierarchyDepths setObject:@(depth) forKey:[NSValue valueWithNonretainedObject:view]];
    }
    return hierarchyDepths;
}

- (NSArray<ViewNode *> *) cacheViews {
    NSMutableArray<ViewNode *> *viewArray = [[NSMutableArray alloc] init];
    NSArray<UIView *> *views = [[UIPhraser sharePhraser] allViewsInHierarchy];
    for (UIView *view in views) {
        [viewArray addObject:[[ViewNode alloc] initWithView:view]];
    }
    return viewArray;
}

@end
