// QGVAPConfigManager.m
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

#import "QGVAPConfigManager.h"
#import "QGMP4Parser.h"
#import "QGVAPLogger.h"
#import "NSDictionary+VAPUtil.h"
#import "UIColor+VAPUtil.h"
#import "NSArray+VAPUtil.h"
#import "QGHWDMetalRenderer.h"
#import "QGVAPTextureLoader.h"

@interface QGVAPConfigManager () {
    
    QGMP4HWDFileInfo *_fileInfo;
}

@end

@implementation QGVAPConfigManager

- (instancetype)initWith:(QGMP4HWDFileInfo *)fileInfo {
    
    if (self = [super init]) {
        _fileInfo = fileInfo;
        [self setupConfig];
    }
    return self;
}

- (void)setupConfig {
    
    QGMP4Box *vapc = [_fileInfo.mp4Parser.rootBox subBoxOfType:QGMP4BoxType_vapc];
    if (!vapc) {
        self.hasValidConfig = NO;
        VAP_Error(kQGVAPModuleCommon, @"config can not find vapc box");
        return ;
    }
    self.hasValidConfig = YES;
    NSData *vapcData = [_fileInfo.mp4Parser readDataOfBox:vapc length:vapc.length-8 offset:8];
    NSError *error = nil;
    NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData:vapcData options:kNilOptions error:&error];
    if (error) {
        VAP_Error(kQGVAPModuleCommon, @"fail to parse config as dictionary file %@", vapc);
    }
    [self parseConfigDictinary:configDictionary];
}

#pragma mark - resource loader

- (void)loadConfigResources {
    
    if (self.model.resources.count == 0) {
        if ([self.delegate respondsToSelector:@selector(onVAPConfigResourcesLoaded:error:)]) {
            [self.delegate onVAPConfigResourcesLoaded:self.model error:nil];
        }
        return ;
    }
    
    //tags
    if ([self.delegate respondsToSelector:@selector(vap_contentForTag:resource:)]) {
        [self.model.resources enumerateObjectsUsingBlock:^(QGVAPSourceInfo * _Nonnull resource, NSUInteger idx, BOOL * _Nonnull stop) {
            resource.contentTagValue = [self.delegate vap_contentForTag:resource.contentTag resource:resource];
        }];
    }
    
    if (![self.delegate respondsToSelector:@selector(vap_loadImageWithURL:context:completion:)]) {
        return ;
    }
    __block NSError *loadError = nil;
    dispatch_group_t group = dispatch_group_create();
    [self.model.resources enumerateObjectsUsingBlock:^(QGVAPSourceInfo * _Nonnull resource, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *tagContent = resource.contentTagValue;
        if ([resource.type isEqualToString:kQGAGAttachmentSourceTypeText] && [resource.loadType isEqualToString:QGAGAttachmentSourceLoadTypeLocal]) {
            resource.sourceImage = [QGVAPTextureLoader drawingImageForText:tagContent color:resource.color size:resource.size bold:[resource.style isEqualToString:kQGAGAttachmentSourceStyleBoldText]];
        }
        
        if ([resource.type isEqualToString:kQGAGAttachmentSourceTypeImg] && [resource.loadType isEqualToString:QGAGAttachmentSourceLoadTypeNet]) {
            NSString *imageURL = tagContent;
            
            NSDictionary *context = @{@"resource":resource};
            dispatch_group_enter(group);
            [self.delegate vap_loadImageWithURL:imageURL context:context completion:^(UIImage *image, NSError *error, NSString *imageURL) {
                if (!image || error) {
                    VAP_Error(kQGVAPModuleCommon, @"loadImageWithURL %@ error:%@", imageURL, error);
                    loadError = (loadError ?: (error ?: ([NSError errorWithDomain:[NSString stringWithFormat:@"loadImageError:%@", imageURL] code:-1 userInfo:nil])));
                }
                resource.sourceImage = image;
                dispatch_group_leave(group);
            }];
        }
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(onVAPConfigResourcesLoaded:error:)]) {
            [self.delegate onVAPConfigResourcesLoaded:self.model error:loadError];
        }
    });
}

- (void)loadMTLTextures:(id<MTLDevice>)device {
    
    [self.model.resources enumerateObjectsUsingBlock:^(QGVAPSourceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MTLTexture> texture = [QGVAPTextureLoader loadTextureWithImage:obj.sourceImage device:device];
        obj.sourceImage = nil;
        obj.texture = texture;
    }];
}

- (void)loadMTLBuffers:(id<MTLDevice>)device {
    
    [self.model.resources enumerateObjectsUsingBlock:^(QGVAPSourceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MTLBuffer> buffer = [QGVAPTextureLoader loadVapColorFillBufferWith:obj.color device:device];
        obj.colorParamsBuffer = buffer;
    }];
}


#pragma mark - parse json

- (void)parseConfigDictinary:(NSDictionary *)configDic {
    
    NSDictionary *commonInfoDic = [configDic hwd_dicValue:@"info"];
    NSArray *sourcesArr = [configDic hwd_arrValue:@"src"];
    NSArray *framesArr = [configDic hwd_arrValue:@"frame"];
    
    if (!commonInfoDic) {
        VAP_Error(kQGVAPModuleCommon, @"has no commonInfoDic:%@", configDic);
        return ;
    }
    QGVAPConfigModel *configModel = [QGVAPConfigModel new];
    //parse
    NSInteger version = [commonInfoDic hwd_integerValue:@"v"];
    NSInteger frameCount = [commonInfoDic hwd_integerValue:@"f"];
    CGFloat w = [commonInfoDic hwd_floatValue:@"w"];
    CGFloat h = [commonInfoDic hwd_floatValue:@"h"];
    CGFloat video_w = [commonInfoDic hwd_floatValue:@"videoW"];
    CGFloat video_h = [commonInfoDic hwd_floatValue:@"videoH"];
    CGFloat orientaion = [commonInfoDic hwd_integerValue:@"orien"];
    NSInteger fps = [commonInfoDic hwd_integerValue:@"fps"];
    BOOL isMerged = ([commonInfoDic hwd_integerValue:@"isVapx"] == 1);
    NSArray *a_frame = [commonInfoDic hwd_arrValue:@"aFrame"];
    NSArray *rgb_frame = [commonInfoDic hwd_arrValue:@"rgbFrame"];
    self.model = configModel;
    //整体信息
    QGVAPCommonInfo *commonInfo = [QGVAPCommonInfo new];
    commonInfo.version = version;
    commonInfo.framesCount = frameCount;
    commonInfo.size = CGSizeMake(w, h);
    commonInfo.videoSize = CGSizeMake(video_w, video_h);
    commonInfo.targetOrientaion = orientaion;
    commonInfo.fps = fps;
    commonInfo.isMerged = isMerged;
    commonInfo.alphaAreaRect = a_frame ? [a_frame hwd_rectValue] : CGRectZero;
    commonInfo.rgbAreaRect = rgb_frame ? [rgb_frame hwd_rectValue] : CGRectZero;
    configModel.info = commonInfo;
    //更新parser的fps信息
    _fileInfo.mp4Parser.fps = fps;
    if (!sourcesArr) {
        VAP_Error(kQGVAPModuleCommon, @"has no sourcesArr:%@", configDic);
        return ;
    }
    
    //源信息
    NSMutableDictionary <NSString *, QGVAPSourceInfo *>*sources = [NSMutableDictionary new];
    [sourcesArr enumerateObjectsUsingBlock:^(NSDictionary *sourceDic, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![sourceDic isKindOfClass:[NSDictionary class]]) {
            VAP_Error(kQGVAPModuleCommon, @"sourceDic is not dic:%@", sourceDic);
            return ;
        }
        NSString *sourceID = [sourceDic hwd_stringValue:@"srcId"];
        if (!sourceID) {
            VAP_Error(kQGVAPModuleCommon, @"has no sourceID:%@", sourceDic);
            return ;
        }
        //parse
        QGAGAttachmentSourceType sourceType = [sourceDic hwd_stringValue:@"srcType"];
        QGAGAttachmentSourceLoadType loadType = [sourceDic hwd_stringValue:@"loadType"];
        NSString *contentTag = [sourceDic hwd_stringValue:@"srcTag"];
        UIColor *color = [UIColor hwd_colorWithHexString:[sourceDic hwd_stringValue:@"color"]];
        QGAGAttachmentSourceStyle style = [sourceDic hwd_stringValue:@"style"];
        CGFloat width = [sourceDic hwd_floatValue:@"w"];
        CGFloat height = [sourceDic hwd_floatValue:@"h"];
        QGAGAttachmentFitType fitType = [sourceDic hwd_stringValue:@"fitType"];
        QGVAPSourceInfo *sourceInfo = [QGVAPSourceInfo new];
        sourceInfo.type = sourceType;
        sourceInfo.style = style;
        sourceInfo.contentTag = contentTag;
        sourceInfo.color = color;
        sourceInfo.size = CGSizeMake(width, height);
        sourceInfo.fitType = fitType;
        sourceInfo.loadType = loadType;
        sources[sourceID] = sourceInfo;
    }];
    configModel.resources = sources.allValues;
    
    //融合信息
    if (!framesArr) {
        VAP_Error(kQGVAPModuleCommon, @"has no framesArr:%@", configDic);
        return ;
    }
    NSMutableDictionary <NSNumber *, NSArray<QGVAPMergedInfo *>*> *mergedConfig = [NSMutableDictionary new];
    [framesArr enumerateObjectsUsingBlock:^(NSDictionary *frameMergedDic, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![frameMergedDic isKindOfClass:[NSDictionary class]]) {
            VAP_Error(kQGVAPModuleCommon, @"frameMergedDic is not dic:%@", frameMergedDic);
            return ;
        }
        NSInteger frameIndex = [frameMergedDic hwd_integerValue:@"i"];
        
        NSMutableArray <QGVAPMergedInfo *> *mergedInfos = [NSMutableArray new];
        NSArray *mergedObjs = [frameMergedDic hwd_arrValue:@"obj"];
        [mergedObjs enumerateObjectsUsingBlock:^(NSDictionary *mergeInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![mergeInfoDic isKindOfClass:[NSDictionary class]]) {
                VAP_Error(kQGVAPModuleCommon, @"mergeInfoDic is not dic:%@", mergeInfoDic);
                return ;
            }
            NSString *sourceID = [mergeInfoDic hwd_stringValue:@"srcId"];
            QGVAPSourceInfo *sourceInfo = sources[sourceID];
            if (!sourceInfo) {
                VAP_Error(kQGVAPModuleCommon, @"sourceInfo is nil:%@", mergeInfoDic);
                return ;
            }
            //parse
            NSArray *frame = [mergeInfoDic hwd_arrValue:@"frame"];
            NSArray *m_frame = [mergeInfoDic hwd_arrValue:@"mFrame"];
            NSInteger renderIndex = [mergeInfoDic hwd_integerValue:@"z"];
            NSInteger rotationAngle = [mergeInfoDic hwd_integerValue:@"mt"];
            QGVAPMergedInfo *mergeInfo = [QGVAPMergedInfo new];
            mergeInfo.source = sourceInfo;
            mergeInfo.renderIndex = renderIndex;
            mergeInfo.needMask = (m_frame != nil);
            mergeInfo.renderRect = frame ? [frame hwd_rectValue] : CGRectZero;
            mergeInfo.maskRect = m_frame ? [m_frame hwd_rectValue] : CGRectZero;
            mergeInfo.maskRotation = rotationAngle;
            [mergedInfos addObject:mergeInfo];
        }];
        NSArray *sortedMergeInfos = [mergedInfos sortedArrayUsingComparator:^NSComparisonResult(QGVAPMergedInfo *info1, QGVAPMergedInfo *info2) {
            return [@(info1.renderIndex) compare:@(info2.renderIndex)];
        }];
        mergedConfig[@(frameIndex)] = sortedMergeInfos;
    }];
    configModel.mergedConfig = mergedConfig;
}

@end
