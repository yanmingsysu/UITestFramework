//
//  JsonServer.h
//  iOSTestFramework
//
//  Created by yanming.sysu on 2019/11/7.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDWebServer.h"
#import "GCDWebServerDataRequest.h"
#import "ViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface JsonServer : NSObject

@property(nonatomic) GCDWebServer *server;
@property() BOOL isTest; //用于测试还是用于实际使用，通过修改该选项可以切换命令组织方式

@property(nonatomic) NSMutableArray<ViewNode *> *viewNodeArray;

+(instancetype)shareServer;

-(instancetype)init;

@end

NS_ASSUME_NONNULL_END
