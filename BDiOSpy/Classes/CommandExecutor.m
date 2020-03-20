//
//  CommandExecutor.m
//  BDiOSpy
//
//  Created by yanming.sysu on 2020/1/16.
//

#import "CommandExecutor.h"
#import "UIInteraction.h"
#import "Compact.h"
#import "ViewProperties.h"
#import "UIPhraser.h"
#import "JsonError.h"
#import "UIAdditions/UIResponder+Additions.h"
#import "UIAdditions/UIView+Addtions.h"
#import "HighlightView.h"
#import <pthread.h>

@implementation CommandExecutor

+ (instancetype)shareExecutor {
    static CommandExecutor *_shareExecutor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareExecutor = [[CommandExecutor alloc] init];
    });
    return _shareExecutor;
}

- (instancetype)init {
    if ([super init]) {
        self.viewArray = [[NSMutableArray alloc] init];
        self.resViewArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Get Property Cmd Exec

- (id) getChildrenExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if (view.subviews.count == 0 || !view.subviews) {
        return @{
            JSON_ID,
            @"result":@[],
        };
    }
    return @{
        JSON_ID,
        @"result":[self convertViewArrayToIDArray:view.subviews],
    };
}

- (id) getParentExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    return @{
        JSON_ID,
        @"result":[NSString stringWithFormat:@"%tu",[[view superview] bd_responderPath].hash],
    };
}

- (id) getTextExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    NSMutableString *str = nil;
    if (![view respondsToSelector:NSSelectorFromString(@"text")]) {
        return @{
            JSON_ID,
            @"result":@"",
        };
    }
    if ([view valueForKey:@"text"]) {
        str = [view valueForKey:@"text"];
    }
    if (!str) {
        return @{
            JSON_ID,
            @"result":@"",
        };
    }
    return @{
        JSON_ID,
        @"result":str,
    };
}

- (id) setTextExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if ([view respondsToSelector:NSSelectorFromString(@"text")]) {
        dispatch_main(^{
            [view setValue:dict[@"params"][@"text"] forKey:@"text"];
        });
    }
    return @{
        JSON_ID,
        @"result":@YES,
    };
}

- (id) getTypeExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    return @{
        JSON_ID,
        @"result":NSStringFromClass([view class]),
    };
}

- (id) isCheckedExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if (![view respondsToSelector:NSSelectorFromString(@"selected")]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no checked property",NSStringFromClass([view class])],
            },
        };
    }
    return @{
        JSON_ID,
        @"result":[view valueForKey:@"selected"],
    };
}

- (id) isEnabledExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if (![view respondsToSelector:NSSelectorFromString(@"enabled")]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no enabled property",NSStringFromClass([view class])],
            },
        };
    }
    return @{
        JSON_ID,
        @"result":[view valueForKey:@"enabled"],
    };
}

- (id) isClickableExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if ([view isClickable]) {
        return @{
            JSON_ID,
            @"result":@YES,
        };
    } else {
        return @{
            JSON_ID,
            @"result":@NO,
        };
    }
}

- (id) isVisibleExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if ([view isVisible]) {
        return @{
            JSON_ID,
            @"result":@YES,
        };
    } else {
        return @{
            JSON_ID,
            @"result":@NO,
        };
    }
}

- (id) getProgressExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (![view isKindOfClass:NSClassFromString(@"UIProgressView")] && ![view isKindOfClass:NSClassFromString(@"UISlider")]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no progress property",NSStringFromClass([view class])],
            },
        };
    }
    float progress = -1;
    if ([view isKindOfClass:NSClassFromString(@"UIProgressView")]) {
        if ([view respondsToSelector:NSSelectorFromString(@"progress")]) {
            if ([view valueForKey:@"progress"]) {
                progress = [[view valueForKey:@"progress"] floatValue];
            }
        }
        if (progress != -1) {
            return @{
                JSON_ID,
                @"result":@(progress * 100), //should be a int value
            };
        }
    } else if ([view isKindOfClass:NSClassFromString(@"UISlider")]) {
        if ([view respondsToSelector:NSSelectorFromString(@"value")]) {
            if ([view valueForKey:@"value"]) {
                progress = [[view valueForKey:@"value"] floatValue];
            }
        }
        if (progress != -1) {
            return @{
                JSON_ID,
                @"result":@(progress * 100), //should be a int value
            };
        }
    }
    return @{
        JSON_ID,
        @"error":@{
                @"code":@(NoPropertyMatches),
                @"message":[NSString stringWithFormat:@"%@ type : has no progress property",NSStringFromClass([view class])],
        },
    };
}

- (id) setProgressExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (![view isKindOfClass:NSClassFromString(@"UIProgressView")] && ![view isKindOfClass:NSClassFromString(@"UISlider")]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no progress property",NSStringFromClass([view class])],
            },
        };
    }
    if (!dict[@"params"][@"progress"]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(ParameterNotEnough),
                    @"message":@"Necessary params not provided: progress",
            },
        };
    }
    float progress = [dict[@"params"][@"progress"] floatValue];
    if ([view isKindOfClass:NSClassFromString(@"UIProgressView")]) {
        dispatch_main(^{
            [(UIProgressView *)view setProgress:progress / 100 animated:YES];
        });
    } else if ([view isKindOfClass:NSClassFromString(@"UISlider")]) {
        dispatch_main(^{
            [(UISlider *)view setValue:progress / 100 animated:YES];
            [(UISlider *)view sendActionsForControlEvents:UIControlEventValueChanged];
        });
    }
    return @{
        JSON_ID,
        @"result":@YES,
    };
}

- (id) getScrollInfoExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (![view isKindOfClass:NSClassFromString(@"UIScrollView")]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no scroll property",NSStringFromClass([view class])],
            },
        };
    }
    CGSize size;
    CGPoint offset;
    UIEdgeInsets *edges = NULL;
    if ([view respondsToSelector:NSSelectorFromString(@"contentSize")] && [view respondsToSelector:NSSelectorFromString(@"contentOffset")]) {
        if ([view valueForKey:@"contentSize"]) {
            size = [[view valueForKey:@"contentSize"] CGSizeValue];
        }
        if ([view valueForKey:@"contentOffset"]) {
            offset = [[view valueForKey:@"contentOffset"] CGPointValue];
        }
        if ([view valueForKey:@"adjustedContentInset"]) {
            edges = (__bridge UIEdgeInsets *)([view valueForKey:@"adjustedContentInset"]);
            NSLog(@"%@", [NSString stringWithFormat:@"%d %d %d %d",(int)edges->top,(int)edges->left,(int)edges->bottom,(int)edges->right]);
        }
    }
    if (edges != NULL) {
        return @{
            JSON_ID,
            @"result":@{
                @"start_x":@0,
                @"current_x":@((int)offset.x),
                @"end_x":@((int)size.width),
                @"scrollable_x":@((int)size.width > (int)SCREEN_WIDTH),
                @"start_y":@0,
                @"current_y":@((int)offset.y + (int)edges->right),
                @"end_y":@((int)size.height),
                @"scrollable_y":@((int)size.height > (int)SCREEN_HEIGHT),
            },
        };
    } else {
        return @{
            JSON_ID,
            @"result":@{
                @"start_x":@0,
                @"current_x":@((int)offset.x),
                @"end_x":@((int)size.width),
                @"scrollable_x":@((int)size.width > (int)SCREEN_WIDTH),
                @"start_y":@0,
                @"current_y":@((int)offset.y),
                @"end_y":@((int)size.height),
                @"scrollable_y":@((int)size.height > (int)SCREEN_HEIGHT),
            },
        };
    }
}


- (id) scrollExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if (!(dict[@"params"][@"distance_x"] && dict[@"params"][@"distance_y"])) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(ParameterNotEnough),
                    @"message":@"necessary parameters not provided: distance_x or distance_y",
            },
        };
    }
    NSInteger x = [dict[@"params"][@"distance_x"] integerValue];
    NSInteger y = [dict[@"params"][@"distance_y"] integerValue];
    if (!([view respondsToSelector:NSSelectorFromString(@"contentSize")] && [view respondsToSelector:NSSelectorFromString(@"contentOffset")])) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no scroll property",NSStringFromClass([view class])],
            },
        };
    } else {
        NSInteger size_x = [[view valueForKey:@"contentSize"] CGSizeValue].width;
        NSInteger size_y = [[view valueForKey:@"contentSize"] CGSizeValue].height;
        if (x != 0 && view.frame.size.width == size_x) {
            return @{
                JSON_ID,
                @"error":@{
                        @"code":@(ParameterWrong),
                        @"message":@"scroll doesn't support horizontal scrolling",
                }
            };
        }
        if (y != 0 && view.frame.size.height == size_y) {
            return @{
                JSON_ID,
                @"error":@{
                        @"code":@(ParameterWrong),
                        @"message":@"scroll doesn't support vertical scrolling",
                }
            };
        }
        dispatch_main(^{
            [view dragFromPoint:view.center toPoint:CGPointMake(view.center.x - x, view.center.y - y) steps:60];
        });
    }
    return @{
        JSON_ID,
        @"result":@YES,
    };
}

- (id) scrollToEnd:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if (!(dict[@"params"][@"direction_x"] && dict[@"params"][@"direction_y"])) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(ParameterNotEnough),
                    @"message":@"necessary parameters not provided: direction_x or direction_y",
            },
        };
    }
    NSInteger x = [dict[@"params"][@"direction_x"] integerValue];
    NSInteger y = [dict[@"params"][@"direction_y"] integerValue];
    if (![view respondsToSelector:NSSelectorFromString(@"contentOffset")]) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoPropertyMatches),
                    @"message":[NSString stringWithFormat:@"%@ type : has no scroll property",NSStringFromClass([view class])],
            },
        };
    }
    NSInteger current_x = [[view valueForKey:@"contentOffset"] CGPointValue].x;
    NSInteger current_y = [[view valueForKey:@"contentOffset"] CGPointValue].y;
    NSInteger x_size = [[view valueForKey:@"contentSize"] CGSizeValue].width;
    NSInteger y_size = [[view valueForKey:@"contentSize"] CGSizeValue].height;
    if (x != 0 && view.frame.size.width == x_size) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(ParameterWrong),
                    @"message":@"scroll doesn't support horizontal scrolling",
            }
        };
    }
    if (y != 0 && view.frame.size.height == y_size) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(ParameterWrong),
                    @"message":@"scroll doesn't support vertical scrolling",
            }
        };
    }
    if (x != 0 && y != 0) {
        dispatch_main(^{
            [view setValue:[NSValue valueWithCGPoint:CGPointMake(x_size * x, y_size * y)] forKey:@"contentOffset"];
        });
    } else {
        if (x == 0) {
            dispatch_main(^{
                [view setValue:[NSValue valueWithCGPoint:CGPointMake(current_x, y_size * y)] forKey:@"contentOffset"];
            });
        }
        if (y == 0) {
            dispatch_main(^{
                [view setValue:[NSValue valueWithCGPoint:CGPointMake(x_size * x, current_y)] forKey:@"contentOffset"];
            });
        }
    }
    return @{
        JSON_ID,
        @"result":@YES,
    };
}

- (id) getRectExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    __block CGRect rect;
    dispatch_main(^{
        rect = [view convertRect:view.bounds toView:[UIApplication sharedApplication].keyWindow];
    });
    return @{
        JSON_ID,
        @"result":@{
            @"left":@(rect.origin.x),
            @"top":@(rect.origin.y),
            @"width":@(rect.size.width),
            @"height":@(rect.size.height),
        },
    };
}

- (id) getVisualRectExec:(NSDictionary *)dict {
    CGRect rect = [UIApplication sharedApplication].windows[0].frame;
    return @{
        JSON_ID,
        @"result":@{
            @"left":@(rect.origin.x),
            @"top":@(rect.origin.y),
            @"width":@(rect.size.width),
            @"height":@(rect.size.height),
        },
    };
}

- (id) getElementInfoExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    if ([view respondsToSelector:NSSelectorFromString(@"text")]) {
        return @{
            JSON_ID,
            @"result":@{
                @"path":[view resPath],
                @"label":@"",
                @"text":[self getTextExec:dict][@"result"],
                @"visible":[self isVisibleExec:dict][@"result"],
                @"rect":[self getRectExec:dict][@"result"],
            },
        };
    }
    return @{
        JSON_ID,
        @"result":@{
            @"path":[view resPath],
            @"label":@"",
            @"text":@"",
            @"visible":[self isVisibleExec:dict][@"result"],
            @"rect":[self getRectExec:dict][@"result"],
        },
    };
}

- (id) getSelectedIndexExec:(NSDictionary *)dict {
    if (!dict[@"params"][@"elem_id"]) {
        return ERROR_JSON;
    }
    UIView *view = [self findViewFromID:dict[@"params"][@"elem_id"]];
    if (!view) {
        return @{
            JSON_ID,
            @"error":@{
                    @"code":@(NoElementMatches),
                    @"message":NOVIEW,
            },
        };
    }
    NSInteger viewCount = -1;
    if ([view isKindOfClass:NSClassFromString(@"UITabBar")]) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UIButton")]) {
                viewCount++;
            }
            if ([((UIButton *)subview).currentAttributedTitle.string isEqualToString:@"selected"]) {
                break;
            }
        }
        return @{
            JSON_ID,
            @"result":@(viewCount),
        };
    }
    return @{
        JSON_ID,
        @"error":@{
                @"code":@(NoPropertyMatches),
                @"message":[NSString stringWithFormat:@"%@ type : has no index property",NSStringFromClass([view class])],
        },
    };
}

- (id) highLightExec:(NSDictionary *)dict {
    if (dict[@"params"][@"rect"][@"left"] && dict[@"params"][@"rect"][@"top"] && dict[@"params"][@"rect"][@"width"] && dict[@"params"][@"rect"][@"height"]) {
        NSInteger left = [dict[@"params"][@"rect"][@"left"] integerValue];
        NSInteger top = [dict[@"params"][@"rect"][@"top"] integerValue];
        NSInteger width = [dict[@"params"][@"rect"][@"width"] integerValue];
        NSInteger height = [dict[@"params"][@"rect"][@"height"] integerValue];
        dispatch_main(^{
            HighlightView *view = [[HighlightView alloc] initWithFrame:CGRectMake(left, top, width, height)];
            view.layer.borderWidth = 2;
            view.layer.borderColor = [[UIColor redColor] CGColor];
            //[view.layer setZPosition:INT_MAX];
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            [view.layer setNeedsDisplay];
            [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        });
        return @{
            JSON_ID,
            @"result":@YES,
        };
    }
    return @{
        JSON_ID,
        @"error":@{
                @"code":@(ParameterNotEnough),
                @"message":@"necessary parameters not provided: left or top or width or height",
        },
    };
}

- (id) hideHighLightExec:(NSDictionary *)dict {
    if (dict[@"params"][@"rect"][@"left"] && dict[@"params"][@"rect"][@"top"] && dict[@"params"][@"rect"][@"width"] && dict[@"params"][@"rect"][@"height"]) {
        NSInteger left = [dict[@"params"][@"rect"][@"left"] integerValue];
        NSInteger top = [dict[@"params"][@"rect"][@"top"] integerValue];
        NSInteger width = [dict[@"params"][@"rect"][@"width"] integerValue];
        NSInteger height = [dict[@"params"][@"rect"][@"height"] integerValue];
        __block NSMutableDictionary *resDict = [[NSMutableDictionary alloc] init];
        dispatch_main((^{
            for (UIView *view in [UIApplication sharedApplication].windows[0].subviews) {
                if (view.frame.size.width == width
                    && view.frame.size.height == height
                    && view.frame.origin.x == left
                    && view.frame.origin.y == top
                    && [NSStringFromClass([view class]) isEqualToString:@"HighlightView"]) {
                    [view removeFromSuperview];
                    NSDictionary *tmpDict = @{
                        JSON_ID,
                        @"result":@YES,
                    };
                    [resDict addEntriesFromDictionary:tmpDict];
                    break;
                }
            }
        }));
        if ([resDict count] == 0) {
            return @{
                JSON_ID,
                @"error":@{
                        @"code":@(ParameterWrong),
                        @"message":@"paramters wrong:can't find highlight",
                },
            };
        } else {
            return resDict;
        }
    }
    return @{
        JSON_ID,
        @"error":@{
                @"code":@(ParameterNotEnough),
                @"message":@"necessary parameters no provided: left or top or width or height",
        },
    };
}

- (id) getUITreeExec:(NSDictionary *)dict {
    if (dict[@"params"][@"root_id"] && dict[@"params"][@"root_id"] != [NSNull null]) {
        UIView *view = [self findViewFromID:dict[@"params"][@"root_id"]];
        if (view == nil) {
            return @{
                JSON_ID,
                @"error":@{
                    @"code":@(ParameterWrong),
                    @"message":@"paramters wrong:can't find view for this id",
                },
            };
        }
        return @{
            JSON_ID,
            @"result":[self elemsInfo:@[view]],
        };
    } else {
        return @{
            JSON_ID,
            @"result":[self elemsInfo:@[[UIApplication sharedApplication].keyWindow]],
        };
    }
}

#pragma mark Gesture Cmd Exec

- (id) clickExec:(NSDictionary *)dict {
    if (dict[@"params"][@"x"] && dict[@"params"][@"y"]) {
        float x = [dict[@"params"][@"x"] floatValue];
        float y = [dict[@"params"][@"y"] floatValue];
        [[UIInteraction shareInteraction]tapScreenAtX:x andY:y];
         return @{
            JSON_ID,
            @"result":@YES,
        };
    } else {
        return ERROR_JSON;
    }
}

- (id) longClickExec:(NSDictionary *)dict {
    if (dict[@"params"][@"x"] && dict[@"params"][@"y"] && dict[@"params"][@"duration"]) {
        float x = [dict[@"params"][@"x"] floatValue];
        float y = [dict[@"params"][@"y"] floatValue];
        float duration = [dict[@"params"][@"duration"] floatValue];
        [[UIInteraction shareInteraction]longPressScreenAtX:x andY:y withDuration:duration];
         return @{
            JSON_ID,
            @"result":@YES,
        };
    } else {
        return ERROR_JSON;
    }
}

- (id) doubleClickExec:(NSDictionary *)dict {
    if (dict[@"params"][@"x"] && dict[@"params"][@"y"]) {
        float x = [dict[@"params"][@"x"] floatValue];
        float y = [dict[@"params"][@"y"] floatValue];
        [[UIInteraction shareInteraction]tapScreenAtX:x andY:y];
         return @{
            JSON_ID,
            @"result":@YES,
        };
    } else {
        return ERROR_JSON;
    }
}

- (id) dragExec:(NSDictionary *)dict {
    if (dict[@"params"][@"from_x"]
        && dict[@"params"][@"from_y"]
        && dict[@"params"][@"to_x"]
        && dict[@"params"][@"to_y"]
        && dict[@"params"][@"duration"]
        && dict[@"params"][@"count"]) {
        float from_x = [dict[@"params"][@"from_x"] floatValue];
        float from_y = [dict[@"params"][@"from_y"] floatValue];
        float to_x = [dict[@"params"][@"to_x"] floatValue];
        float to_y = [dict[@"params"][@"to_y"] floatValue];
        if (dict[@"params"][@"duration"] && dict[@"params"][@"duration"] != [NSNull null]) {
            [[UIInteraction shareInteraction] dragStartAtX:from_x andY:from_y endAtX:to_x andY:to_y withDuration:[dict[@"params"][@"duration"] integerValue]];
             return @{
                JSON_ID,
                @"result":@YES,
            };
        } else {
            [[UIInteraction shareInteraction] dragStartAtX:from_x andY:from_y endAtX:to_x andY:to_y];
             return @{
                JSON_ID,
                @"result":@YES,
            };
        }
    } else {
        return ERROR_JSON;
    }
}

- (id) elementSearchExec:(NSDictionary *)dict {
    __block UIView *rootView = nil;
    if ([dict[@"params"] objectForKey:@"root_id"] && [dict[@"params"] objectForKey:@"root_id"] != [NSNull null]) {
//        NSArray<UIView *> *viewArray = [[UIPhraser sharePhraser] allViewsInHierarchy];
//        for (UIView *view in viewArray) {
//            if ([[NSString stringWithFormat:@"%lu",[view bd_responderPath].hash] isEqualToString:dict[@"params"][@"root_id"]]) {
//                rootView = view;
//                break;
//            }
//        }
        rootView = [self findViewFromID:dict[@"params"][@"root_id"]];
    } else {
        dispatch_main(^{
            rootView = [UIApplication sharedApplication].keyWindow;
        });
    }
    NSArray *filterArray = dict[@"params"][@"path"];
    __block NSMutableArray<UIView *> *views = [[NSMutableArray alloc] init];
    if (rootView != nil) {
        views = [NSMutableArray arrayWithObject:rootView];
    } else {
        dispatch_main(^{
            views = [NSMutableArray arrayWithObject:[UIApplication sharedApplication].keyWindow];
        });
    }
    for (NSInteger num = 0; num < [filterArray count]; ++num) {
        if (filterArray[num][@"predicates"] == @[]) {
            if (filterArray[num][@"index"] == [NSNull null]) {
                return @{
                    JSON_ID,
                    @"error":@{
                            @"code":@(ParameterWrong),
                            @"message":@"index can't be null here",
                    },
                };
            } else {
                NSArray <UIView *> *allviews = [[UIPhraser sharePhraser] allViewsInHierarchy];
                NSInteger index = [filterArray[num][@"index"] integerValue];
                if (index < 0) {
                    if (-index < allviews.count) {
                        UIView *view = allviews[allviews.count + index];
                        return @{
                            JSON_ID,
                            @"result":[self convertViewArrayToIDArray:[NSArray arrayWithObject:view]],
                        };
                    } else {
                        return @{
                            JSON_ID,
                            @"result":@[],
                        };
                    }
                } else {
                    if (index < allviews.count) {
                        UIView *view = allviews[index];
                        return @{
                            JSON_ID,
                            @"result":[self convertViewArrayToIDArray:[NSArray arrayWithObject:view]],
                        };
                    } else {
                        return @{
                            JSON_ID,
                            @"result":@[],
                        };
                    }
                }
            }
        }
        NSMutableDictionary *mutableDict = [filterArray[num] mutableCopy];
        if (filterArray[num][@"depth"] == [NSNull null]) {
            [mutableDict setObject:[NSString stringWithFormat:@"%d",INT_MAX] forKey:@"depth"];
        }
        if (filterArray[num][@"index"] == [NSNull null]) {
            [mutableDict setObject:[NSString stringWithFormat:@"%d",INT_MAX] forKey:@"index"];
        }
        NSArray<NSString *> *viewIDArray = [self findElementWithPredicates:mutableDict[@"predicates"] withRootView:views andDepth:[mutableDict[@"depth"] integerValue] andIndex:[mutableDict[@"index"] integerValue]];
        if (viewIDArray.count == 0) {
            return @{
                JSON_ID,
                @"result":@[],
            };
        }
        views = [[self findViewArrayFromIDArray:viewIDArray] mutableCopy];
        [self.viewArray removeAllObjects];
        for (UIView *tmpView in views) {
            [self.viewArray addObject:[[ViewNode alloc] initWithView:tmpView]];
        }
    }
    [self.resViewArray removeAllObjects];
    for (UIView *view in views) {
        [self.resViewArray addObject:[[ViewNode alloc] initWithView:view]];
    }
    NSArray<NSString *> *viewResult = [self convertViewArrayToIDArray:views];
    return @{
        JSON_ID,
        @"result":viewResult,
    };
}

- (id) killProcessExec:(NSDictionary *)dict {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self exitApplication];
    });
    return @{
        JSON_ID,
        @"result":@(YES),
    };
}


- (void)exitApplication
{
    UIWindow *window = [[UIApplication sharedApplication] windows][0];

    [UIView animateWithDuration:0.4f animations:^{
        CGAffineTransform curent =  window.transform;
        CGAffineTransform scale = CGAffineTransformScale(curent, 0.1,0.1);
        [window setTransform:scale];
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

#pragma mark Inline Methods

- (NSArray<NSString *> *)convertViewArrayToIDArray:(NSArray<UIView *> *)viewArray {
    NSMutableArray<NSString *> *idArray = [[NSMutableArray alloc] init];
    for (UIView *view in viewArray) {
        [idArray addObject:[NSString stringWithFormat:@"%tu",[view bd_responderPath].hash]];
    }
    return [idArray copy];
}

- (UIView *)findViewFromID:(NSString *)str {
    for (ViewNode *node in self.viewArray) {
        if ([node.hashString isEqualToString:str]) {
            if ([NSString stringWithFormat:@"%tu",[node.view bd_responderPath].hash]){
                return node.view;
            }
        }
    }
    for (ViewNode *node in self.resViewArray) {
        if ([node.hashString isEqualToString:str]) {
            if ([NSString stringWithFormat:@"%tu",[node.view bd_responderPath].hash]){
                return node.view;
            }
        }
    }
    NSArray<UIView *> *allViews = [[UIPhraser sharePhraser] allViewsInHierarchy];
    UIView *viewRes = nil;
    for (UIView *view in allViews) {
        if ([[NSString stringWithFormat:@"%tu",[view bd_responderPath].hash] isEqualToString:str]) {
            viewRes = view;
        }
    }
    return viewRes;
}

- (NSArray<UIView *> *)findViewArrayFromIDArray:(NSArray<NSString *> *)idArray {
    NSMutableArray<UIView *> *viewArray = [[NSMutableArray alloc] init];
    NSArray<UIView *> *allViews = [[UIPhraser sharePhraser] allViewsInHierarchy];
    for (NSString *viewID in idArray) {
        for (UIView *view in allViews) {
            if ([[NSString stringWithFormat:@"%tu",[view bd_responderPath].hash] isEqualToString:viewID]) {
                [viewArray addObject:view];
                break;
            }
        }
    }
    return [viewArray copy];
}

- (NSArray<NSString *> *) findElementWithPredicates:(NSArray *)predicatesArray
                                        withRootView:(NSArray<UIView *> *)rootViewArray
                                            andDepth:(NSInteger)depth
                                            andIndex:(NSInteger)index {
    if (!rootViewArray) {
        rootViewArray = [NSArray arrayWithObject:[UIApplication sharedApplication].windows[0]];
    }
    NSMutableArray<NSString *> *elementArray = [[NSMutableArray alloc] init];
    for (UIView *rootView in rootViewArray) {
        ViewProperties *filter = [[ViewProperties alloc] init];
        for (NSDictionary *strArray in predicatesArray) {
            [filter addArrayProperties:strArray];
        }
        NSInteger viewCount = 0;
        NSArray<UIView *> *viewArray = [[UIPhraser sharePhraser] allViewsInHierarchy];
        for (UIView *view in viewArray) {
            if ([self depthForView:view toRootView:rootView] <= depth) {
                if ([filter paramsAccordance:[[ViewProperties alloc] initWithView:view]] && [self view:view isSubviewOfView:rootView]) {
                    [elementArray addObject:[NSString stringWithFormat:@"%tu",[view bd_responderPath].hash]];
                    viewCount++;
                }
            }
        }
    }
    if (index == INT_MAX) {
        return elementArray;
    }
    else if (index < 0) {
        if (-index < elementArray.count) {
            return [NSMutableArray arrayWithObject:[elementArray objectAtIndex:elementArray.count + index]];
        } else {
            return [[NSMutableArray alloc] init];
        }
    } else {
        if (index < elementArray.count) {
            return [NSMutableArray arrayWithObject:[elementArray objectAtIndex:index]];
        } else {
            return [[NSMutableArray alloc] init];
        }
    }
}

- (BOOL) view:(UIView *)view isSubviewOfView:(UIView *) parent {
    while(true) {
        if (view == parent) {
            return true;
        }
        if (view == [UIApplication sharedApplication].keyWindow) {
            return false;
        }
        view = view.superview;
    }
    return false;
}

- (NSInteger) depthForView:(UIView *)view toRootView:(UIView *)rootView {
    __block NSInteger distance = 0;
    __block UIView *viewSelf = view;
    dispatch_main(^{
        while (viewSelf != rootView) {
            if ([[UIApplication sharedApplication].windows containsObject:(UIWindow *)viewSelf]) {
                break;
            }
            viewSelf = [viewSelf superview];
            distance ++;
        }
    });
    return distance;
}

- (BOOL) viewArrayContainID:(NSString *)str {
    for (ViewNode *node in self.viewArray) {
        if ([node.hashString isEqualToString:str]) {
            return true;
        }
    }
    return false;
}

- (NSArray<NSDictionary *> *) elemsInfo:(NSArray<UIView *> *)views {
    if (views == nil || views.count == 0) {
        return @[];
    }
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    for (UIView *view in views) {
        NSDictionary *dict = @{
            @"elem_id":[NSString stringWithFormat:@"%tu",[view bd_responderPath].hash],
            @"elem_info":@{
                @"path":[view resPath],
                @"label":@"",
                @"text":[view getElemText],
                @"visible":@([view isVisible]),
                @"rect":[view getRect],
            },
            @"children":[self elemsInfo:view.subviews],
        };
        [dictArray addObject:dict];
    }
    return dictArray;
}

@end
