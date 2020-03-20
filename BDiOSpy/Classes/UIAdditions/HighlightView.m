//
//  HighlightView.m
//  BDiOSpy
//
//  Created by yanming.sysu on 2020/2/13.
//

#import "HighlightView.h"
#import "Compact.h"
#import "UIApplication+Additions.h"

@implementation HighlightView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return  nil;
    }
    return [super hitTest:point withEvent:event];
}

@end
