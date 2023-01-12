// QGBaseDecoder.h
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

#import <Foundation/Foundation.h>
#import "QGAnimatedImageDecodeThread.h"
#import "QGBaseDFileInfo.h"

extern NSString* kQGVAPDecoderSeekStart;
extern NSString* kQGVAPDecoderSeekFinish;

@interface QGBaseDecoder : NSObject

@property (atomic, assign) NSInteger currentDecodeFrame;    //正在解码的帧索引
@property (nonatomic, readonly) QGBaseDFileInfo *fileInfo; //解码文件信息 只能通过初始化方法赋值

- (instancetype)initWith:(QGBaseDFileInfo *)fileInfo error:(NSError **)error;
- (void)decodeFrame:(NSInteger)frameIndex buffers:(NSMutableArray *)buffers;
- (BOOL)shouldStopDecode:(NSInteger)nextFrameIndex;
- (BOOL)isFrameIndexBeyondEnd:(NSInteger)frameIndex;

@end
