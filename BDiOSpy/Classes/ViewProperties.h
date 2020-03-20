//
//  ViewProperties.h
//  BDiOSpy
//
//  Created by yanming.sysu on 2019/12/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,PropertyOP){
    Equal = 1,
    NotEqual = 2,
    REEqual = 3,
    More = 4,
    NoLess = 5,
    Less = 6,
    NoMore = 7,
};

@interface ViewProperties : NSObject

@property(nonatomic) NSString *type;
@property(nonatomic) NSString *text;
@property(nonatomic) BOOL isVisiable;
@property(nonatomic) BOOL isClickable;
@property(nonatomic) uint8_t options; //用于开启任意个属性进行匹配
@property(nonatomic) NSMutableArray *opArray; //存储操作符

- (instancetype) initWithDic:(NSDictionary *)dict;

- (instancetype) initWithView:(UIView *)view;

- (BOOL)paramsAccordance:(ViewProperties *)property;

- (void) addArrayProperties:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
