//
//  JsonPhraser.m
//  testfrank
//
//  Created by yanming.sysu on 2019/11/11.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import "JsonPhraser.h"
#import "ViewNode.h"
#import "CommandExecutor.h"
#import "Compact.h"

@implementation JsonPhraser

- (id)phraseCommandFromJson:(NSDictionary *)dict {
    if (!dict[@"method"]) {
        return ERROR_JSON;
    }
    // 当当前id未注册，这里注册避免id发生变动的情况，顺便加速id查找
    if (dict[@"params"][@"elem_id"] && dict[@"params"][@"elem_id"] != [NSNull null]) {
        if (![[CommandExecutor shareExecutor] viewArrayContainID:dict[@"params"][@"elem_id"]]) {
            UIView *view = [[CommandExecutor shareExecutor] findViewFromID:dict[@"params"][@"elem_id"]];
            [[CommandExecutor shareExecutor].viewArray addObject:[[ViewNode alloc] initWithView:view]];
        }
    }
    NSString *cmd  = dict[@"method"];
    if ([cmd isEqualToString:@"click"]) {
        return [[CommandExecutor shareExecutor] clickExec:dict];
    } else if ([cmd isEqualToString:@"drag"]) {
        return [[CommandExecutor shareExecutor] dragExec:dict];
    } else if ([cmd isEqualToString:@"long_click"]) {
        return [[CommandExecutor shareExecutor] longClickExec:dict];
    } else if ([cmd isEqualToString:@"double_click"]) {
        return [[CommandExecutor shareExecutor] doubleClickExec:dict];
    } else if ([cmd isEqualToString:@"get_element_ids"]) {
        return [[CommandExecutor shareExecutor] elementSearchExec:dict];
    } else if ([cmd isEqualToString:@"get_children"]) {
        return [[CommandExecutor shareExecutor] getChildrenExec:dict];
    } else if ([cmd isEqualToString:@"get_parent"]) {
        return [[CommandExecutor shareExecutor] getParentExec:dict];
    } else if ([cmd isEqualToString:@"get_text"]) {
        return [[CommandExecutor shareExecutor] getTextExec:dict];
    } else if ([cmd isEqualToString:@"get_type"]) {
        return [[CommandExecutor shareExecutor] getTypeExec:dict];
    } else if ([cmd isEqualToString:@"is_clickable"]) {
        return [[CommandExecutor shareExecutor] isClickableExec:dict];
    } else if ([cmd isEqualToString:@"is_visible"]) {
        return [[CommandExecutor shareExecutor] isVisibleExec:dict];
    } else if ([cmd isEqualToString:@"set_text"]) {
        return [[CommandExecutor shareExecutor] setTextExec:dict];
    } else if ([cmd isEqualToString:@"is_checked"]) {
        return [[CommandExecutor shareExecutor] isCheckedExec:dict];
    } else if ([cmd isEqualToString:@"is_enabled"]) {
       return [[CommandExecutor shareExecutor] isEnabledExec:dict];
    } else if ([cmd isEqualToString:@"get_progress"]) {
        return [[CommandExecutor shareExecutor] getProgressExec:dict];
    } else if ([cmd isEqualToString:@"set_progress"]) {
        return [[CommandExecutor shareExecutor] setProgressExec:dict];
    } else if ([cmd isEqualToString:@"get_scroll_info"]) {
        return [[CommandExecutor shareExecutor] getScrollInfoExec:dict];
    } else if ([cmd isEqualToString:@"scroll"]) {
        return [[CommandExecutor shareExecutor] scrollExec:dict];
    } else if ([cmd isEqualToString:@"scroll_to_end"]) {
        return [[CommandExecutor shareExecutor] scrollToEnd:dict];
    } else if ([cmd isEqualToString:@"get_rect"]) {
        return [[CommandExecutor shareExecutor] getRectExec:dict];
    } else if ([cmd isEqualToString:@"get_element_info"]) {
        return [[CommandExecutor shareExecutor] getElementInfoExec:dict];
    } else if ([cmd isEqualToString:@"get_selected_index"]) {
        return [[CommandExecutor shareExecutor] getSelectedIndexExec:dict];
    } else if ([cmd isEqualToString:@"highlight"]) {
        return [[CommandExecutor shareExecutor] highLightExec:dict];
    } else if ([cmd isEqualToString:@"hide_highlight"]) {
        return [[CommandExecutor shareExecutor] hideHighLightExec:dict];
    } else if ([cmd isEqualToString:@"get_visual_rect"]) {
        return [[CommandExecutor shareExecutor] getVisualRectExec:dict];
    } else if ([cmd isEqualToString:@"get_ui_tree"]) {
        return [[CommandExecutor shareExecutor] getUITreeExec:dict];
    } else if ([cmd isEqualToString:@"kill_process"]) {
        return [[CommandExecutor shareExecutor] killProcessExec:dict];
    }
    return ERROR_JSON;
}



# pragma mark Test Method

- (JsonCommand)phraseCommandFromDict:(NSDictionary *)dict {
    if (dict[@"Cmd"] != NULL) {
        NSInteger cmd = [dict[@"Cmd"] intValue];
        switch (cmd) {
            case 1:
                return Hello;
            case 2:
                return GetUITree;
            case 3:
                return Click;
            case 4:
                return LongPress;
            case 5:
                return TwoFingerTap;
            case 6:
                return Drag;
            case 7:
                return GetViewList;
            case 8:
                return ViewGesture;
            case 9:
                return ClickAlert;
            default:
                return Error;
        }
    } else {
        return Error;
    }
}

- (NSDictionary *)jsonCmdPhrase:(NSData *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dict;
}

#pragma mark -json struct

- (NSString *) jsonWithViewNode:(ViewNode *)rootView {
    return [self jsonStringWithDictionary:[self jsonWithRootViewNodes:rootView] WithPrettyPrint:YES];
}

- (NSDictionary *)jsonWithRootViewNodes:(ViewNode *)rootView {
    NSMutableDictionary *jsonWithViews = [[NSMutableDictionary alloc] init];
    NSUInteger serialNumber = 0;
    if (rootView.subviews.count > 0) {
        for (ViewNode *viewNode in rootView.subviews) {
            [jsonWithViews setObject:[self jsonWithViewNodes:viewNode andNums:0] forKey:[NSString stringWithFormat:@"%lu",(unsigned long)serialNumber]];
            serialNumber++;
        }
    }
    return jsonWithViews;
}

- (NSDictionary *) jsonWithViewNodes:(ViewNode *)viewNode andNums:(NSUInteger)serialNumber {
    if (viewNode.view != NULL) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NSStringFromClass([viewNode.view class]), [NSString stringWithFormat:@"%luView",serialNumber], NSStringFromCGRect(viewNode.view.frame), [NSString stringWithFormat:@"%luFrame",serialNumber], nil];
        if (viewNode.subviews.count > 0) {
            for (ViewNode *node in viewNode.subviews) {
                [dict setObject:[self jsonWithViewNodes:node andNums:serialNumber] forKey:[NSString stringWithFormat:@"%luSubviews",serialNumber]];
                serialNumber++;
            }
        }
        return [dict copy];
    }
    return nil;
}

-(NSString*) jsonStringWithDictionary:(NSDictionary *)dict WithPrettyPrint:(BOOL)prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                  options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                    error:&error];

    if (! jsonData) {
       NSLog(@"%s: error: %@", __func__, error.localizedDescription);
       return @"{}";
    } else {
       return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}



@end
