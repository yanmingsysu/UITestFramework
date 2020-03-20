//
//  ViewNode.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/12.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewNode : NSObject

@property(nonatomic, weak, nullable) __weak UIView *view;
@property(nonatomic) NSString *hashString;
@property(nonatomic, strong) NSMutableArray<ViewNode *> *subviews;

- (instancetype) init;

- (instancetype) initWithView:(UIView *)view;

- (ViewNode *) phraseViewsFromRoot:(NSArray<UIView *> *)viewArray;

@end

NS_ASSUME_NONNULL_END
