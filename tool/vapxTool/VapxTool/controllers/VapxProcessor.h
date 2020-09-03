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
#import "VapxFileHelper.h"
#import "VapMergeInfoView.h"

typedef void (^processorCompletionBlock)(BOOL success, NSString *output, NSError* error);
typedef void (^processorProgressBlock)(CGFloat progress);

@interface VapxProcessor : NSObject

@property (nonatomic, strong) VapxFileHelper *fileHelper;

@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger fps;
@property (nonatomic, assign) NSInteger bitrates;
@property (nonatomic, assign) CGFloat alphaScale;
@property (nonatomic, strong) NSString *audioPath;
@property (nonatomic, assign) NSEdgeInsets layoutPadding;
@property (nonatomic, assign) BOOL classicMode;
@property (nonatomic, strong) NSArray<VapMergeInfoView*> *mergeInfoViews;

- (void)process:(processorProgressBlock)progress onCompletion:(processorCompletionBlock)block;

@end
