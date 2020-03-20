//
//  JsonError.h
//  BDiOSpy
//
//  Created by yanming.sysu on 2020/2/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BDiOSpyError) {
    ParameterNotEnough  = 1001, //参数不全
    ParameterWrong      = 1002, //参数错误
    NoElementMatches    = 1003, //所提供id无法找到对应的view
    NoPropertyMatches   = 1004, //所提供id无所查询属性
    
};

@interface JsonError : NSObject

@end

NS_ASSUME_NONNULL_END
