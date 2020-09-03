// UIGestureRecognizer+VAPUtil.m
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
//
// Licensed under the MIT License (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

#import "UIGestureRecognizer+VAPUtil.h"
#import <objc/runtime.h>
#import "QGVAPSafeMutableArray.h"

static const int vap_block_key;

@interface _VAPUIGestureRecognizerBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _VAPUIGestureRecognizerBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@implementation UIGestureRecognizer (VAPUtil)

- (instancetype)initWithVapActionBlock:(void (^)(id sender))block {
    
    if (self = [self init]) {
        [self addVapActionBlock:block];
    }
    return self;
}

- (void)addVapActionBlock:(void (^)(id sender))block {
    
    _VAPUIGestureRecognizerBlockTarget *target = [[_VAPUIGestureRecognizerBlockTarget alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    NSMutableArray *targets = [self _vap_allUIGestureRecognizerBlockTargets];
    [targets addObject:target];
}

- (NSMutableArray *)_vap_allUIGestureRecognizerBlockTargets {
    
    NSMutableArray *targets = objc_getAssociatedObject(self, &vap_block_key);
    if (!targets) {
        targets = [QGVAPSafeMutableArray new];
        objc_setAssociatedObject(self, &vap_block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

- (void)removeAllVapActionBlocks {
    
    NSMutableArray *targets = [self _vap_allUIGestureRecognizerBlockTargets];
    [targets enumerateObjectsUsingBlock:^(id target, NSUInteger idx, BOOL *stop) {
        [self removeTarget:target action:@selector(invoke:)];
    }];
    [targets removeAllObjects];
}

@end
