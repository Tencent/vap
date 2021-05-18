// QGBaseDecoder.m
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

#import "QGBaseDecoder.h"
#import "QGAnimatedImageDecodeThreadPool.h"

NSString* kQGVAPDecoderSeekStart = @"kQGVAPDecoderSeekStart";
NSString* kQGVAPDecoderSeekFinish = @"kQGVAPDecoderSeekFinish";

@interface QGBaseDecoder() {

    QGBaseDFileInfo *_fileInfo;
}

@end

@implementation QGBaseDecoder

- (instancetype)initWith:(QGBaseDFileInfo *)fileInfo error:(NSError **)error {
    
    if (self = [super init]) {
        _currentDecodeFrame = -1;
        _fileInfo = fileInfo;
        _fileInfo.occupiedCount ++;
    }
    return self;
}

- (QGBaseDFileInfo *)fileInfo {
    
    return _fileInfo;
}

/**
 由具体子类实现
 该方法在decodeframe方法即将被调用时调用，如果返回YES则停止解码工作
 
 @param nextFrameIndex 将要解码的帧索引
 @return 是否需要继续解码
 */
- (BOOL)shouldStopDecode:(NSInteger)nextFrameIndex {
    // No implementation here. Meant to be overriden in subclass.
    return NO;
}

- (BOOL)isFrameIndexBeyondEnd:(NSInteger)frameIndex {
    
    return NO;
}

/**
 在专用线程内解码指定帧并放入对应的缓冲区内
 
 @param frameIndex 帧索引
 @param buffers 缓冲
 */
- (void)decodeFrame:(NSInteger)frameIndex buffers:(NSMutableArray *)buffers {
    // No implementation here. Meant to be overriden in subclass.
}

@end
