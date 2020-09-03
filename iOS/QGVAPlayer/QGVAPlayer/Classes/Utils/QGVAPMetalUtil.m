// QGVAPMetalUtil.m
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

#import "QGVAPMetalUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "QGVAPLogger.h"
#import <UIKit/UIKit.h>

NSString *const kVAPAttachmentVertexFunctionName = @"vapAttachment_vertexShader";
NSString *const kVAPAttachmentFragmentFunctionName = @"vapAttachment_FragmentShader";
NSString *const kVAPVertexFunctionName = @"vap_vertexShader";
NSString *const kVAPYUVFragmentFunctionName = @"vap_yuvFragmentShader";
NSString *const kVAPMaskFragmentFunctionName = @"vap_maskFragmentShader";
NSString *const kVAPMaskBlurFragmentFunctionName = @"vap_maskBlurFragmentShader";

float const kVAPMTLVerticesIdentity[16] = {-1.0, -1.0, 0.0, 1.0, -1.0, 1.0, 0.0, 1.0, 1.0, -1.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0};
float const kVAPMTLTextureCoordinatesIdentity[8] = {0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0};
float const kVAPMTLTextureCoordinatesFor90[8] = {0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0};

void replaceArrayElements(float arr0[], float arr1[], int size) {
    
    if ((arr0 == NULL || arr1 == NULL) && size > 0) {
        assert(0);
    }
    if (size < 0) {
        assert(0);
    }
    for (int i = 0; i < size; i++) {
        arr0[i] = arr1[i];
    }
}

//倒N形
void genMTLVertices(CGRect rect, CGSize containerSize, float vertices[16], BOOL reverse) {
    
    if (vertices == NULL) {
        VAP_Error(kQGVAPModuleCommon, @"generateMTLVertices params illegal.");
        assert(0);
        return ;
    }
    if (containerSize.width <= 0 || containerSize.height <= 0) {
        VAP_Error(kQGVAPModuleCommon, @"generateMTLVertices params containerSize illegal.");
        assert(0);
        return ;
    }
    float originX, originY, width, height;
    originX = -1+2*rect.origin.x/containerSize.width;
    originY = 1-2*rect.origin.y/containerSize.height;
    width = 2*rect.size.width/containerSize.width;
    height = 2*rect.size.height/containerSize.height;
    
    if (reverse) {
        float tempVertices[] = {originX, originY-height, 0.0, 1.0, originX, originY, 0.0, 1.0, originX+width, originY-height, 0.0, 1.0, originX+width, originY, 0.0, 1.0};
        replaceArrayElements(vertices, tempVertices, 16);
        return ;
    }
    float tempVertices[] = {originX, originY, 0.0, 1.0, originX, originY-height, 0.0, 1.0, originX+width, originY, 0.0, 1.0 , originX+width, originY-height, 0.0, 1.0};
    replaceArrayElements(vertices, tempVertices, 16);
}

//N形
void genMTLTextureCoordinates(CGRect rect, CGSize containerSize, float coordinates[8], BOOL reverse, NSInteger degree) {
    
    //degree预留字段，支持旋转纹理
    if (coordinates == NULL) {
        VAP_Error(kQGVAPModuleCommon, @"generateMTLTextureCoordinates params coordinates illegal.");
        assert(0);
        return ;
    }
    if (containerSize.width <= 0 || containerSize.height <= 0) {
        VAP_Error(kQGVAPModuleCommon, @"generateMTLTextureCoordinates params containerSize illegal.");
        assert(0);
        return ;
    }
    float originX, originY, width, height;
    originX = rect.origin.x/containerSize.width;
    originY = rect.origin.y/containerSize.height;
    width = rect.size.width/containerSize.width;
    height = rect.size.height/containerSize.height;
    
    if (reverse) {
        float tempCoordintes[] = {originX, originY, originX, originY+height , originX+width, originY,originX+width, originY+height};
        replaceArrayElements(coordinates, tempCoordintes, 8);
        return ;
    }
    float tempCoordintes[] = {originX, originY+height, originX, originY, originX+width, originY+height, originX+width, originY};
    replaceArrayElements(coordinates, tempCoordintes, 8);
}

CGSize vapSourceSizeForCenterFull(CGSize sourceSize, CGSize renderSize) {
    
    //source大小完全包含render大小，直接返回中间部分
    if (sourceSize.width >= renderSize.width && sourceSize.height >= renderSize.height) {
        return sourceSize;
    }
    CGRect rectForAspectFill = vapRectWithContentModeInsideRect(CGRectMake(0, 0, renderSize.width, renderSize.height), sourceSize, UIViewContentModeScaleAspectFill);
    return rectForAspectFill.size;
}

CGRect vapRectForCenterFull(CGSize sourceSize, CGSize renderSize) {
    
    //source大小完全包含render大小，直接返回中间部分
    if (sourceSize.width >= renderSize.width && sourceSize.height >= renderSize.height) {
        return CGRectMake((sourceSize.width-renderSize.width)/2.0, (sourceSize.height-renderSize.height)/2.0, renderSize.width, renderSize.height);
    }
    
    CGRect rectForAspectFill = vapRectWithContentModeInsideRect(CGRectMake(0, 0, renderSize.width, renderSize.height), sourceSize, UIViewContentModeScaleAspectFill);
    
    CGRect intersection = CGRectMake(-rectForAspectFill.origin.x, -rectForAspectFill.origin.y, renderSize.width, renderSize.height);
    return intersection;
}

CGRect vapRectWithContentModeInsideRect(CGRect boundingRect, CGSize aspectRatio, UIViewContentMode contentMode) {
    
    if (aspectRatio.width <= 0 || aspectRatio.height <= 0) {
        return boundingRect;
    }
    CGRect desRect = CGRectZero;
    switch (contentMode) {
        case UIViewContentModeScaleToFill: {
            desRect = boundingRect;
        }
            break;
        case UIViewContentModeScaleAspectFit: {
            desRect = AVMakeRectWithAspectRatioInsideRect(aspectRatio, boundingRect);
        }
            break;
        case UIViewContentModeScaleAspectFill: {
            CGFloat ratio = MAX(CGRectGetWidth(boundingRect)/aspectRatio.width, CGRectGetHeight(boundingRect)/aspectRatio.height);
            CGSize contentSize = CGSizeMake(aspectRatio.width*ratio, aspectRatio.height*ratio);
            desRect = CGRectMake(boundingRect.origin.x+(CGRectGetWidth(boundingRect)-contentSize.width)/2.0, boundingRect.origin.y+(CGRectGetHeight(boundingRect)-contentSize.height)/2.0, contentSize.width, contentSize.height);
        }
            break;
        case UIViewContentModeCenter: {
            desRect = CGRectMake(boundingRect.origin.x+(CGRectGetWidth(boundingRect)-aspectRatio.width)/2.0, boundingRect.origin.y+(CGRectGetHeight(boundingRect)-aspectRatio.height)/2.0, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeTop: {
            desRect = CGRectMake(boundingRect.origin.x+(CGRectGetWidth(boundingRect)-aspectRatio.width)/2.0, boundingRect.origin.y, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeBottom: {
            desRect = CGRectMake(boundingRect.origin.x+(CGRectGetWidth(boundingRect)-aspectRatio.width)/2.0, boundingRect.origin.y+CGRectGetHeight(boundingRect)-aspectRatio.height, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeLeft: {
            desRect = CGRectMake(boundingRect.origin.x, boundingRect.origin.y+(CGRectGetHeight(boundingRect)-aspectRatio.height)/2.0, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeRight: {
            desRect = CGRectMake(boundingRect.origin.x+CGRectGetWidth(boundingRect)-aspectRatio.width, boundingRect.origin.y+(CGRectGetHeight(boundingRect)-aspectRatio.height)/2.0, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeTopLeft: {
            desRect = CGRectMake(boundingRect.origin.x, boundingRect.origin.y, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeTopRight: {
            desRect = CGRectMake(boundingRect.origin.x+CGRectGetWidth(boundingRect)-aspectRatio.width, boundingRect.origin.y, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeBottomLeft: {
            desRect = CGRectMake(boundingRect.origin.x, boundingRect.origin.y+CGRectGetHeight(boundingRect)-aspectRatio.height, aspectRatio.width, aspectRatio.height);
        }
            break;
        case UIViewContentModeBottomRight: {
            desRect = CGRectMake(boundingRect.origin.x+CGRectGetWidth(boundingRect)-aspectRatio.width, boundingRect.origin.y+CGRectGetHeight(boundingRect)-aspectRatio.height, aspectRatio.width, aspectRatio.height);
        }
            break;
        default:
            break;
    }
    return desRect;
}

@implementation QGVAPMetalUtil

@end
