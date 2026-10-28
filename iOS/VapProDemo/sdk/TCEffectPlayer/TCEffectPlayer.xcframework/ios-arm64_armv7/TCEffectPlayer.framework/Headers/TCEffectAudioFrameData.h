// Copyright (c) 2025 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"

NS_ASSUME_NONNULL_BEGIN

TCEP_EXPORT @interface TCEffectAudioFrameData : NSObject

///音频sample数据
///当数据为非planar时，data[0]存放数据
@property(nonatomic, assign) uint8_t *_Nonnull* _Nonnull data;

///音频sample数据大小
///当数据为非planar时，size[0]存放数据长度
@property(nonatomic, assign) int *size;

///音频的采样率
@property(nonatomic, assign) unsigned int sampleRate;

///音频的channel layout， 常见值：3-立体声（STEREO），4-单声道（MONO）
@property(nonatomic, assign) uint64_t channelLayout;

///音频格式, 常见值：0-unsigned 8 bits. 1-signed 16 bits. 2-signed 32 bits
@property(nonatomic, assign) int format;

///当前sample的PTS, 单位毫秒
@property(nonatomic, assign) int64_t ptsMs;

///每个声道的采样数
@property(nonatomic, assign) int nbSamples;

///声道数
@property(nonatomic, assign) int channels;

@end

NS_ASSUME_NONNULL_END
