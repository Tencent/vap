// QGBaseAnimatedImageFrame+Displaying.h
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

#import "QGBaseAnimatedImageFrame.h"

@interface QGBaseAnimatedImageFrame (Displaying)

@property (nonatomic, strong) NSDate *startDate; //开始播放的时间
@property (nonatomic, assign) NSTimeInterval decodeTime; //解码时间

- (BOOL)shouldFinishDisplaying;     //是否需要结束播放（根据播放时长来决定）

@end
