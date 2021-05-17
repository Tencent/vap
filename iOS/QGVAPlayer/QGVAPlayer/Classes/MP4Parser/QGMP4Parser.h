// QGMP4Parser.h
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
#import "QGMP4Box.h"

@class QGMP4Parser;
@protocol QGMP4ParserDelegate <NSObject>

@optional
- (void)didParseMP4Box:(QGMP4Box *)box parser:(QGMP4Parser *)parser;
- (void)MP4FileDidFinishParse:(QGMP4Parser *)parser;

@end

@interface QGMP4Parser : NSObject

@property (nonatomic, strong) QGMP4Box *rootBox;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, weak) id<QGMP4ParserDelegate> delegate;

- (instancetype)initWithFilePath:(NSString *)filePath;
- (void)parse;
- (NSData *)readDataForBox:(QGMP4Box *)box;
- (NSInteger)readValue:(const char*)bytes length:(NSInteger)length;

@end

@interface QGMP4ParserProxy : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;

@property (nonatomic, assign) NSInteger picWidth;       //视频宽度
@property (nonatomic, assign) NSInteger picHeight;      //视频高度
@property (nonatomic, assign) NSInteger fps;            //视频fps
@property (nonatomic, assign) double duration;          //视频时长
@property (nonatomic, strong) NSData *spsData;          //sps
@property (nonatomic, strong) NSData *ppsData;          //pps
@property (nonatomic, strong) NSArray *videoSamples;    //所有帧数据，包含了位置和大小等信息
@property (nonatomic, strong) NSArray *videoSyncSampleIndexes;  // 所有关键帧的index
@property (nonatomic, strong) QGMP4Box *rootBox;        //mp4文件根box
@property (nonatomic, strong) QGMP4TrackBox *videoTrackBox;     //视频track
@property (nonatomic, strong) QGMP4TrackBox *audioTrackBox;     //音频track
/** vps */
@property (nonatomic, strong) NSData *vpsData;
/** 视频流编码器ID类型 */
@property (nonatomic, assign) QGMP4VideoStreamCodecID videoCodecID;

- (void)parse;
- (NSData *)readPacketOfSample:(NSInteger)sampleIndex;
- (NSData *)readDataOfBox:(QGMP4Box *)box length:(NSInteger)length offset:(NSInteger)offset;

@end
