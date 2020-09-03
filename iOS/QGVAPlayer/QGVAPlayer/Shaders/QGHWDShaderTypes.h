//  QGHWDShaderTypes.h
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

#ifndef QGHWDShaderTypes_h
#define QGHWDShaderTypes_h

/*
 请注意：更新本文件后请同步到QGHWDMetalShaderSourceDefine.h
 */
#import <simd/simd.h>

typedef struct {
    packed_float4 position;
    packed_float2 textureColorCoordinate;
    packed_float2 textureAlphaCoordinate;
} QGHWDVertex;

typedef struct {
    packed_float4 position;
    packed_float2 textureColorCoordinate;
    packed_float2 textureAlphaCoordinate;
    packed_float2 textureMaskCoordinate;
} QGVAPVertex;

struct ColorParameters {
    
    matrix_float3x3 matrix;
    packed_float2 offset;
};

struct MaskParameters {
    matrix_float3x3 weightMatrix;
    int coreSize;
    float texelOffset;
};

struct VapAttachmentFragmentParameter {
    
    int needOriginRGB;
    packed_float4 fillColor;
};

typedef struct {
    packed_float4 position;
    packed_float2 sourceTextureCoordinate;
    packed_float2 maskTextureCoordinate;
} QGHWDAttachmentVertex;

typedef enum QGHWDYUVFragmentTextureIndex {
    
    QGHWDYUVFragmentTextureIndexLuma            = 0,
    QGHWDYUVFragmentTextureIndexChroma          = 1,
    QGHWDYUVFragmentTextureIndexAttachmentStart = 2,
} QGHWDYUVFragmentTextureIndex;

#endif /* QGHWDShaderTypes_h */
