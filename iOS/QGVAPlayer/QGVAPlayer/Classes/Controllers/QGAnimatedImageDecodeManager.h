// QGAnimatedImageDecodeManager.h
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
#import "QGBaseDecoder.h"
#import "QGBaseAnimatedImageFrame.h"
#import "QGAnimatedImageDecodeConfig.h"

@class QGAnimatedImageDecodeManager;
@protocol QGAnimatedImageDecoderDelegate <NSObject>

/**
 必须实现该方法 用以实例化解码器

 @param manager 解码控制器
 @return class
 */
- (Class)decoderClassForManager:(QGAnimatedImageDecodeManager *)manager;

@optional

- (BOOL)shouldSetupAudioPlayer;
/**
 到文件末尾时被调用

 @param decoder 解码器
 */
- (void)decoderDidFinishDecode:(QGBaseDecoder *)decoder;

- (void)decoderDidFailDecode:(QGBaseDecoder *)decoder error:(NSError *)error;

@end

@interface QGAnimatedImageDecodeManager : NSObject

@property (nonatomic, weak) id<QGAnimatedImageDecoderDelegate> decoderDelegate;

- (instancetype)initWith:(QGBaseDFileInfo *)fileInfo
                  config:(QGAnimatedImageDecodeConfig *)config
                delegate:(id<QGAnimatedImageDecoderDelegate>)delegate;

- (QGBaseAnimatedImageFrame *)consumeDecodedFrame:(NSInteger)frameIndex;

- (void)tryToStartAudioPlay;
- (void)tryToStopAudioPlay;
- (void)tryToPauseAudioPlay;
- (void)tryToResumeAudioPlay;
- (BOOL)containsThisDeocder:(id)decoder;

@end
