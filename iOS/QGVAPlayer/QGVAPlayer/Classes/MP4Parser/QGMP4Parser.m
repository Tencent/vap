// QGMP4Parser.m
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

#import "QGMP4Parser.h"
#import "QGVAPLogger.h"

#pragma mark - mp4 parser
@interface QGMP4Parser() {
    
    QGMp4BoxDataFetcher _boxDataFetcher;
}

@property (nonatomic, strong) NSString *filePath;

@end

@implementation QGMP4Parser

#pragma mark -- life cycle

- (instancetype)initWithFilePath:(NSString *)filePath {
    
    if (self = [super init]) {
        _filePath = filePath;
        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath];
        __weak __typeof(self) weakSelf = self;
        _boxDataFetcher = ^NSData *(QGMP4Box *box) {return [weakSelf readDataForBox:box];};
    }
    return self;
}

- (void)dealloc {
    
    [_fileHandle closeFile];
}

#pragma mark -- methods

- (void)parse {
    
    if (!_filePath || !_fileHandle) {
        return ;
    }
    
    unsigned long long fileSize = [_fileHandle seekToEndOfFile];
    [_fileHandle seekToFileOffset:0];
    _rootBox = [QGMP4BoxFactory createBoxForType:QGMP4BoxType_unknown startIndex:0 length:fileSize];
    NSMutableArray *BFSQueue = [NSMutableArray new];
    [BFSQueue addObject:_rootBox];
    
    QGMP4Box *calBox = _rootBox;
    
    //长度包含包含类型码长度+本身长度
    while ((calBox = [BFSQueue firstObject])) {
        [BFSQueue removeObjectAtIndex:0];
        
        if (calBox.length <= 2*(kQGBoxSizeLengthInBytes+kQGBoxTypeLengthInBytes)) {
            //长度限制
            continue ;
        }
        
        unsigned long long offset = 0;
        unsigned long long length = 0;
        QGMP4BoxType type = QGMP4BoxType_unknown;
        
        //第一个子box
        offset = calBox.superBox ? (calBox.startIndexInBytes + kQGBoxSizeLengthInBytes + kQGBoxTypeLengthInBytes) : 0;
        
        //特殊处理
        if ([self shouldResetOffset:calBox.type]) {
            [self calibrateOffset:&offset boxType:calBox.type];
        }
        
        //解析子box
        do {
            //判断是否会越界
            if ((offset+kQGBoxSizeLengthInBytes+kQGBoxTypeLengthInBytes)>(calBox.startIndexInBytes+calBox.length)) {
                break ;
            }
            
            if (![self readBoxTypeAndLength:offset type:&type length:&length]) {
                break;
            }
          
            if ((offset+length)>(calBox.startIndexInBytes+calBox.length)) {
                //reach to super box end or not a box
                break ;
            }
            
            if (![QGMP4BoxFactory isTypeValueValid:type] && (offset == (calBox.startIndexInBytes + kQGBoxSizeLengthInBytes + kQGBoxTypeLengthInBytes))) {
                //目前的策略是
                break ;
            }
            QGMP4Box *subBox = [QGMP4BoxFactory createBoxForType:type startIndex:offset length:length];
            subBox.superBox = calBox;
            if (!calBox.subBoxes) {
                calBox.subBoxes = [NSMutableArray new];
            }
            //加入box节点
            [calBox.subBoxes addObject:subBox];
            
            //进入广度优先遍历队列
            [BFSQueue addObject:subBox];
            [self didParseBox:subBox];
            
            //继续兄弟box
            offset += length;
        } while(1);
    }
    
    [self didFinisheParseFile];
}

- (BOOL)readBoxTypeAndLength:(uint64_t)offset type:(QGMP4BoxType *)type length:(uint64_t*)length {
    [_fileHandle seekToFileOffset:offset];
    NSData *data = [_fileHandle readDataOfLength:(kQGBoxSizeLengthInBytes + kQGBoxTypeLengthInBytes)];
    if (data.length < kQGBoxSizeLengthInBytes + kQGBoxTypeLengthInBytes) {
      VAP_Error(kQGVAPModuleCommon, @"read box length and type error");
      return NO;
    }
    const char *bytes = data.bytes;
    *length = [self readValue:bytes length:kQGBoxSizeLengthInBytes];
    *type = [self readValue:&bytes[kQGBoxSizeLengthInBytes] length:kQGBoxTypeLengthInBytes];
    if (*length == kQGBoxLargeSizeFlagLengthInBytes) {
      offset += kQGBoxSizeLengthInBytes + kQGBoxTypeLengthInBytes;
      [_fileHandle seekToFileOffset:offset];
      data = [_fileHandle readDataOfLength:kQGBoxLargeSizeLengthInBytes];
      if (data.length < kQGBoxLargeSizeLengthInBytes) {
        VAP_Error(kQGVAPModuleCommon, @"read box length and type error");
        return NO;
      }
      bytes = data.bytes;
      *length = [self readValue:bytes length:kQGBoxLargeSizeLengthInBytes];
      if (*length == 0) {
        VAP_Error(kQGVAPModuleCommon, @"read box length is 0");
        return NO;
      }
    }
    return YES;
}

- (BOOL)shouldResetOffset:(QGMP4BoxType)type {
    return type == QGMP4BoxType_stsd ||
           type == QGMP4BoxType_avc1 ||
           type == QGMP4BoxType_hvc1;
}

- (void)calibrateOffset:(uint64_t*)offset boxType:(QGMP4BoxType)type {
    switch (type) {
        case QGMP4BoxType_stsd:
            *offset += 8;
            break;
        case QGMP4BoxType_avc1:
        case QGMP4BoxType_hvc1:
            *offset += (24 + 2 + 2 + 14 + 32 + 4);
            break;
        default:
            break;
    }
}

- (NSData *)readDataForBox:(QGMP4Box *)box {
    
    if (!box) {
        return  nil;
    }
    [_fileHandle seekToFileOffset:box.startIndexInBytes];
    return [_fileHandle readDataOfLength:(NSUInteger)box.length];
}

- (NSInteger)readValue:(const char*)bytes length:(NSInteger)length {
    
    NSInteger value = 0;
    for (int i = 0; i < length; i++) {
        value += (bytes[i]&0xff)<<((length-i-1)*8);
    }
    VAP_Debug(kQGVAPModuleCommon, @"readValue length:%lld value:%lld", length, value);
    return value;
}

#pragma mark -- private methods

- (void)didParseBox:(QGMP4Box *)box {
    
    if ([box respondsToSelector:@selector(boxDidParsed:)]) {
        [box boxDidParsed:_boxDataFetcher];
    }
    if ([self.delegate respondsToSelector:@selector(didParseMP4Box:parser:)]) {
        [self.delegate didParseMP4Box:box parser:self];
    }
}

- (void)didFinisheParseFile {
    
    if ([self.delegate respondsToSelector:@selector(MP4FileDidFinishParse:)]) {
        [self.delegate MP4FileDidFinishParse:self];
    }
}

@end

#pragma mark - parser proxy

@interface QGMP4ParserProxy() <QGMP4ParserDelegate> {
    
    QGMP4Parser *_parser;
}

@end

@implementation QGMP4ParserProxy

- (instancetype)initWithFilePath:(NSString *)filePath {
    
    if (self = [super init]) {
        
        _parser = [[QGMP4Parser alloc] initWithFilePath:filePath];
        _parser.delegate = self;
    }
    return self;
}

- (NSInteger)picWidth {
    
    if (_picWidth == 0) {
        _picWidth = [self readPicWidth];
    }
    return _picWidth;
}

- (NSInteger)picHeight {
    
    if (_picHeight == 0) {
        _picHeight = [self readPicHeight];
    }
    return _picHeight;
}

- (NSInteger)fps {
    
    if (_fps == 0) {
        if (self.videoSamples.count == 0) {
            return 0;
        }
        _fps = lround(self.videoSamples.count/self.duration);
    }
    return _fps;
}

- (double)duration {
    
    if (_duration == 0) {
        _duration = [self readDuration];
    }
    return _duration;
}

- (NSArray *)videoSamples {
    
    if (_videoSamples) {
        return _videoSamples;
    }
    NSMutableArray *videoSamples = [NSMutableArray new];
    
    uint64_t tmp = 0;
    QGMP4SttsBox *sttsBox = [self.videoTrackBox subBoxOfType:QGMP4BoxType_stts];
    QGMP4StszBox *stszBox = [self.videoTrackBox subBoxOfType:QGMP4BoxType_stsz];
    QGMP4StscBox *stscBox = [self.videoTrackBox subBoxOfType:QGMP4BoxType_stsc];
    QGMP4StcoBox *stcoBox = [self.videoTrackBox subBoxOfType:QGMP4BoxType_stco];
    QGMP4CttsBox *cttsBox = [self.videoTrackBox subBoxOfType:QGMP4BoxType_ctts];

    uint32_t stscEntryIndex = 0;
    uint32_t stscEntrySampleIndex = 0;
    uint32_t stscEntrySampleOffset = 0;
    uint32_t sttsEntryIndex = 0;
    uint32_t sttsEntrySampleIndex = 0;
    uint32_t stcoChunkLogicIndex = 0;
    for (int i = 0; i < stszBox.sampleCount; ++i) {
        if (stscEntryIndex >= stscBox.entries.count ||
            sttsEntryIndex >= sttsBox.entries.count ||
            stcoChunkLogicIndex >= stcoBox.chunkOffsets.count) {
            break;
        }

        QGStscEntry *stscEntry = stscBox.entries[stscEntryIndex];
        QGSttsEntry *sttsEntry = sttsBox.entries[sttsEntryIndex];
        uint32_t sampleOffset = [stcoBox.chunkOffsets[stcoChunkLogicIndex] unsignedIntValue] + stscEntrySampleOffset;
        uint32_t ctts = 0;
        if (i < cttsBox.compositionOffsets.count) {
            ctts = [cttsBox.compositionOffsets[i] unsignedIntValue];
        }

        QGMP4Sample *sample = [QGMP4Sample new];
        sample.codecType = QGMP4CodecTypeVideo;
        sample.sampleIndex = i;
        sample.chunkIndex = stcoChunkLogicIndex;
        sample.sampleDelta = sttsEntry.sampleDelta;
        sample.sampleSize = [stszBox.sampleSizes[i] unsignedIntValue];
        sample.pts = tmp + ctts;
        sample.streamOffset = sampleOffset;
        [videoSamples addObject:sample];

        stscEntrySampleOffset += sample.sampleSize;
        tmp += sample.sampleDelta;

        stscEntrySampleIndex++;
        if (stscEntrySampleIndex >= stscEntry.samplesPerChunk) {
            if (stcoChunkLogicIndex + 1 < stcoBox.chunkOffsets.count) {
                stcoChunkLogicIndex++;
            }

            stscEntrySampleIndex = 0;
            stscEntrySampleOffset = 0;
        }

        sttsEntrySampleIndex++;
        if (sttsEntrySampleIndex >= sttsEntry.sampleCount) {
            sttsEntrySampleIndex = 0;
            if (sttsEntryIndex + 1 < sttsBox.entries.count) {
                sttsEntryIndex++;
            }
        }

        if (stscEntryIndex + 1 < stscBox.entries.count) {
            if (stcoChunkLogicIndex >= stscBox.entries[stscEntryIndex + 1].firstChunk - 1) {
                stscEntryIndex++;
            }
        }
    }
    _videoSamples = videoSamples;
    return _videoSamples;
}

- (NSArray *)videoSyncSampleIndexes {
    QGMP4StssBox *stssBox = [self.videoTrackBox subBoxOfType:QGMP4BoxType_stss];
    return stssBox.syncSamples;
}

/**
 调用该方法才会解析mp4文件并得到必要信息。
 */
- (void)parse {
    
    [_parser parse];
    _rootBox = _parser.rootBox;
    
    // 解析视频解码配置信息
    [self parseVideoDecoderConfigRecord];
}

#pragma mark - Private

- (void)parseVideoDecoderConfigRecord {
    if (self.videoCodecID == QGMP4VideoStreamCodecIDH264) {
        [self parseAvccDecoderConfigRecord];
    } else if (self.videoCodecID == QGMP4VideoStreamCodecIDH265) {
        [self parseHvccDecoderConfigRecord];
    }
}

- (void)parseAvccDecoderConfigRecord {
    self.spsData = [self parseAvccSPSData];
    self.ppsData = [self parseAvccPPSData];
}

- (void)parseHvccDecoderConfigRecord {
    NSData *extraData = [_parser readDataForBox:[self.videoTrackBox subBoxOfType:QGMP4BoxType_hvcC]];
    if (extraData.length <= 8) {
        return;
    }
    
    const char *bytes = extraData.bytes;
    int index = 30; // 21 + 4 + 4
    
    //int lengthSize = ((bytes[index++] & 0xff) & 0x03) + 1;
    int arrayNum = bytes[index++] & 0xff;
    
    // sps pps vps 种类数量
    for (int i = 0; i < arrayNum; i++) {
        int value = bytes[index++] & 0xff;
        int naluType = value & 0x3F;
        // sps pps vps 各自的数量
        int naluNum = ((bytes[index] & 0xff) << 8) + (bytes[index + 1] & 0xff);
        index += 2;
        
        for (int j = 0; j < naluNum; j++) {
            int naluLength = ((bytes[index] & 0xff) << 8) + (bytes[index + 1] & 0xff);
            index += 2;
            NSData *paramData = [NSData dataWithBytes:&bytes[index] length:naluLength];
            
            if (naluType == 32) {
                // vps
                self.vpsData = paramData;
            } else if (naluType == 33) {
                // sps
                self.spsData = paramData;
            } else if (naluType == 34) {
                // pps
                self.ppsData = paramData;
            }
            
            index += naluLength;
        }
    }
}

- (NSData *)parseAvccSPSData {
    //boxsize(32)+boxtype(32)+prefix(40)+预留(3)+spsCount(5)+spssize(16)+...+ppscount(8)+ppssize(16)+...
    NSData *extraData = [_parser readDataForBox:[self.videoTrackBox subBoxOfType:QGMP4BoxType_avcC]];
    if (extraData.length <= 8) {
        return nil;
    }
    const char *bytes = extraData.bytes;
    //sps数量 默认一个暂无使用
    //NSInteger spsCount = bytes[13]&0x1f;
    NSInteger spsLength = ((bytes[14]&0xff)<<8) + (bytes[15]&0xff);
    NSInteger naluType = (uint8_t)bytes[16]&0x1F;
    if (spsLength + 16 > extraData.length || naluType != 7) {
        return nil;
    }
    NSData *spsData = [NSData dataWithBytes:&bytes[16] length:spsLength];
    return spsData;
}

- (NSData *)parseAvccPPSData {
    NSData *extraData = [_parser readDataForBox:[self.videoTrackBox subBoxOfType:QGMP4BoxType_avcC]];
    if (extraData.length <= 8) {
        return nil;
    }
    const char *bytes = extraData.bytes;
    NSInteger spsCount = bytes[13]&0x1f;
    NSInteger spsLength = ((bytes[14]&0xff)<<8) + (bytes[15]&0xff);
    NSInteger prefixLength = 16 + spsLength;
    
    while (--spsCount > 0) {
        if (prefixLength+2 >= extraData.length) {
            return nil;
        }
        NSInteger nextSpsLength = ((bytes[prefixLength]&0xff)<<8)+bytes[prefixLength+1]&0xff;
        prefixLength += nextSpsLength;
    }
    
    //默认1个
    //    NSInteger ppsCount = bytes[prefixLength]&0xff;
    if (prefixLength+3 >= extraData.length) {
        return nil;
    }
    NSInteger ppsLength = ((bytes[prefixLength+1]&0xff)<<8)+(bytes[prefixLength+2]&0xff);
    NSInteger naluType = (uint8_t)bytes[prefixLength+3]&0x1F;
    if (naluType != 8 || (ppsLength+prefixLength+3) > extraData.length) {
        return nil;
    }
    
    NSData *ppsData = [NSData dataWithBytes:&bytes[prefixLength+3] length:ppsLength];
    return ppsData;
}

- (NSInteger)readPicWidth {
    if (self.videoCodecID == QGMP4VideoStreamCodecIDUnknown) {
        return 0;
    }
    
    QGMP4BoxType boxType = self.videoCodecID == QGMP4VideoStreamCodecIDH264 ? QGMP4BoxType_avc1 : QGMP4BoxType_hvc1;
    NSInteger sizeIndex = 32;
    NSUInteger readLength = 2;
    QGMP4Box *avc1 = [self.videoTrackBox subBoxOfType:boxType];
    [_parser.fileHandle seekToFileOffset:avc1.startIndexInBytes+sizeIndex];
    NSData *widthData = [_parser.fileHandle readDataOfLength:readLength];
    
    if (widthData.length < readLength) {
        return 0;
    }
    
    const char *bytes = widthData.bytes;
    NSInteger width = ((bytes[0]&0xff)<<8)+(bytes[1]&0xff);
    return width;
}

- (NSInteger)readPicHeight {
    if (self.videoCodecID == QGMP4VideoStreamCodecIDUnknown) {
        return 0;
    }
    
    QGMP4BoxType boxType = self.videoCodecID == QGMP4VideoStreamCodecIDH264 ? QGMP4BoxType_avc1 : QGMP4BoxType_hvc1;
    NSInteger sizeIndex = 34;
    NSUInteger readLength = 2;
    QGMP4Box *avc1 = [self.videoTrackBox subBoxOfType:boxType];
    [_parser.fileHandle seekToFileOffset:avc1.startIndexInBytes+sizeIndex];
    NSData *heightData = [_parser.fileHandle readDataOfLength:readLength];
    
    if (heightData.length < readLength) {
        return 0;
    }
    
    const char *bytes = heightData.bytes;
    NSInteger height = ((bytes[0]&0xff)<<8)+(bytes[1]&0xff);
    return height;
}

- (double)readDuration {
    
    QGMP4MvhdBox *mdhdBox = [self.rootBox subBoxOfType:QGMP4BoxType_mvhd];
    NSData *mvhdData = [_parser readDataForBox:mdhdBox];
    const char *bytes = mvhdData.bytes;
    NSInteger version = READ32BIT(&bytes[8]);
    NSInteger timescaleIndex = 20;
    NSInteger timescaleLength = 4;
    NSInteger durationIndex = 24;
    NSInteger durationLength = 4;
    if (version == 1) {
        timescaleIndex = 28;
        durationIndex = 32;
        durationLength = 8;
    }
    
    NSInteger scale = [_parser readValue:&bytes[timescaleIndex] length:timescaleLength];
    NSInteger duration = [_parser readValue:&bytes[durationIndex] length:durationLength];
    if (scale == 0) {
        return 0;
    }
    double result = duration/(double)scale;
    return result;
}

- (NSData *)readPacketOfSample:(NSInteger)sampleIndex {
    
    if (sampleIndex >= self.videoSamples.count) {
        VAP_Error(kQGVAPModuleCommon, @"readPacketOfSample beyond bounds!:%@ > %@", @(sampleIndex), @(self.videoSamples.count-1));
        return nil;
    }
    QGMP4Sample *videoSample = self.videoSamples[sampleIndex];
    NSInteger currentSampleSize = videoSample.sampleSize;
    [_parser.fileHandle seekToFileOffset:videoSample.streamOffset];
    // 当视频文件有问题时，sampleIndex还没有到最后，sampleIndex < self.videoSamples.count(总帧数)时，readDataOfLength长度可能为0Bytes
    NSData *packetData = [_parser.fileHandle readDataOfLength:currentSampleSize];
    return packetData;
}

- (NSData *)readDataOfBox:(QGMP4Box *)box length:(NSInteger)length offset:(NSInteger)offset {
    
    if (length <= 0 || offset + length > box.length) {
        return nil;
    }
    [_parser.fileHandle seekToFileOffset:box.startIndexInBytes+offset];
    NSData *data = [_parser.fileHandle readDataOfLength:length];
    return data;
}

#pragma mark -- delegate

- (void)MP4FileDidFinishParse:(QGMP4Parser *)parser {
    
}

- (void)didParseMP4Box:(QGMP4Box *)box parser:(QGMP4Parser *)parser {
    
    switch (box.type) {
        case QGMP4BoxType_hdlr: {
            QGMP4TrackType trackType = ((QGMP4HdlrBox*)box).trackType;
            QGMP4TrackBox *trackBox = (QGMP4TrackBox*)[box superBoxOfType:QGMP4BoxType_trak];
            switch (trackType) {
                case QGMP4TrackType_Video:
                    self.videoTrackBox = trackBox;
                    break;
                case QGMP4TrackType_Audio:
                    self.audioTrackBox = trackBox;
                    break;
                default:
                    break;
            }
        } break;
        case QGMP4BoxType_avc1: {
            self.videoCodecID = QGMP4VideoStreamCodecIDH264;
        } break;
        case QGMP4BoxType_hvc1: {
            self.videoCodecID = QGMP4VideoStreamCodecIDH265;
        } break;
        default:
            break;
    }
}

@end
