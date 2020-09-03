// QGVAPMetalShaderFunctionLoader.m
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

#import "QGVAPMetalShaderFunctionLoader.h"
#import "QGHWDMetalShaderSourceDefine.h"
#import "QGHWDShaderTypes.h"
#import "QGVAPLogger.h"

@interface QGVAPMetalShaderFunctionLoader () {
    
    BOOL _alreadyLoadDefaultLibrary;
    BOOL _alreadyLoadHWDLibrary;
}

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLLibrary> defaultLibrary;
@property (nonatomic, strong) id<MTLLibrary> hwdLibrary;

@end

@implementation QGVAPMetalShaderFunctionLoader

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    
    if (self = [super init]) {
        _device = device;
    }
    return self;
}

- (id<MTLFunction>)loadFunctionWithName:(NSString *)funcName {
    
    id<MTLFunction> program = nil;
    [self loadDefaultLibraryIfNeed];
    program = [self.defaultLibrary newFunctionWithName:funcName];
    //没有找到defaultLibrary文件 || defaultLibrary中不包含对应的fucntion
    if (!program) {
        [self loadHWDLibraryIfNeed];
        program = [self.hwdLibrary newFunctionWithName:funcName];
    }
    return program;
}

- (void)loadDefaultLibraryIfNeed {
    
    if (self.defaultLibrary || _alreadyLoadDefaultLibrary) {
        return ;
    }
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *metalLibPath = [bundle pathForResource:@"default" ofType:@"metallib"];
    if (metalLibPath.length == 0) {
        return ;
    }
    NSError *error = nil;
    id<MTLLibrary> defaultLibrary = [self.device newLibraryWithFile:metalLibPath error:&error];
    if (!defaultLibrary || error) {
        VAP_Error(kQGVAPModuleCommon, @"loadDefaultLibrary error!:%@", error);
        return ;
    }
    self.defaultLibrary = defaultLibrary;
    _alreadyLoadDefaultLibrary = YES;
}

- (void)loadHWDLibraryIfNeed {
    
    if (self.hwdLibrary || _alreadyLoadHWDLibrary) {
        return ;
    }
    NSError *error = nil;
    NSString *sourceString = [NSString stringWithFormat:@"%@%@%@", kQGHWDMetalShaderSourceImports, kQGHWDMetalShaderTypeDefines, kQGHWDMetalShaderSourceString];
    id<MTLLibrary> hwdLibrary = [self.device newLibraryWithSource:sourceString options:nil error:&error];
    if (!hwdLibrary || error) {
        VAP_Error(kQGVAPModuleCommon, @"loadHWDLibrary error!:%@", error);
        return ;
    }
    self.hwdLibrary = hwdLibrary;
    _alreadyLoadHWDLibrary = YES;
}

@end
