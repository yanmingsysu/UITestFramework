//
//  Compact.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/21.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "JsonError.h"

#ifndef Compact_h
#define Compact_h

#define dispatch_main($block) (pthread_main_np() ? $block() : dispatch_sync(dispatch_get_main_queue(), $block))

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define JSON_ID @"id":dict[@"id"]

#define ERROR_JSON @{JSON_ID, @"error":@{@"code":@(ParameterNotEnough),@"message":@"necessary parameters no provided",},}

#define NOVIEW @"No view find for the id"

#endif /* Compact_h */
