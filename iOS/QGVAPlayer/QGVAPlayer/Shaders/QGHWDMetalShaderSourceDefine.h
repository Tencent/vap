// QGHWDMetalShaderSourceDefine.h
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

#ifndef QGHWDMetalShaderSourceDefine_h
#define QGHWDMetalShaderSourceDefine_h

#import "VAPMacros.h"
#import "QGHWDShaderTypes.h"

/*
 !!!!!!!!!important!!!!!!!!!
 ！！所有.metal文件更新，都需要同步到这个文件中！！
 ！！本文件内着色器代码作为兜底逻辑，当无法找到预编译着色器时使用本文件定义的着色器字符串进行编译！
 !!!!!!!!!!!!!!!!!!!!!!!!!!
 */

//The source may only import the Metal standard library. There is no search path to find other functions.

//头文件引入
static NSString * const kQGHWDMetalShaderSourceImports =
@"#include <metal_stdlib> \n#import <simd/simd.h>\n";

//类型定义
static NSString * const kQGHWDMetalShaderTypeDefines =
SHADER_STRING(
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
              
              typedef struct {
                  packed_float4 position;
                  packed_float2 sourceTextureCoordinate;
                  packed_float2 maskTextureCoordinate;
              } QGHWDAttachmentVertex;
              
              struct VapAttachmentFragmentParameter {
                  
                  int needOriginRGB;
                  packed_float4 fillColor;
              };
);

//着色器代码
static NSString * const kQGHWDMetalShaderSourceString =
SHADER_STRING(
              
              //QGHWDShaders.metal
              using namespace metal;
              typedef struct {
                  
                  float4 clipSpacePostion [[ position ]];
                  float2 textureColorCoordinate;
                  float2 textureAlphaCoordinate;
              } HWDRasterizerData;
              
              typedef struct {
                  
                  float4 clipSpacePostion [[ position ]];
                  float2 textureColorCoordinate;
                  float2 textureAlphaCoordinate;
                  float2 textureMaskCoordinate;
              } VAPRasterizerData;
              
              typedef struct {
                  
                  float4 position [[ position ]];
                  float2 sourceTextureCoordinate;
                  float2 maskTextureCoordinate;
              } VAPAttachmentRasterizerData;
              
              float3 RGBColorFromYuvTextures(sampler textureSampler, float2 coordinate, texture2d<float> texture_luma, texture2d<float> texture_chroma, matrix_float3x3 rotationMatrix, float2 offset) {
                  
                  float3 color;
                  color.x = texture_luma.sample(textureSampler, coordinate).r;
                  color.yz = texture_chroma.sample(textureSampler, coordinate).rg - offset;
                  return float3(rotationMatrix * color);
              }
              
              float4 RGBAColor(sampler textureSampler, float2 colorCoordinate, float2 alphaCoordinate, texture2d<float> lumaTexture, texture2d<float> chromaTexture, constant ColorParameters *colorParameters) {
                  matrix_float3x3 rotationMatrix = colorParameters[0].matrix;
                  float2 offset = colorParameters[0].offset;
                  float3 color = RGBColorFromYuvTextures(textureSampler, colorCoordinate, lumaTexture, chromaTexture, rotationMatrix, offset);
                  float3 alpha = RGBColorFromYuvTextures(textureSampler, alphaCoordinate, lumaTexture, chromaTexture, rotationMatrix, offset);
                  return float4(color, alpha.r);
              }
              
              vertex HWDRasterizerData hwd_vertexShader(uint vertexID [[ vertex_id ]], constant QGHWDVertex *vertexArray [[ buffer(0) ]]) {
                  
                  HWDRasterizerData out;
                  out.clipSpacePostion = vertexArray[vertexID].position;
                  out.textureColorCoordinate = vertexArray[vertexID].textureColorCoordinate;
                  out.textureAlphaCoordinate = vertexArray[vertexID].textureAlphaCoordinate;
                  return out;
              }

              fragment float4 hwd_yuvFragmentShader(HWDRasterizerData input [[ stage_in ]],
                                                    texture2d<float>  lumaTexture [[ texture(0) ]],
                                                    texture2d<float>  chromaTexture [[ texture(1) ]],
                                                    constant ColorParameters *colorParameters [[ buffer(0) ]]) {
                  //signifies that an expression may be computed at compile-time rather than runtime
                  constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
                  return RGBAColor(textureSampler, input.textureColorCoordinate, input.textureAlphaCoordinate, lumaTexture, chromaTexture, colorParameters);
              }

              vertex VAPRasterizerData vap_vertexShader(uint vertexID [[ vertex_id ]], constant QGVAPVertex *vertexArray [[ buffer(0) ]]) {
                  
                  VAPRasterizerData out;
                  out.clipSpacePostion = vertexArray[vertexID].position;
                  out.textureColorCoordinate = vertexArray[vertexID].textureColorCoordinate;
                  out.textureAlphaCoordinate = vertexArray[vertexID].textureAlphaCoordinate;
                  out.textureMaskCoordinate = vertexArray[vertexID].textureMaskCoordinate;
                  return out;
              }

              fragment float4 vap_yuvFragmentShader(VAPRasterizerData input [[ stage_in ]],
                                                    texture2d<float>  lumaTexture [[ texture(0) ]],
                                                    texture2d<float>  chromaTexture [[ texture(1) ]],
                                                    constant ColorParameters *colorParameters [[ buffer(0) ]]) {
                  //signifies that an expression may be computed at compile-time rather than runtime
                  constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
                  return RGBAColor(textureSampler, input.textureColorCoordinate, input.textureAlphaCoordinate, lumaTexture, chromaTexture, colorParameters);
              }

              fragment float4 vap_maskFragmentShader(VAPRasterizerData input [[ stage_in ]],
                                                    texture2d<float>  lumaTexture [[ texture(0) ]],
                                                    texture2d<float>  chromaTexture [[ texture(1) ]],
                                                    texture2d<float>  maskTexture [[ texture(2) ]],
                                                    constant ColorParameters *colorParameters [[ buffer(0) ]]) {
                  //signifies that an expression may be computed at compile-time rather than runtime
                  constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
                  float4 originColor = RGBAColor(textureSampler, input.textureColorCoordinate, input.textureAlphaCoordinate, lumaTexture, chromaTexture, colorParameters);
                  float4 maskColor = maskTexture.sample(textureSampler, input.textureMaskCoordinate);
                  float needMask = maskColor.r * 255;
                  return float4(originColor.rgb, (1 - needMask) * originColor.a);
              }

              fragment float4 vap_maskBlurFragmentShader(VAPRasterizerData input [[ stage_in ]],
                                                         texture2d<float>  lumaTexture [[ texture(0) ]],
                                                         texture2d<float>  chromaTexture [[ texture(1) ]],
                                                         texture2d<float>  maskTexture [[ texture(2) ]],
                                                         constant ColorParameters *colorParameters [[ buffer(0) ]],
                                                         constant MaskParameters *maskParameters [[ buffer(1) ]]) {
                  //signifies that an expression may be computed at compile-time rather than runtime
                  constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
                  float4 originColor = RGBAColor(textureSampler, input.textureColorCoordinate, input.textureAlphaCoordinate, lumaTexture, chromaTexture, colorParameters);
                  
                  int uniform = 255;
                  float3x3 weightMatrix = maskParameters[0].weightMatrix;
                  int coreSize = maskParameters[0].coreSize;
                  float texelOffset = maskParameters[0].texelOffset;
                  float alphaResult = 0;
                  
                  // 循环9次可以写成for循环
                  for (int y = 0; y < coreSize; y++) {
                      for (int x = 0; x < coreSize; x++) {
                          float2 nearMaskColor = float2(input.textureMaskCoordinate.x +  (-1.0 + float(x)) * texelOffset, input.textureMaskCoordinate.y + (-1.0 + float(y)) * texelOffset);
                          alphaResult += maskTexture.sample(textureSampler, nearMaskColor).r * uniform * weightMatrix[x][y];
                      }
                  }
                  
                  int needOrigin = step(alphaResult, 0.01) + step(originColor.a, 0.01);
                  return float4(originColor.rgb, needOrigin * originColor.a + (1 - needOrigin) * (1 - alphaResult));
              }
              
              vertex VAPAttachmentRasterizerData vapAttachment_vertexShader(uint vertexID [[ vertex_id ]], constant QGHWDAttachmentVertex *vertexArray [[ buffer(0) ]]) {
                  
                  VAPAttachmentRasterizerData out;
                  out.position = vertexArray[vertexID].position;
                  out.sourceTextureCoordinate = vertexArray[vertexID].sourceTextureCoordinate;
                  out.maskTextureCoordinate =  vertexArray[vertexID].maskTextureCoordinate;
                  return out;
              }

              fragment float4 vapAttachment_FragmentShader(VAPAttachmentRasterizerData input [[ stage_in ]],
                                                           texture2d<float>  lumaTexture [[ texture(0) ]],
                                                           texture2d<float>  chromaTexture [[ texture(1) ]],
                                                           texture2d<float>  sourceTexture [[ texture(2) ]],
                                                           constant ColorParameters *colorParameters [[ buffer(0) ]],
                                                           constant VapAttachmentFragmentParameter *fillParams [[ buffer(1) ]]) {
                  
                  constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
                  matrix_float3x3 rotationMatrix = colorParameters[0].matrix;
                  float2 offset = colorParameters[0].offset;
                  float3 mask = RGBColorFromYuvTextures(textureSampler, input.maskTextureCoordinate, lumaTexture, chromaTexture, rotationMatrix, offset);
                  float4 source = sourceTexture.sample(textureSampler, input.sourceTextureCoordinate);
                  return float4(source.rgb, source.a * mask.r);
              }
              );

#endif /* QGHWDMetalShaderSourceDefine_h */
