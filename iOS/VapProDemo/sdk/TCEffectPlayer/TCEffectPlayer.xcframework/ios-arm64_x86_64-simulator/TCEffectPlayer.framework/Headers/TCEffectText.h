// Copyright (c) 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"

NS_ASSUME_NONNULL_BEGIN


enum {
    TCEPTextAlignmentNone = -1,    ///< 默认值
    TCEPTextAlignmentLeft = 0,     ///< 表示文字左对齐
    TCEPTextAlignmentCenter = 1,   ///< 表示文字居中对齐
    TCEPTextAlignmentRight = 2     ///< 表示文字右对齐
};


TCEP_EXPORT @interface TCEffectText : NSObject

/**
 * 文字内容
 * text content
 */
@property(nonatomic, copy) NSString* text;

/**
 * 文字样式，如： “bold”，不填写，则正常字体。
 * Text style, such as "bold", if left blank, normal font will be used
 **/
@property(nonatomic, copy) NSString* fontStyle;

/**
 * 文字大小，默认为0，单位是px （如果设置了此参数，会以此参数固定去显示文字）
 * Font size, default is 0,  in pixels.  (If this display parameter is set, the existing parameters will be fixed to text))
 **/
@property(nonatomic, assign) CGFloat fontSize;

/**
 * 文字对齐方式，取值如: TCEPTextAlignmentLeft   默认为 TCEPTextAlignmentNone
 *
 * Text alignment, value: TCEPTextAlignmentLeft, defalut value is TCEPTextAlignmentNone
 */
@property(nonatomic, assign) int alignment;

/**
 * 字体颜色，格式：ARGB格式。设置颜色，将会覆盖通过 teptool 工具配置的默认文字格式。
 *
 * Font color, format: ARGB format. Setting the color will override the default text format configured by the teptool tool.
 */
@property(nonatomic, copy) UIColor* color;

@end


NS_ASSUME_NONNULL_END
