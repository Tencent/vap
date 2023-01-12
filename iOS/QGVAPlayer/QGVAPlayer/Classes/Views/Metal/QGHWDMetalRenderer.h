// QGHWDMetalRenderer.h
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

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import "VAPMacros.h"

UIKIT_EXTERN NSString *const kQGHWDVertexFunctionName;
UIKIT_EXTERN NSString *const kQGHWDYUVFragmentFunctionName;
extern matrix_float3x3 const kQGColorConversionMatrix601Default;
extern matrix_float3x3 const kQGColorConversionMatrix601FullRangeDefault;
extern matrix_float3x3 const kQGColorConversionMatrix709Default;
extern matrix_float3x3 const kQGColorConversionMatrix709FullRangeDefault;
extern matrix_float3x3 const kQGBlurWeightMatrixDefault;
extern id<MTLDevice> kQGHWDMetalRendererDevice;

#if TARGET_OS_SIMULATOR//模拟器

@interface QGHWDMetalRenderer : NSObject

@property (nonatomic, assign) QGHWDTextureBlendMode blendMode;

- (instancetype)initWithMetalLayer:(id)layer blendMode:(QGHWDTextureBlendMode)mode;
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer metalLayer:(id)layer;
- (void)dispose;

@end
#else

@interface QGHWDMetalRenderer : NSObject

@property (nonatomic, assign) QGHWDTextureBlendMode blendMode;

- (instancetype)initWithMetalLayer:(CAMetalLayer *)layer blendMode:(QGHWDTextureBlendMode)mode;

- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer metalLayer:(CAMetalLayer *)layer;

- (void)dispose;

@end

#endif
