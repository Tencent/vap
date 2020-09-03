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

#import "VapxFileHelper.h"
#import <AppKit/AppKit.h>

@implementation VapxFileHelper

static NSString *workSpacePath = nil;


- (void)clearCurrentWorkSpace {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    [directoryContent enumerateObjectsUsingBlock:^(NSString *content, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([content.lastPathComponent hasPrefix:@"workspace"]) {
            [fileManager removeItemAtPath:[documentsPath stringByAppendingPathComponent:content] error:nil];
        }
    }];
    workSpacePath = nil;
}

- (void)createCurrentWorkSpaceIfNeed {
    
    [self clearCurrentWorkSpace];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self videoFramesPath]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self videoFramesPath] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if (![fileManager fileExistsAtPath:[self outputPath]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self outputPath] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (![fileManager fileExistsAtPath:[self layoutDir]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self layoutDir] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (![fileManager fileExistsAtPath:[self audioPath]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self audioPath] withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

- (NSString *)saveUploadedAudioFile:(NSURL *)path {
    
    NSString *des = [[self audioPath] stringByAppendingPathComponent:path.lastPathComponent];
    NSError *e = nil;
    [[NSFileManager defaultManager] copyItemAtURL:path toURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", des]] error:&e];
    if (e) {
        NSLog(@"saveUploadedAudioFile error:%@ %@ %@", path, des, e);
    }
    return des;
}

- (void)saveUploadedVideoFrames:(NSArray<NSURL *> *)paths {
    
    [paths enumerateObjectsUsingBlock:^(NSURL * _Nonnull URL, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *des = [[self videoFramesPath] stringByAppendingPathComponent:URL.lastPathComponent];
        NSError *e = nil;
        [[NSFileManager defaultManager] copyItemAtURL:URL toURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", des]] error:&e];
        if (e) {
            NSLog(@"saveUploadedVideoFrames error:%@ %@ %@", URL, des, e);
        }
    }];
}

- (NSString *)saveUploadedMasks:(NSArray<NSURL *> *)paths identifier:(NSString *)identifier {
    
    NSString *maskDir = [self maskPathForIdentifier:identifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:maskDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:maskDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    [paths enumerateObjectsUsingBlock:^(NSURL * _Nonnull URL, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError *e = nil;
        NSString *des = [maskDir stringByAppendingPathComponent:URL.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtURL:URL toURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", des]] error:&e];
        if (e) {
            NSLog(@"saveUploadedMasks error:%@ %@ %@", URL, des, e);
        }
    }];
    return maskDir;
}

- (NSString *)maskPathForIdentifier:(NSString *)identifier {
    return [[self workSpacePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"mask-%@",identifier]];
}

- (NSString *)audioPath {
    return [[self workSpacePath] stringByAppendingPathComponent:@"audio"];
}

- (NSString *)videoFramesPath {
    return [[self workSpacePath] stringByAppendingPathComponent:@"videoFrames"];
}

- (NSString *)outputPath {
    return [[self workSpacePath] stringByAppendingPathComponent:@"output"];
}

- (NSString *)layoutDir {
    return [[self workSpacePath] stringByAppendingPathComponent:@"layout"];
}

- (NSString *)layoutMP4Name {
    return @"layout.mp4";
}

- (NSString *)workSpacePath {
    
    if (workSpacePath) {
        return workSpacePath;
    }
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    workSpacePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"workspace-%@", @(timeInterval)]];
    return workSpacePath;
}

- (NSString *)outputMP4Name {
    return @"vap.mp4";
}

@end
