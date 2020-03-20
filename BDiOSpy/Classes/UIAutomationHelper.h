//
//  UIAutomationHelper.h
//  BDiOSpy
//
//  Created by yanming.sysu on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAutomationHelper : NSObject

+ (UIAutomationHelper *)sharedHelper;

+ (BOOL)acknowledgeSystemAlert;

+ (BOOL)acknowledgeSystemAlertWithIndex:(NSUInteger)index;

+ (void)deactivateAppForDuration:(NSNumber *)duration;

@end

NS_ASSUME_NONNULL_END
