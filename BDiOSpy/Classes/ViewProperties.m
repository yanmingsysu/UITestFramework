//
//  ViewProperties.m
//  BDiOSpy
//
//  Created by yanming.sysu on 2019/12/16.
//

#import "ViewProperties.h"
#import "Compact.h"
#import "UIAdditions/UIView+Addtions.h"
#import <pthread.h>

@implementation ViewProperties

- (instancetype) initWithDic:(NSDictionary *)dict {
    if ([super init]) {
        if (dict[@"type"]) {
            self.options |= 0x08;
            self.type = dict[@"type"];
        }
        if (dict[@"text"]) {
            self.options |= 0x04;
            self.text = dict[@"text"];
        }
        if (dict[@"isVisiable"]) {
            self.options |= 0x02;
            self.isVisiable = [dict[@"isVisiable"] boolValue];
        }
        if (dict[@"isClickable"]) {
            self.options |= 0x01;
            self.isClickable = [dict[@"isClickable"] boolValue];
        }
        
    }
    return self;
}

- (instancetype) initWithView:(UIView *)view {
    if ([super init]) {
        self.type = NSStringFromClass([view class]);
        if ([view respondsToSelector:NSSelectorFromString(@"text")]) {
            if ([view valueForKey:@"text"]) {
                self.text = [view valueForKey:@"text"];
            }
            NSLog(@"[BDiOSpy] i have text property");
        }
        dispatch_main(^(){
            self.isVisiable = !(view.isHidden);
            self.isClickable = [view isClickable];
        });
    }
    return self;
}


//this method should be used by viewporperties from dict!!!
- (BOOL)isEqual:(id)object {
    ViewProperties *viewProperties = (ViewProperties *)object;
    if ((self.options & 0x08) == 0x08) {
        if (![self.type isEqual:viewProperties.type]) {
            return NO;
        }
    }
    if ((self.options & 0x04) == 0x04) {
        if (!viewProperties.text) {
            return NO;
        } else {
            if (![self.text isEqual:viewProperties.text]) {
                return NO;
            }
        }
    }
    if ((self.options & 0x02) == 0x02) {
        if (self.isVisiable != viewProperties.isVisiable) {
            return NO;
        }
    }
    if ((self.options & 0x01) == 0x01) {
        if (self.isClickable != viewProperties.isClickable) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)paramsAccordance:(ViewProperties *)property {
    if ((self.options & 0x08) == 0x08) {
        if ([self.opArray[0] integerValue] == 1) {
            if (![NSClassFromString(property.type) isSubclassOfClass:NSClassFromString(self.type)] && ![self.type isEqualToString:property.type]) {
                return NO;
            }
        } else if (![self text:self.type satisfyOP:[self.opArray[0] integerValue] withText:property.type]) {
            return NO;
        }
    }
    if ((self.options & 0x04) == 0x04) {
        if (![self text:self.text satisfyOP:[self.opArray[1] integerValue] withText:property.text]) {
            return NO;
        }
    }
    if ((self.options & 0x02) == 0x02) {
        if (![self boolean:self.isVisiable satisfyOP:[self.opArray[2] integerValue] withBoolean:property.isVisiable]){
            return NO;
        }
    }
    if ((self.options & 0x01) == 0x01) {
        if (![self boolean:self.isClickable satisfyOP:[self.opArray[3] integerValue] withBoolean:property.isClickable]){
            return NO;
        }
    }
    return YES;
}

- (BOOL) text:(NSString *)str1 satisfyOP:(NSInteger)op withText:(NSString *)str2 {
    switch (op) {
        case 1:{
            if ([str1 isEqual:str2]){
                return YES;
            } else {
                return NO;
            }
        }
            break;
        case 2:{
            if (![str1 isEqual:str2]){
                return YES;
            } else {
                return NO;
            }
        }
            break;
        case 3:{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",str1];
            if ([predicate evaluateWithObject:str2]) {
                return YES;
            } else {
                return NO;
            }
        }
            break;
        default:
            return NO;
            break;
    }
}

- (BOOL) boolean:(BOOL)b1 satisfyOP:(NSInteger)op withBoolean:(BOOL)b2 {
    switch (op) {
        case 1:{
            if (b1 == b2) {
                return YES;
            } else {
                return NO;
            }
        }
        case 2:{
            if (b1 != b2) {
                return YES;
            } else {
                return NO;
            }
        }
        default:
            return NO;
    }
}

- (void) addArrayProperties:(NSDictionary *)dict {
    if (self.opArray == nil) {
        self.opArray = [NSMutableArray arrayWithArray:@[@0, @0, @0, @0]];
    }
    if ([dict[@"name"] isEqualToString:@"type"]) {
        [self.opArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:[self phraseOP:dict[@"operator"]]]];
        self.type = dict[@"value"];
        self.options |= 0x08;
    }
    if ([dict[@"name"] isEqualToString:@"text"]) {
        [self.opArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:[self phraseOP:dict[@"operator"]]]];
        self.text = dict[@"value"];
        self.options |= 0x04;
    }
    if ([dict[@"name"] isEqualToString:@"isVisiable"]) {
        [self.opArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:[self phraseOP:dict[@"operator"]]]];
        self.text = dict[@"value"];
        self.options |= 0x02;
    }
    if ([dict[@"name"] isEqualToString:@"isClickable"]) {
        [self.opArray replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:[self phraseOP:dict[@"operator"]]]];
        self.text = dict[@"value"];
        self.options |= 0x01;
    }
}

- (NSInteger) phraseOP:(NSString *)str {
    if ([str isEqualToString:@"=="]) {
        return 1;
    } else if ([str isEqualToString:@"!="]) {
        return 2;
    } else if ([str isEqualToString:@"~="]) {
        return 3;
    } else if ([str isEqualToString:@">"]) {
        return 4;
    } else if ([str isEqualToString:@">="]) {
        return 5;
    } else if ([str isEqualToString:@"<"]) {
        return 6;
    } else if ([str isEqualToString:@"<="]) {
        return 7;
    }
    return 1;
}

@end
