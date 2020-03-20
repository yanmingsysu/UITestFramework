//
//  IOHIDEvent+Additions.h
//  frameworkDev
//
//  Created by yanming.sysu on 2019/11/18.
//  Copyright © 2019 Bytedance. All rights reserved.
//

#import <CoreFoundation/CFBase.h>

typedef struct __IOHIDEvent * IOHIDEventRef;
IOHIDEventRef BD_IOHIDEventWithTouches(NSArray *touches) CF_RETURNS_RETAINED;
