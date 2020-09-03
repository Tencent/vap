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

#import "VapxProcessor.h"
#import "QGVAPConfigModel.h"
#import "VapxMP4Decoder.h"
#import "VapxAlphaExtractor.h"
#import "QGVAPConfigModel.h"
#import "VapxMp4Editor.h"
#import "VapxMaskInfoGenerator.h"
#import "VapxLayoutManager.h"
#import "VapxFileHelper.h"
#import "AppDelegate.h"

@implementation VapxProcessor

- (void)process:(processorProgressBlock)progress onCompletion:(processorCompletionBlock)block {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        NSString *mp4Path = [self produceVapFile:&error progress:progress];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!block) {
                return ;
            }
            if (error || mp4Path.length == 0) {
                block(NO,nil,error);
                return ;
            }
            block(YES, mp4Path, nil);
        });
    });
}

- (NSString *)produceVapFile:(NSError **)error progress:(processorProgressBlock)progress {
    
    QGVAPConfigModel *configModel = [QGVAPConfigModel new];
    QGVAPCommonInfo *commonInfo = [QGVAPCommonInfo new];
    configModel.info = commonInfo;
    commonInfo.version = self.version;
    commonInfo.fps = self.fps;
    
    CGFloat currentProgress = 0.0;
    CGFloat stepSize = 1/8.0;
    
    //1.配置信息
    NSMutableArray<QGVAPSourceInfo *> *sources = [NSMutableArray new];
    NSMutableArray *maskDirs = [NSMutableArray new];
    [self.mergeInfoViews enumerateObjectsUsingBlock:^(VapMergeInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QGVAPSourceInfo *source = [QGVAPSourceInfo new];
        source.srcID = [NSString stringWithFormat:@"%@",@(idx+1)];
        if ([obj.resTypePopButton.title isEqualToString:@"网络图片"]) {
            source.type = kVapAttachmentSourceTypeImgUrl;
            source.loadType = kVapAttachmentLoadTypeNet;
        } else if([obj.resTypePopButton.title isEqualToString:@"文字"]) {
            source.type = kVapAttachmentSourceTypeTextStr;
            source.loadType = kVapAttachmentLoadTypeLocal;
            if ([obj.fontStyleButton.title isEqualToString:@"粗体"]) {
                source.style = kVapAttachmentSourceStyleBoldText;
            }
        }
        source.contentTag = obj.tagLabel.stringValue;
        source.color = obj.colorLabel.stringValue;
        source.size = NSMakeSize([obj.widthLabel.stringValue integerValue], [obj.heightLabel.stringValue integerValue]);
        if ([obj.fitTypePopButton.selectedItem.title isEqualToString:@"铺满"]) {
            source.fitType = kVapAttachmentFitTypeFitXY;
        } else if ([obj.fitTypePopButton.selectedItem.title isEqualToString:@"等比适配"]) {
            source.fitType = kVapAttachmentFitTypeCenterFull;
        }
        [sources addObject:source];
        [maskDirs addObject:obj.maskPath];
    }];
    configModel.resources = sources;
    
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    //2.拆分alpha rgb通道
    [VapxAlphaExtractor extractWithDir:[self.fileHelper videoFramesPath] info:&commonInfo completion:^(NSInteger framesCount, NSArray<NSString *> *alphaFiles, NSArray<NSString *> *rgbFiles) {
        NSLog(@"--count:%@", @(framesCount));
    }];
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    if (self.classicMode && (((int)commonInfo.size.width)%16 != 0 || ((int)commonInfo.size.height)%16 != 0)) {
        *error = [NSError errorWithDomain:@"经典模式下长宽必须是16整数倍" code:-1 userInfo:nil];
        return nil;
    }
    
    //3.生成每一帧的遮罩信息
    NSDictionary *mergeInfos = [VapxMaskInfoGenerator mergeInfoAt:maskDirs sources:sources frames:commonInfo.framesCount];
    configModel.mergedConfig = mergeInfos;
    if (mergeInfos.count > 0) {
        configModel.info.isMerged = YES;
    }
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    //4.布局计算
    CGFloat alphaScale = self.alphaScale;
    VapxLayoutManager *layoutManager = [VapxLayoutManager new];
    layoutManager.padding = self.layoutPadding;
    layoutManager.classicMode = self.classicMode;
    NSSize size = [layoutManager maximumSizeForInfo:configModel alphaMinScale:alphaScale];
    if (size.width > kVapLayoutMaxWidth || size.height > kVapLayoutMaxWidth) {
        NSLog(@"尺寸过大，请尝试减小scale");
        *error = [NSError errorWithDomain:@"尺寸过大，请尝试减小scale" code:-1 userInfo:nil];
    }
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    //5.布局
    CGFloat hexWidth = [self minimumHexNumberOf:(int)size.width];
    CGFloat hexHeight = [self minimumHexNumberOf:(int)size.height];
    commonInfo.videoSize = NSMakeSize(hexWidth, hexHeight);
    [layoutManager layoutWith:configModel desDir:[_fileHelper layoutDir] alphaScale:alphaScale];
    
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    //6.合成mp4文件
    NSString *outputPath = [VapxMP4Decoder encodeWithDir:[_fileHelper layoutDir] outputName:[_fileHelper layoutMP4Name] fps:commonInfo.fps bitRate:[NSString stringWithFormat:@"%@k",@(self.bitrates)] audioPath:self.audioPath];
    
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    //7.生成配置box
    NSString *jsonString = [configModel jsonString];
    NSData *utf8Data = [jsonString dataUsingEncoding:kCFStringEncodingUTF8];
    NSString *avcJsonPath = [[_fileHelper outputPath] stringByAppendingPathComponent:@"vapc.json"];
    [utf8Data writeToFile:avcJsonPath atomically:YES];
    
    NSInteger length = utf8Data.length+8;
    unsigned char bytes[8] = {(length&0xff000000)>>24,(length&0xff0000)>>16,(length&0xff00)>>8,length&0xff,'v','a','p','c'};
    NSMutableData *muData = [[[NSData alloc] initWithBytes:bytes length:8] mutableCopy];
    [muData appendData:utf8Data];
    NSString *vapcStringPath = [[_fileHelper outputPath] stringByAppendingPathComponent:@"vapc.bin"];
    BOOL succ = [muData writeToFile:vapcStringPath atomically:YES];
    if (!succ) {
        NSLog(@"vapc data write fail!%@", muData);
        *error = [NSError errorWithDomain:@"vapc data write fail!" code:-1 userInfo:nil];
        return nil;
    }
    currentProgress += stepSize;
    if (progress) {
        progress(currentProgress);
    }
    
    if ([[(AppDelegate *)[NSApplication sharedApplication].delegate encoder] isEqualToString:@"libvpx-vp9"]) {
        return outputPath;
    }
    
    //8.将配置信息写入mp4n并导出文件
    VapxMp4Editor *mp4Editor = [VapxMp4Editor new];
    mp4Editor.inputPath = [[_fileHelper layoutDir] stringByAppendingPathComponent:[_fileHelper layoutMP4Name]];
    mp4Editor.outputPath = [[_fileHelper outputPath] stringByAppendingPathComponent:[_fileHelper outputMP4Name]];
    NSString *newMp4 = [mp4Editor mp4ByInsertAtom:vapcStringPath atIndex:1];
    [[NSFileManager defaultManager] removeItemAtPath:vapcStringPath error:nil];
    return newMp4;
}

- (NSInteger)minimumHexNumberOf:(NSInteger)num {
    if (num%16 == 0) {
        return num;
    }
    return 16-((int)num%16)+num;
}

@end
