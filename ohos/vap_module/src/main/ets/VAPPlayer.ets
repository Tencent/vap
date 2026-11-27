/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { AnimConfig, FitType, MixData, VideoInfo, VideoMode, XComponentContext } from './DataDeclare';

import { downloadFile } from './HttpReq';

export class VAPPlayer implements XComponentContext {
  private vapContext: XComponentContext | null = null;
  public loops: number = 1;
  private jsCbfn?: () => void;
  private uri = ''
  private mixData: Array<MixData> = []
  public sandDir = ''

  setContext(context: object): void {
    this.vapContext = context as XComponentContext;
  }

  getVideoInfo(uri: string): VideoInfo | undefined {
    if (this.vapContext) {
      return this.vapContext.getVideoInfo(uri);
    }
    return undefined
  }

  doneFn = () => {
    console.log('enter doneFn loops ' + this.loops)
    this.loops--;
    if (this.loops > 0) {
      this.vapContext?.play(this.uri, this.mixData, this.doneFn);
      console.log('loops ' + this.loops)
    } else {
      this.loops = 1
      this.jsCbfn ? this.jsCbfn() : ''
    }
  }

  async play(uri: string, mixData?: Array<MixData>, cbFn?: () => void): Promise<void> {
    if (mixData) {
      this.mixData = []
      for (let element of mixData) {
        if (element.imgUri) {
          element.imgUri = await downloadFile(element.imgUri, this.sandDir)
        }
        this.mixData.push(element)
      }
    }
    this.uri = await downloadFile(uri, this.sandDir)

    this.jsCbfn = cbFn
    console.log('mPlayOption ' + JSON.stringify(this.mixData))
    this.vapContext?.play(this.uri, this.mixData, this.doneFn);
  }

  on(type: string, callback: (state?: number | string, ret?: number | AnimConfig) => void) {
    this.vapContext?.on(type, callback);
  }

  pause(): void {
    this.vapContext?.pause();
  }

  stop(): void {
    this.vapContext?.stop();
    this.loops = 1;
  }

  setLoop(loops: number): void {
    this.loops = loops
  }

  setFitType(fitType: FitType): void {
    this.vapContext?.setFitType(fitType);
  }

  setVideoMode(videoMode: VideoMode): void {
    this.vapContext?.setVideoMode(videoMode);
  }
}