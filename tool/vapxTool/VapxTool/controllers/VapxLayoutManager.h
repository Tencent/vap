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

@interface VapxBox : NSObject

@property (nonatomic, assign) NSRect rect;
@property (nonatomic, assign) BOOL used;
@property (nonatomic, strong) VapxBox *down;
@property (nonatomic, strong) VapxBox *right;

@end

@interface VapxLayoutManager : NSObject

//为了消除编码算法对边界的影响，加上padding
@property (nonatomic, assign) NSEdgeInsets padding;
@property (nonatomic, assign) BOOL classicMode;

- (NSSize)maximumSizeForInfo:(QGVAPConfigModel *)config alphaMinScale:(CGFloat)scale;

- (void)layoutWith:(QGVAPConfigModel *)config desDir:(NSString *)des alphaScale:(CGFloat)scale;

@end

