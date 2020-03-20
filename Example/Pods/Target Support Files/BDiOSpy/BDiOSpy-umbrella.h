#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CommandExecutor.h"
#import "Compact.h"
#import "JsonError.h"
#import "JsonPhraser.h"
#import "JsonServer.h"
#import "CGGeometry+Additions.h"
#import "HighlightView.h"
#import "IOHIDEvent+Additions.h"
#import "UIApplication+Additions.h"
#import "UIEvent+Additions.h"
#import "UIResponder+Additions.h"
#import "UITouch+Additions.h"
#import "UIView+Addtions.h"
#import "UIAutomationHelper.h"
#import "UIInteraction.h"
#import "UIPhraser.h"
#import "ViewNode.h"
#import "ViewProperties.h"

FOUNDATION_EXPORT double BDiOSpyVersionNumber;
FOUNDATION_EXPORT const unsigned char BDiOSpyVersionString[];

