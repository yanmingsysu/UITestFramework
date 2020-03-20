//
//  JsonServer.m
//  iOSTestFramework
//
//  Created by yanming.sysu on 2019/11/7.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "JsonServer.h"
#import "GCDWebServerDataResponse.h"
#import "JsonPhraser.h"
#import "UIPhraser.h"
#import "ViewNode.h"
#import "UIInteraction.h"
#import "ViewProperties.h"
#import "UIAdditions/UIResponder+Additions.h"
#import "UIAdditions/UIView+Addtions.h"
#import "Compact.h"
#import "UIAutomationHelper.h"
#import <pthread.h>

@implementation JsonServer : NSObject

// initialize server
__attribute__((constructor)) static void load_server() {
    [JsonServer shareServer];
}

+(instancetype)shareServer {
    static JsonServer *shareServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareServer = [[self alloc] init];
    });
    return shareServer;
}

- (instancetype)init{
    NSLog(@"[BDiOSpy] server init alloc");
    if (self = [super init]) {
        self.viewNodeArray = [[NSMutableArray alloc] init];
        self.server = [[GCDWebServer alloc] init];
        self.isTest = NO; //修改此处进行切换测试和实际线上环境
        
        if (!self.isTest) {
            __weak typeof(self) weakSelf = self;
            [self.server addDefaultHandlerForMethod:@"POST"
                                       requestClass:[GCDWebServerDataRequest class]
                                       processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
                if (((GCDWebServerDataRequest *)request).jsonObject != nil) {
                    NSDictionary *dict = (NSDictionary *)((GCDWebServerDataRequest *)request).jsonObject;
                    return [GCDWebServerDataResponse responseWithJSONObject:[weakSelf jsonFromPhraser:dict]];
                }
                return [GCDWebServerDataResponse responseWithText:@"Server error:no json"];
            }];
        } else {
            __weak typeof(self) weakSelf = self;
            [self.server addDefaultHandlerForMethod:@"POST"
                                       requestClass:[GCDWebServerDataRequest class]
                                       processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
                if (((GCDWebServerDataRequest *)request).jsonObject != nil) {
                    NSDictionary *dict = (NSDictionary *)((GCDWebServerDataRequest *)request).jsonObject;
                    return [GCDWebServerDataResponse responseWithJSONObject:[weakSelf testConstructResponseJson:dict]];
                }
                return [GCDWebServerDataResponse responseWithText:@"Server error:no json"];
            }];
        }
        [self.server startWithPort:0 bonjourName:NULL];
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *stub_txt = [NSString stringWithFormat:@"%@stub_url.txt",tmpDir];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath: stub_txt]) {
            [fileManager removeItemAtPath: stub_txt error:nil];
        }
        if ([fileManager createFileAtPath: stub_txt
                                           contents:[self.server.serverURL.absoluteString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
            NSLog(@"%@", [NSString stringWithFormat:@"[BDiOSpy]successfully write url to file:%@serverurl.txt",tmpDir]);
        }
        NSLog(@"[BDiOSpy] Server start, url is:%@",self.server.serverURL);
    }
    return self;
}

#pragma mark - Real Json Construct

- (id)jsonFromPhraser:(NSDictionary *)dict {
    JsonPhraser *phraser = [[JsonPhraser alloc] init];
    return [phraser phraseCommandFromJson:dict];
}


#pragma mark - Test Json Construct

- (id)testConstructResponseJson:(NSDictionary *)dict {
    JsonPhraser *jsonPhraser = [[JsonPhraser alloc] init];
    JsonCommand cmd = [jsonPhraser phraseCommandFromDict:dict];
    switch (cmd) {
        case Error:
            return [self errorJson:dict];
        case Hello:
            return [self helloJson:dict];
        case GetUITree:
            return [self viewPhraseJson:dict];
        case Click:
            return [self clickJson:dict];
        case LongPress:
            return [self longPressJson:dict];
        case TwoFingerTap:
            return [self twoFingerTapJson:dict];
        case Drag:
            return [self dragJson:dict];
        case GetViewList:
            return [self getViewListJson:dict];
        case ViewGesture:
            return [self viewGestureJson:dict];
        case ClickAlert :
            return [self clickAlertViewJson:dict];
        default:
            return [self errorJson:dict];
            break;
    }
}

- (id)errorJson:(NSDictionary *)dict {
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"Error",
        @"ErrMsg":@"Error",
    };
    return reDict;
}

- (id)helloJson:(NSDictionary *)dict {
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"Hello",
        @"HelloResponse":@"Hello",
    };
    return reDict;
}

- (id)viewPhraseJson:(NSDictionary *)dict {
    JsonPhraser *jsonPhraser = [[JsonPhraser alloc] init];
    ViewNode *node = [[ViewNode alloc] init];
    node = [node phraseViewsFromRoot:[UIApplication sharedApplication].windows];
    NSString *viewPhraseJson = [jsonPhraser jsonWithViewNode:node];
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"GetUITree",
        @"Views":viewPhraseJson,
    };
    return reDict;
}

- (id)clickJson:(NSDictionary *)dict {
    float x = [dict[@"LocationX"] floatValue];
    float y = [dict[@"LocationY"] floatValue];
    [[UIInteraction shareInteraction]tapScreenAtX:x andY:y];
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"Click",
        @"ClickRes":@"Success",
    };
    return reDict;
}

- (id)longPressJson:(NSDictionary *)dict {
    float x = [dict[@"LocationX"] floatValue];
    float y = [dict[@"LocationY"] floatValue];
    float duration = [dict[@"Duration"] floatValue];
    [[UIInteraction shareInteraction] longPressScreenAtX:x andY:y withDuration:duration];
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"LongPress",
        @"LongPressRes":@"Success",
    };
    return reDict;
}

- (id)twoFingerTapJson:(NSDictionary *)dict {
    float x = [dict[@"LocationX"] floatValue];
    float y = [dict[@"LocationY"] floatValue];
    [[UIInteraction shareInteraction] twoFingerTapAtX:x andY:y];
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"TwoFingerTap",
        @"TwoFingerTap":@"Success",
    };
    return reDict;
}

- (id)dragJson:(NSDictionary *)dict {
    float startX = [dict[@"StartLocationX"] floatValue];
    float startY = [dict[@"StartLocationY"] floatValue];
    float endX = [dict[@"EndLocationX"] floatValue];
    float endY = [dict[@"EndLocationY"] floatValue];
    [[UIInteraction shareInteraction] dragStartAtX:startX andY:startY endAtX:endX andY:endY];
    NSDictionary *reDict = @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"Drag",
        @"Drag":@"Success",
    };
    return reDict;
}

- (id)getViewListJson:(NSDictionary *)dict {
    ViewProperties *viewPropertiesFromDic = [[ViewProperties alloc] initWithDic:dict[@"params"]];
    NSArray<UIView *> *viewArray = [[UIPhraser sharePhraser] allViewsInHierarchy];
    [self.viewNodeArray removeAllObjects];
    for (UIView * view in viewArray) {
        if ([viewPropertiesFromDic isEqual:[[ViewProperties alloc] initWithView:view]]) {
            [self.viewNodeArray addObject:[[ViewNode alloc] initWithView:view]];
        }
    }
    NSMutableDictionary *reDict = [@{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"GetViewList",
    } mutableCopy];
    if (self.viewNodeArray.count > 0) {
        NSMutableArray<NSString *> *viewIDArray = [[NSMutableArray alloc] init];
        for (ViewNode *node in self.viewNodeArray) {
            [viewIDArray addObject:node.hashString];
        }
        [reDict setObject:viewIDArray forKey:@"ViewList"];
    }
    return reDict;
}

- (id) viewGestureJson:(NSDictionary *)dict {
    NSString *viewID = dict[@"params"][@"viewID"];
    for (ViewNode *node in self.viewNodeArray) {
        if ([node.hashString isEqualToString:viewID]) {
            if (node.view) {
                if ([[NSString stringWithFormat:@"%lu",[node.view bd_responderPath].hash] isEqualToString:viewID]) {
                    dispatch_main(^(){
                       [node.view viewResponseToCmdDict:dict[@"params"]];
                    });
                } else {
                    return @{
                        @"Seq":dict[@"Seq"],
                        @"Cmd":@"ViewGesture",
                        @"Error":@"View has changed",
                    };
                }
            } else {
                return @{
                    @"Seq":dict[@"Seq"],
                    @"Cmd":@"ViewGesture",
                    @"Error":@"View has changed",
                };
            }
        }
    }
    return @{
        @"Seq":dict[@"Seq"],
        @"Cmd":@"ViewGesture",
        @"ViewGesture":@"Success",
    };
}

- (id)clickAlertViewJson:(NSDictionary *)dict {
    __block BOOL clickAlertViewResult;
    dispatch_main(^(){
        clickAlertViewResult = [UIAutomationHelper acknowledgeSystemAlert]; //some methods must be called in mainthread
    });
    if (clickAlertViewResult) {
        return @{
            @"Seq":dict[@"Seq"],
            @"Cmd":@"ClickAlert",
            @"ClickAlert":@"Success",
        };
    } else {
        return @{
            @"Seq":dict[@"Seq"],
            @"Cmd":@"ClickAlert",
            @"ClickAlert":@"Fail",
        };
    }
}

@end
