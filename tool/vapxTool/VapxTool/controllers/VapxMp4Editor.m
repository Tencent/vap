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

#import "VapxMp4Editor.h"

@implementation VapxMp4Editor

- (NSString *)mp4ByInsertAtom:(NSString *)atomPath atIndex:(NSInteger)index {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.inputPath.length == 0 || ![fileManager fileExistsAtPath:self.inputPath]) {
        return nil;
    }
    
    NSString *ffmpegPath = [[NSBundle mainBundle] pathForResource:@"mp4edit" ofType:@""];
    NSString *output = self.outputPath;
    
    NSArray *arguments = @[@"--insert", [NSString stringWithFormat:@":%@:%@", atomPath, @(index)], self.inputPath, output];
    
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
