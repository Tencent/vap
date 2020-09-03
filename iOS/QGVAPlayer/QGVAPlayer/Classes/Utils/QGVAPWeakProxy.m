// QGVAPWeakProxy.m
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

#import "QGVAPWeakProxy.h"

@implementation QGVAPWeakProxy {
    __weak id _target;
}

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        _target = target;
    }
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[QGVAPWeakProxy alloc] initWithTarget:target];
}

// 1. 快速消息转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _target;
}

// 2. 如果<1>返回nil，到标准消息转发处理，如果不处理为Crash：unrecognized selector. 这里我们直接返回空指针地址.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    void *null = NULL;
    [anInvocation setReturnValue:&null];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

@end
