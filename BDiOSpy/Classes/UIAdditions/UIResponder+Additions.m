//
//  UIResponder+Additions.m
//  BDiOSpy
//
//  Created by yanming.sysu on 2019/12/10.
//

#import "UIResponder+Additions.h"

NSString * const kBDViewPathSeperator = @"/";

@implementation UIResponder (Additions)

- (NSString *)bd_viewControllerPath {

    UIViewController *responder = (UIViewController *)self;
    UIViewController *parent = responder.parentViewController;
    if (parent
        && ![parent isKindOfClass:[UINavigationController class]]
        && ![parent isKindOfClass:[UITabBarController class]]
        && !bd_ui_isMultiPage(parent)
        ) {

        NSArray *childs = [parent childViewControllers];
        return [NSString stringWithFormat:@"%@%@%@",[parent bd_viewControllerPath], kBDViewPathSeperator, [self pathIndexOfSameClass:childs]];
    }

    return NSStringFromClass(self.class);
}

- (NSString *)resPath {
    if ([self isKindOfClass:[UIViewController class]]) {
        return [self bd_viewControllerPath];
    }

    if ([self.nextResponder isKindOfClass:[UIView class]]) {
        UIView *parent = (UIView *)self.nextResponder;
        NSArray *childs = parent.subviews;
        return [NSString stringWithFormat:@"%@%@%@",[parent bd_responderPathNoDescription], kBDViewPathSeperator, [self pathIndexOfSameClass:childs]];
    }

    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        UIViewController *parent = (UIViewController *)self.nextResponder;
        return [NSString stringWithFormat:@"%@%@%@",[parent bd_viewControllerPath], kBDViewPathSeperator, NSStringFromClass(self.class)];
    }

    return NSStringFromClass(self.class);
}

- (NSString *)bd_responderPath {

    if ([self isKindOfClass:[UIViewController class]]) {
        return [self bd_viewControllerPath];
    }

    if ([self.nextResponder isKindOfClass:[UIView class]]) {
        UIView *parent = (UIView *)self.nextResponder;
        NSArray *childs = parent.subviews;
        return [NSString stringWithFormat:@"%@%@%@%@",[parent bd_responderPath], kBDViewPathSeperator, [self pathIndexOfSameClass:childs], self.description];
    }

    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        UIViewController *parent = (UIViewController *)self.nextResponder;
        return [NSString stringWithFormat:@"%@%@%@",[parent bd_viewControllerPath], kBDViewPathSeperator, NSStringFromClass(self.class)];
    }

    return NSStringFromClass(self.class);
}

- (NSString *)bd_responderPathNoDescription {

    if ([self isKindOfClass:[UIViewController class]]) {
        return [self bd_viewControllerPath];
    }

    if ([self.nextResponder isKindOfClass:[UIView class]]) {
        UIView *parent = (UIView *)self.nextResponder;
        NSArray *childs = parent.subviews;
        return [NSString stringWithFormat:@"%@%@%@",[parent bd_responderPathNoDescription], kBDViewPathSeperator, [self pathIndexOfSameClass:childs]];
    }

    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        UIViewController *parent = (UIViewController *)self.nextResponder;
        return [NSString stringWithFormat:@"%@%@%@",[parent bd_viewControllerPath], kBDViewPathSeperator, NSStringFromClass(self.class)];
    }

    return NSStringFromClass(self.class);
}

- (NSString *)pathIndexOfSameClass:(NSArray *)items {
    if (items.count <= 1) {
        return [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
    }

    NSMutableArray *sameItems = [NSMutableArray new];
    for (NSObject *item in items) {
        if (item) {
            if ([NSStringFromClass([self class]) isEqualToString:NSStringFromClass([item class])]) {
                [sameItems addObject:item];
            }
        }
    }

    if (sameItems.count <= 1) {
        return [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
    }
    
    NSUInteger index = [sameItems indexOfObject:self];
    return  [NSString stringWithFormat:@"%@[%lu]", NSStringFromClass([self class]), (unsigned long)index];
}

BOOL bd_ui_isMultiPage(UIViewController *page) {
    if ([page isKindOfClass:[UIPageViewController class]]) {
        UIPageViewController *parent = (UIPageViewController *)page;
        return parent.viewControllers.count > 1;
    }

    return NO;
}

@end
