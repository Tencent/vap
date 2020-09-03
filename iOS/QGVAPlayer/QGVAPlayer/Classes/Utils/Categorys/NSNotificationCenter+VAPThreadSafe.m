// NSNotificationCenter+ThreadSafe.m
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

#import "NSNotificationCenter+VAPThreadSafe.h"
#import "QGVAPSafeMutableDictionary.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface NSObject (SafeNotification)

@property (nonatomic, strong) NSOperationQueue *notificationOperationQueue;

@end

@implementation NSObject (SafeNotification)

- (NSOperationQueue *)notificationOperationQueue {
    @synchronized (self) {
        NSOperationQueue *queue = objc_getAssociatedObject(self, @"notificationOperationQueue");
        if (!queue) {
            queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
            self.notificationOperationQueue = queue;
        }
        return queue;
    }
}

- (void)setNotificationOperationQueue:(NSOperationQueue *)notificationOperationQueue {
    @synchronized (self) {
        objc_setAssociatedObject(self, @"notificationOperationQueue", notificationOperationQueue, OBJC_ASSOCIATION_RETAIN);
    }
}

@end

@implementation NSNotificationCenter (VAPThreadSafe)

- (void)hwd_addSafeObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    
    double sysVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];;
    if (sysVersion >= 9.0) {
        return [self addObserver:observer selector:aSelector name:aName object:anObject];
    }
    __weak typeof(observer) weakObserver = observer;
    __block NSObject *blockObserver = [self addObserverForName:aName object:anObject queue:aName.notificationOperationQueue usingBlock:^(NSNotification * _Nonnull note) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        __strong __typeof__(weakObserver) strongObserver = weakObserver;
        [strongObserver performSelector:aSelector withObject:note];
#pragma clang diagnostic pop
        if (!weakObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:blockObserver];
            blockObserver = nil;
        }
    }];
}
- (void)hwd_addWeakObserver:( id)Observer name:(NSNotificationName)aName usingBlock:(void (^)(NSNotification *note,id observer))block{
    __weak id weakObserver=Observer;
    __block NSObject *blockObserver = [self addObserverForName:aName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
         __strong id strongObserver = weakObserver;
        if(!weakObserver ){
            [[NSNotificationCenter defaultCenter] removeObserver:blockObserver];
            blockObserver = nil;
        }else{
            block(note,strongObserver);
        }
    
    }];
}
- (void)hwd_addSafeObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject queue:(NSOperationQueue *)queue {

    aName.notificationOperationQueue = queue;
    [self hwd_addSafeObserver:observer selector:aSelector name:aName object:anObject];
}

@end
