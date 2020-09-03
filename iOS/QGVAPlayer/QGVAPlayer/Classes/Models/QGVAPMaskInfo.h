// QGVAPMaskInfo.h
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
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

typedef NSUInteger QGVAPMaskValues;

NS_ASSUME_NONNULL_BEGIN

// 如果要更新data、rect、size必须重新创建QGVAPMaskInfo对象
@interface QGVAPMaskInfo : NSObject

/** mask数据 0/1 Byte */
@property (nonatomic, strong) NSData *data;
/** 采样范围 与datasize单位一致 */
@property (nonatomic, assign) CGRect sampleRect;
/** mask 大小 单位pixel */
@property (nonatomic, assign) CGSize dataSize;
/** 模糊范围，单位pixel */
@property (nonatomic, assign) NSInteger blurLength;
/** mask纹理 */
@property (nonatomic, strong, readonly) id<MTLTexture> texture;

@end

NS_ASSUME_NONNULL_END
