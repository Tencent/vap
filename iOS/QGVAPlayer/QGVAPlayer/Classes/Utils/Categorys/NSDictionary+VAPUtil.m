// NSDictionary+VAPUtil.m
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

#import "NSDictionary+VAPUtil.h"

#define HWD_RETURN_VALUE(_type_, _default_)                                                     \
if (!key) return _default_;                                                            \
id value = self[key];                                                            \
if (!value || value == [NSNull null]) return _default_;                                \
if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value)._type_;   \
if ([value isKindOfClass:[NSString class]]) return ((NSString *)value)._type_; \
return _default_;

@implementation NSDictionary (VAPUtil)

- (CGFloat)hwd_floatValue:(NSString *)key {
    HWD_RETURN_VALUE(floatValue, 0.0);
}

- (NSInteger)hwd_integerValue:(NSString *)key {
    HWD_RETURN_VALUE(integerValue, 0);
}

- (NSString *)hwd_stringValue:(NSString *)key {
    
    NSString *defaultValue = @"";
    if (!key) return defaultValue;
    id value = self[key];
    if (!value || value == [NSNull null]) return defaultValue;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return defaultValue;
}

- (NSDictionary *)hwd_dicValue:(NSString *)key {
    
    if (!key) {
        return nil;
    }
    id value = self[key];
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return value;
}

- (NSArray *)hwd_arrValue:(NSString *)key {
    
    if (!key) {
        return nil;
    }
    id value = self[key];
    if (![value isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return value;
}

@end
