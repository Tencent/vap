// QGAnimatedImageDecodeManager.m
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

#import "QGAnimatedImageDecodeManager.h"
#import "QGAnimatedImageBufferManager.h"
#import "QGBaseDecoder.h"
#import "QGVAPSafeMutableArray.h"
#import "QGMP4FrameHWDecoder.h"
#import "QGVAPLogger.h"
#import <sys/stat.h>
#import <AVFoundation/AVFoundation.h>

@interface QGAnimatedImageDecodeManager() {

    QGAnimatedImageDecodeConfig *_config;           //解码配置
    QGBaseDFileInfo *_fileInfo;                     //sharpP文件信息
    NSMutableArray *_decoders;                      //解码器
    QGAnimatedImageBufferManager *_bufferManager;   //缓冲管理
    AVAudioPlayer *_audioPlayer;
}

@end

@implementation QGAnimatedImageDecodeManager

- (instancetype)initWith:(QGBaseDFileInfo *)fileInfo
                  config:(QGAnimatedImageDecodeConfig *)config
                delegate:(id<QGAnimatedImageDecoderDelegate>)delegate {

    if (self = [super init]) {
        
        _config = config;
        _fileInfo = fileInfo;
        _decoderDelegate = delegate;
        [self createDecodersByConfig:config];
        _bufferManager = [[QGAnimatedImageBufferManager alloc] initWithConfig:config];
        [self initializeBuffers];
        [self setupAudioPlayerIfNeed];
    }
    return self;
}

/**
 取出已解码的一帧并准备下一帧
 
 @param frameIndex 帧索引
 @return 帧内容
 */
- (QGBaseAnimatedImageFrame *)consumeDecodedFrame:(NSInteger)frameIndex {

    @synchronized (self) {
        // 控制何时命中第一帧，缓存满了才命中
        if (frameIndex == 0 && _bufferManager.buffers.count < _config.bufferCount) {
            return nil;
        }
        [self checkIfDecodeFinish:frameIndex];
        QGBaseAnimatedImageFrame *frame = [_bufferManager popVideoFrame];
        if (frame) {
            // pts顺序
            frame.frameIndex = frameIndex;
            [self decodeFrame:frameIndex+_config.bufferCount];
        }
        return frame;
    }
}

- (void)tryToStartAudioPlay {
    if (!_audioPlayer) {
        return ;
    }
    [_audioPlayer play];
}

#pragma mark - private methods

- (void)checkIfDecodeFinish:(NSInteger)frameIndex {
    
    NSInteger decoderIndex = _decoders.count==1?0:frameIndex%_decoders.count;
    QGBaseDecoder *decoder = _decoders[decoderIndex];
    if ([decoder isFrameIndexBeyondEnd:frameIndex]) {
        if ([self.decoderDelegate respondsToSelector:@selector(decoderDidFinishDecode:)]) {
            [self.decoderDelegate decoderDidFinishDecode:decoder];
        }
    }
}

- (void)decodeFrame:(NSInteger)frameIndex {

    if (!_decoders || _decoders.count == 0) {
        //NSLog(@"error! can't find decoder");
        return ;
    }
    NSInteger decoderIndex = _decoders.count==1?0:frameIndex%_decoders.count;
    QGBaseDecoder *decoder = _decoders[decoderIndex];
    if ([decoder shouldStopDecode:frameIndex]) {
        return ;
    }
    [decoder decodeFrame:frameIndex buffers:_bufferManager.buffers];
}

- (void)createDecodersByConfig:(QGAnimatedImageDecodeConfig *)config {

    if (!self.decoderDelegate || ![self.decoderDelegate respondsToSelector:@selector(decoderClassForManager:)]) {
        VAP_Event(kQGVAPModuleCommon, @"you MUST implement the delegate in invoker!");
        NSAssert(0, @"you MUST implement the delegate in invoker!");
        return ;
    }
    
    _decoders = [QGVAPSafeMutableArray new];
    for (int i = 0; i < config.threadCount; i ++) {
        Class class = [self.decoderDelegate decoderClassForManager:self];
        NSError *error = nil;
        QGBaseDecoder *decoder = [class alloc];
        decoder = [decoder initWith:_fileInfo error:&error];
        if (!decoder) {
            if ([self.decoderDelegate respondsToSelector:@selector(decoderDidFailDecode:error:)]) {
                [self.decoderDelegate decoderDidFailDecode:nil error:error];
            }
            break ;
        }
        [_decoders addObject:decoder];
    }
}

- (void)initializeBuffers {
    
    for (int i = 0; i < _config.bufferCount; i++) {
        [self decodeFrame:i];
    }
}

- (void)setupAudioPlayerIfNeed {
    
    if ([_fileInfo isKindOfClass:[QGMP4HWDFileInfo class]]) {
        QGMP4ParserProxy *mp4Parser = [(QGMP4HWDFileInfo *)_fileInfo mp4Parser];
        if (!mp4Parser.audioTrackBox) {
            _audioPlayer = nil;
            return ;
        }
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:_fileInfo.filePath] error:&error];
    }
}

- (void)dealloc {

}

@end
