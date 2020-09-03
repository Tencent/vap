// QGVAPMetalRenderer.h
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
#import "QGVAPConfigModel.h"
#import <Metal/Metal.h>
#import "VAPMacros.h"

#if TARGET_OS_SIMULATOR//模拟器

@interface QGVAPMetalRenderer : NSObject

@property (nonatomic, strong) QGVAPCommonInfo *commonInfo;

- (instancetype)initWithMetalLayer:(id)layer;
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer metalLayer:(id)layer mergeInfos:(NSArray<QGVAPMergedInfo *> *)infos;
- (void)dispose;

@end

#else

@interface QGVAPMetalRenderer : NSObject

@property (nonatomic, strong) QGVAPCommonInfo *commonInfo;
@property (nonatomic, strong) QGVAPMaskInfo *maskInfo;

- (instancetype)initWithMetalLayer:(CAMetalLayer *)layer;

- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer metalLayer:(CAMetalLayer *)layer mergeInfos:(NSArray<QGVAPMergedInfo *> *)infos;

- (void)dispose;

@end

#endif
