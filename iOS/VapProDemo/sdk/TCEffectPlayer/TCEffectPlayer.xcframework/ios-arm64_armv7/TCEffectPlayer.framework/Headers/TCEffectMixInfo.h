// Copyright (c) 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"

NS_ASSUME_NONNULL_BEGIN

@class TCEffectMixItem;
TCEP_EXPORT @interface TCEffectMixInfo : NSObject

@property (nonatomic, strong) NSArray<TCEffectMixItem *> *textMixItemList;
@property (nonatomic, strong) NSArray<TCEffectMixItem *> *imageMixItemList;

@end

TCEP_EXPORT @interface TCEffectMixItem : NSObject

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
