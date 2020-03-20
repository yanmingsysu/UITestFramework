//
//  UIPhraser.h
//  testfrank
//
//  Created by yanming.sysu on 2019/11/11.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIPhraser : NSObject

+ (instancetype)sharePhraser;

- (NSArray<UIView *> *)allViewsInHierarchy;

- (NSArray<UIWindow *> *)allWindows;

- (NSDictionary<NSValue *, NSNumber *> *)hierarchyDepthsForViews:(NSArray<UIView *> *)views;

- (NSArray<ViewNode *> *) cacheViews;

@end

NS_ASSUME_NONNULL_END
