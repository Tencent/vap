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

#import "VapxMP4Decoder.h"
#import "AppDelegate.h"

@implementation VapxMP4Decoder

+ (NSString *)encodeWithDir:(NSString *)directory outputName:(NSString *)output fps:(NSInteger)fps bitRate:(NSString *)bitRate audioPath:(NSString *)audioPath {
    
    VapxMP4Decoder *encoder = [VapxMP4Decoder new];
    encoder.resourceDirectory = directory;
    encoder.outputName = output;
    encoder.fps = fps;
    encoder.bitRate = bitRate;
    encoder.audioPath = audioPath;
    return [encoder encode];
}

- (NSString *)encode {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.resourceDirectory.length == 0 || ![fileManager fileExistsAtPath:self.resourceDirectory]) {
        return nil;
    }
    if (!self.outputName) {
        return nil;
    }
    NSString *ffmpegPath = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@""];
    NSString *inputPath = [self.resourceDirectory stringByAppendingPathComponent:@"*.png"];
    __block NSString *outputName = self.outputName;
    __block BOOL isVp9;
    dispatch_sync(dispatch_get_main_queue(), ^{
         isVp9 = [[(AppDelegate *)[NSApplication sharedApplication].delegate encoder] isEqualToString:@"libvpx-vp9"];
        if (isVp9) {
            outputName = [outputName stringByReplacingOccurrencesOfString:@"mp4" withString:@"webm"];
        }
    });
    
    __block BOOL isH265;
    dispatch_sync(dispatch_get_main_queue(), ^{
        isH265 = [[(AppDelegate *)[NSApplication sharedApplication].delegate encoder] isEqualToString:@"libx265"];
    });
    
    NSString *output = [self.resourceDirectory stringByAppendingPathComponent:outputName];
    
    if ([fileManager fileExistsAtPath:output]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:output error:&error];
        if (error) {
            NSLog(@"removeItemAtPath:%@ fail!", output);
            return nil;
        }
    }
    NSMutableArray *arguments = nil;
    
    // high 3.0  main 4.0
    if (isH265) {
        arguments = [@[@"-r", [NSString stringWithFormat:@"%@", @(MAX(self.fps, 1))],
                               @"-pattern_type", @"glob",
                               @"-i", inputPath,
                               @"-c:v", @"libx265",
                               @"-pix_fmt", self.yuvFormat?:@"yuv420p",
                               @"-profile:v", self.profile?:@"main",
                               @"-level",@"4.0",
                               @"-b:v", self.bitRate?: @"2000k",
                               /*@"-bf", @"0",*/
                               /*@"-crf", @"28",*/
                               @"-tag:v", @"hvc1",
                               @"-bufsize", @"2000k", output] mutableCopy];
    } else if (isVp9) {
        arguments = [@[@"-framerate", [NSString stringWithFormat:@"%@", @(MAX(self.fps, 1))],
                       @"-pattern_type", @"glob",
                                   @"-i", inputPath,
                                   @"-c:v", @"libvpx-vp9",
                                   @"-pix_fmt", self.yuvFormat?:@"yuv420p",
                                   @"-b:v", self.bitRate?: @"2000k",
                                   @"-bufsize", @"2000k", output] mutableCopy];
    } else {
        arguments = [@[@"-r", [NSString stringWithFormat:@"%@", @(MAX(self.fps, 1))],
                               @"-pattern_type", @"glob",
                               @"-i", inputPath,
                               @"-c:v", @"libx264",
                               @"-pix_fmt", self.yuvFormat?:@"yuv420p",
                               @"-profile:v", self.profile?:@"main",
                               @"-level",@"4.0",
                               @"-b:v", self.bitRate?: @"2000k",
                               @"-bf", @"0",
                               /*@"-crf", @"28",*/
                               @"-bufsize", @"2000k", output] mutableCopy];
    }
    
    if (self.audioPath.length > 0) {
        
        if (isVp9) {
            [arguments insertObjects:@[@"-i",self.audioPath,@"-c:a",@"libopus",@"-ab", @"112k"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(6, 6)]];
        } else {
            [arguments insertObjects:@[@"-i",self.audioPath,@"-c:a",@"aac",@"-ab", @"112k"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(6, 6)]];
        }
    }
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle * read = [pipe fileHandleForReading];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: ffmpegPath];
    [task setArguments: arguments];
    [task setStandardOutput: pipe];
    [task launch];
    [task waitUntilExit];

    NSData* data = [read readDataToEndOfFile];
    NSString* stringOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"stringOutput:%@, terminationStatus:%i",stringOutput, [task terminationStatus]);
    return output;
}

@end
