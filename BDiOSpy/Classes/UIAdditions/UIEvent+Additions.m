//
//  UIEvent+Additions.m
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import "UIEvent+Additions.h"
#import "IOHIDEvent+Additions.h"

typedef struct __GSEvent * GSEventRef;

@interface BDGSEventProxy : NSObject
{
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end

@implementation BDGSEventProxy
@end

@interface UIEvent (AdditionsMorePrivateHeaders)
- (void)_setGSEvent:(GSEventRef)event;
- (void)_setHIDEvent:(IOHIDEventRef)event;
- (void)_setTimestamp:(NSTimeInterval)timestemp;
@end

@implementation UIEvent (Additions)

- (void)setEventWithTouches:(NSArray *)touches {
    NSOperatingSystemVersion iOS8 = {8, 0, 0};
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]
        && [[NSProcessInfo new] isOperatingSystemAtLeastVersion:iOS8]) {
        [self setIOHIDEventWithTouches:touches];
    } else {
        [self setGSEventWithTouches:touches];
    }
}

- (void)setGSEventWithTouches:(NSArray *)touches
{
    UITouch *touch = touches[0];
    CGPoint location = [touch locationInView:touch.window];
    BDGSEventProxy *gsEventProxy = [[BDGSEventProxy alloc] init];
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0;
    gsEventProxy->sizeY = 1.0;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;
    
    [self _setGSEvent:(GSEventRef)gsEventProxy];
    
    [self _setTimestamp:(((UITouch*)touches[0]).timestamp)];
}

- (void)setIOHIDEventWithTouches:(NSArray *)touches {
    IOHIDEventRef event = BD_IOHIDEventWithTouches(touches);
    [self _setHIDEvent:event];
    CFRelease(event);
}

@end
