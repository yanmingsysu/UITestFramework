//
//  CommandExecutor.h
//  BDiOSpy
//
//  Created by yanming.sysu on 2020/1/16.
//

#import <Foundation/Foundation.h>
#import "ViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommandExecutor : NSObject

@property ()NSMutableArray<ViewNode *> *viewArray; //存放被调用的id的viewnode，不会清空
@property ()NSMutableArray<ViewNode *> *resViewArray; //存放查找结果的id的viewnode，会被清空

+ (instancetype)shareExecutor;

- (BOOL) viewArrayContainID:(NSString *)str;

- (UIView *)findViewFromID:(NSString *)str;

- (id) clickExec:(NSDictionary *)dict;

- (id) longClickExec:(NSDictionary *)dict;

- (id) doubleClickExec:(NSDictionary *)dict;

- (id) dragExec:(NSDictionary *)dict;

- (id) elementSearchExec:(NSDictionary *)dict;

- (id) getChildrenExec:(NSDictionary *)dict;

- (id) getParentExec:(NSDictionary *)dict;

- (id) getTextExec:(NSDictionary *)dict;

- (id) setTextExec:(NSDictionary *)dict;

- (id) getTypeExec:(NSDictionary *)dict;

- (id) isClickableExec:(NSDictionary *)dict;

- (id) isVisibleExec:(NSDictionary *)dict;

- (id) isCheckedExec:(NSDictionary *)dict;

- (id) isEnabledExec:(NSDictionary *)dict;

- (id) getProgressExec:(NSDictionary *)dict;

- (id) setProgressExec:(NSDictionary *)dict;

- (id) getScrollInfoExec:(NSDictionary *)dict;

- (id) scrollExec:(NSDictionary *)dict;

- (id) scrollToEnd:(NSDictionary *)dict;

- (id) getRectExec:(NSDictionary *)dict;

- (id) getElementInfoExec:(NSDictionary *)dict;

- (id) getSelectedIndexExec:(NSDictionary *)dict;

- (id) highLightExec:(NSDictionary *)dict;

- (id) hideHighLightExec:(NSDictionary *)dict;

- (id) getVisualRectExec:(NSDictionary *)dict;

- (id) getUITreeExec:(NSDictionary *)dict;

- (id) killProcessExec:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
