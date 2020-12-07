// QGAnimatedImageBufferManager.m
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

#import "QGAnimatedImageBufferManager.h"
#import "QGVAPSafeMutableArray.h"

@interface QGAnimatedImageBufferManager() {

    QGAnimatedImageDecodeConfig *_config;       //解码配置
}

@end

@implementation QGAnimatedImageBufferManager

- (instancetype)initWithConfig:(QGAnimatedImageDecodeConfig *)config {

    if (self = [super init]) {
        _config = config;
        [self createBuffersWithConfig:config];
    }
    return self;
}

- (void)createBuffersWithConfig:(QGAnimatedImageDecodeConfig *)config {
    _buffers = [[QGVAPSafeMutableArray alloc] initWithCapacity:config.bufferCount];
}

/**
 取出指定的在缓冲区的帧，若不存在于缓冲区则返回空
 
 @param frameIndex 目标帧索引
 @return 帧数据
 */
- (QGBaseAnimatedImageFrame *)getBufferedFrame:(NSInteger)frameIndex {

    if (_buffers.count == 0) {
        //NSLog(@"fail buffer is nil");
        return nil;
    }
    NSInteger bufferIndex = frameIndex%_buffers.count;
    if (bufferIndex > _buffers.count-1) {
        //NSLog(@"fail");
        return nil;
    }
    id frame = [_buffers objectAtIndex:bufferIndex];
    if (![frame isKindOfClass:[QGBaseAnimatedImageFrame class]] || ([(QGBaseAnimatedImageFrame*)frame frameIndex] != frameIndex)) {
        return nil;
    }
    return frame;
}

- (QGBaseAnimatedImageFrame *)popVideoFrame {
    if (!_buffers.count) {
        return nil;
    }
    
    if (![_buffers.firstObject isKindOfClass:[QGBaseAnimatedImageFrame class]]) {
        return nil;
    }
    
    QGBaseAnimatedImageFrame *frame = _buffers.firstObject;
    [_buffers removeObjectAtIndex:0];
    
    return frame;
}

/**
 判断当前缓冲区是否被填满
 
 @return 只有当缓冲区所有区域都被QGBaseAnimatedImageFrame类型的数据填满才算缓冲区满
 */
- (BOOL)isBufferFull {

    __block BOOL isFull = YES;
    [_buffers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[QGBaseAnimatedImageFrame class]]) {
            isFull = NO;
            *stop = YES;
        }
    }];
    return isFull;
}

- (void)dealloc {

}

@end
