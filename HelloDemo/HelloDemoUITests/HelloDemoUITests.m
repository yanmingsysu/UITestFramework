//
//  HelloDemoUITests.m
//  HelloDemoUITests
//
//  Created by Lin Yong on 2020/1/15.
//  Copyright © 2020 ByteDance. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServer.h>


@interface HelloDemoUITests : XCTestCase
@property (nonatomic, strong) GCDWebServer *server;
@end

@implementation HelloDemoUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (NSDictionary *)makeResultWithId:(NSString *)aid err:(int)code errMsg:(NSString *)msg {
    NSDictionary *resultDict = nil;
    if (code != 0) {
        resultDict = @{
            @"id": aid,
            @"error": @{
                    @"name": @"Error",
                    @"code": @(code),
                    @"message": msg ? msg : @""
            }
        };
    }
    else {
        resultDict = @{@"id": aid, @"result": @(YES)};
    }
    return resultDict;
}

- (NSDictionary *)handleReq:(NSDictionary *)data {
    NSDictionary *params = data[@"params"];
    NSLog(@"params: %@", params);
    NSArray<NSString *> *buttons = params[@"button_text"];
    if ([buttons count] <= 0) {
        return [self makeResultWithId:data[@"id"] err:1 errMsg:@"button_text should not be empty"];
    }
    
    int timeout = [params[@"timeout"] intValue];
    timeout = timeout > 0 ? timeout : 0;
    sleep(timeout);
    
    NSString *bundleId = params[@"bundle_id"];
    __block NSDictionary *resultDict = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
         XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:bundleId];
         XCUIElement *e = [[app descendantsMatchingType:XCUIElementTypeAlert] element];
        if (![e exists]) {
            e = [[app descendantsMatchingType:XCUIElementTypeSheet] element];
        }
        if (![e exists]) {
            XCUIApplication *spring = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
            e = [[spring descendantsMatchingType:XCUIElementTypeAlert] element];
        }
        if (![e exists]) {
            XCUIApplication *spring = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
            e = [[spring descendantsMatchingType:XCUIElementTypeSheet] element];
        }
         if ([e exists]) {
             for (NSString *button in buttons) {
                 XCUIElement *targetBtn = e.buttons[button];
                 if ([targetBtn exists]) {
                     [targetBtn tap];
                     resultDict = [self makeResultWithId:data[@"id"] err:0 errMsg:nil];
                     return;
                 }
             }
         }
         else {
             resultDict = [self makeResultWithId:data[@"id"] err:2 errMsg:@"alert not exists"];
         }
    });
    
    if (resultDict) {
        return resultDict;
    }
    
    
    return [self makeResultWithId:data[@"id"] err:3 errMsg:@"cannot find targt button"];
}


- (void)testExample {
    // UI tests must launch the application that they test.

//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app launch];

    
//    [self addUIInterruptionMonitorWithDescription:@"Dismiss Alert" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
//        [interruptingElement.buttons[@"OK"] tap];
//        return true;
//    }];
    
    
    self.server = [[GCDWebServer alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.server addDefaultHandlerForMethod:@"POST"
                               requestClass:[GCDWebServerDataRequest class]
                               processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
        if (((GCDWebServerDataRequest *)request).jsonObject != nil) {
            NSDictionary *dict = (NSDictionary *)((GCDWebServerDataRequest *)request).jsonObject;
            return [GCDWebServerDataResponse responseWithJSONObject:[weakSelf handleReq:dict]];
        }
        return [GCDWebServerDataResponse responseWithText:@"Server error:no json"];
    }];
    
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithInteger:8088] forKey:GCDWebServerOption_Port];
    [options setObject:@(NO) forKey:GCDWebServerOption_AutomaticallySuspendInBackground];

    if ([self.server startWithOptions:options error:nil]) {
        NSLog(@"server start successfuly: %@", self.server.serverURL);

    }

    
//    [app tap]; // need to interact with the app for the handler to fire
    
//    XCUIElement *e = [[app descendantsMatchingType:XCUIElementTypeAlert] element];
//    BOOL rst = [e waitForExistenceWithTimeout:5];
//    NSLog(@"wait: %d, elem:%@", rst, e);
    
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);

    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


@end
