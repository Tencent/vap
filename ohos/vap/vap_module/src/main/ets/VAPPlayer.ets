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
import { AnimConfig, FitType, MixData,
  VAPSpeed,
  VapState, VideoInfo, VideoMode, XComponentContext, DownloadData } from './DataDeclare';

import { downloadFile } from './HttpReq';

export class VAPPlayer implements XComponentContext {
  private vapContext: XComponentContext | null = null;
  private loops: number = 1;
  private jsCbfn?: () => void;
  private uri = ''
  private mixData: Array<MixData> = []
  public sandDir = ''
  private id: string = ''
  private downloadTimeout: number = 60000; // ms
  private downloadCallback: (data: DownloadData) => void = (data: DownloadData) => {};

  constructor(id: string) {
    this.id = id
  }

  setContext(context: object): void {
    this.vapContext = context as XComponentContext;
  }

  getVideoInfo(uri: string): VideoInfo | undefined {
    if (this.vapContext) {
      return this.vapContext.getVideoInfo(uri, this.id);
    }
    return undefined
  }

  doneFn = () => {
    console.log('enter doneFn loops ' + this.loops)
    this.loops--;
    if (this.loops > 0) {
      this.vapContext?.play(this.uri, this.mixData, this.doneFn, this.id);
      console.log('loops ' + this.loops)
    } else {
      this.loops = 1
      this.jsCbfn ? this.jsCbfn() : ''
    }
  }

  setDownloadAttribute(dTime: number, downloadProgress?: (data: DownloadData) => void) {
    this.downloadTimeout = dTime;
    if (downloadProgress) {
      this.downloadCallback = downloadProgress;
    }
  }

  async play(uri: string, mixData?: Array<MixData>, cbFn?: () => void): Promise<void> {
    if (mixData) {
      this.mixData = []
      for (let element of mixData) {
        if (element.imgUri) {
          element.imgUri = await downloadFile(element.imgUri, this.downloadTimeout, this.sandDir, this.downloadCallback)
        }
        this.mixData.push(element)
      }
    }
    this.uri = await downloadFile(uri, this.downloadTimeout, this.sandDir, this.downloadCallback)

    this.jsCbfn = cbFn
    console.log('mPlayOption ' + JSON.stringify(this.mixData))
    this.vapContext?.play(this.uri, this.mixData, this.doneFn, this.id);
  }

  on(type: string, callback: (state?: VapState | string, ret?: number | AnimConfig | undefined) => void) {
    this.vapContext?.on(type, callback, this.id);
  }

  off(type: string) {
    this.vapContext?.off(type, this.id)
  }

  pause(): void {
    this.vapContext?.pause(this.id);
  }

  stop(): void {
    this.vapContext?.stop(this.id);
    this.loops = 1;
  }

  setLoop(loops: number): void {
    this.loops = loops
  }

  setFitType(fitType: FitType): void {
    this.vapContext?.setFitType(fitType, this.id);
  }

  setVideoMode(videoMode: VideoMode): void {
    this.vapContext?.setVideoMode(videoMode, this.id);
  }

  setSpeed(speed: VAPSpeed): void {
    this.vapContext?.setSpeed(speed, this.id);
  }
}