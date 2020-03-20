//
//  JsonPhraser.h
//  testfrank
//
//  Created by yanming.sysu on 2019/11/11.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewNode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JsonCommand){
    Error = 0,
    Hello = 1,
    GetUITree = 2,
    Click = 3,
    LongPress = 4,
    TwoFingerTap = 5,
    Drag = 6,
    GetViewList = 7,
    ViewGesture = 8,
    ClickAlert = 9,
};

@interface JsonPhraser : NSObject

- (NSDictionary *)jsonCmdPhrase:(NSData *)data;

- (id)phraseCommandFromJson:(NSDictionary *)dict;

- (JsonCommand)phraseCommandFromDict:(NSDictionary *)dict;

- (NSString *) jsonWithViewNode:(ViewNode *)rootView;

@end

NS_ASSUME_NONNULL_END
