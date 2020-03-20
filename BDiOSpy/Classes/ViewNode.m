//
//  ViewNode.m
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/12.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "ViewNode.h"
#import "UIPhraser.h"
#import "UIAdditions/UIResponder+Additions.h"

@implementation ViewNode

- (instancetype) init {
    if (self = [super init]) {
        self.view = nil;
        self.subviews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype) initWithView:(UIView *)view {
    if ([super init]) {
        self.view = view;
        self.hashString = [NSString stringWithFormat:@"%lu",(unsigned long)[view bd_responderPath].hash];
    }
    return self;
}


- (instancetype) initWithViewArray:(NSArray<UIView *> *)views {
    ViewNode *viewNode = [[ViewNode alloc] init];
    for (UIView *view in views) {
        NSString *string = NSStringFromClass([view class]);
        if (![string isEqualToString:@"UITextEffectsWindow"]) {
            [viewNode.subviews addObject:[[ViewNode alloc] initWithView:view]];
        }
    }
    return viewNode;
}

- (ViewNode *) phraseViewsFromRoot:(NSArray<UIView *> *)viewArray {
    ViewNode *rootView = [[ViewNode alloc] initWithViewArray:viewArray];
    for (ViewNode __strong *viewNode in rootView.subviews) {
        viewNode = [self phraseViews:viewNode];
    }
    return rootView;
}

- (ViewNode *) phraseViews:(ViewNode *)viewNode {
    for (UIView *view in viewNode.view.subviews) {
        if (![view isEqual:viewNode.view]) {
            ViewNode *node = [[ViewNode alloc] initWithView:view];
            [self phraseViews:node];
            [viewNode.subviews addObject:node];
        }
    }
    return viewNode;
}

@end
