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

import { util } from '@kit.ArkTS';
import {
  AnimConfig,
  FitType,
  MixData,
  SrcInfo,
  VideoInfo,
  XComponentContext,
  VAPColor,
  VAPTextAlign,
  VAPFontWeight
} from './DataDeclare';
import { LogUtil } from './LogUtil';
import { downloadFile } from './HttpReq'
import { systemDateTime } from '@kit.BasicServicesKit';

class MaPosition {
  public width: number = 200
  public height: number = 30
  public top: number = 0
  public left: number = 0
}

export class MixInputDataBean implements MixData {
  tag: string;
  txt?: string;
  imgUri?: string;
  color?: VAPColor
  fontWeight?: VAPFontWeight
  textAlign?: VAPTextAlign

  constructor(tag: string) {
    this.tag = tag
  }
}

export class VideoInfoBean implements VideoInfo {
  srcInfos: SrcInfo[] = [];
  width: number = 0;
  height: number = 0;
}
;

export class VideoSize {
  width?: number = undefined;
  height?: number = undefined;
}
;

@Component
export struct VAPComponent {
  private vapContext: XComponentContext | null = null;
  public loops: number = 1;
  private jsCbfn?: () => void;
  private uri = ''
  private mixData: Array<MixData> = new Array
  private fitType: FitType = FitType.FIT_XY
  private videoSize: VideoInfoBean = new VideoInfoBean
  public sandDir = '' // 使用网络资源需要设置该属性
  public mCmpController: VAPComponentController | null = null;
  @State isRunning: boolean = false;
  @State containerWidth: number = 0;
  @State containerHeight: number = 0
  @State vapPosition: MaPosition = new MaPosition

  aboutToDisappear() {
    LogUtil.info('[lifeCycle] VAPComponent aboutToDisappear')
  }

  setFitType(fitType: FitType) {
    LogUtil.info(' setFitType ' + this.fitType + '  ' + fitType)
    if (fitType != this.fitType) {
      this.fitType = fitType
      this.vapContext?.setFitType(fitType);
    }
  }

  aboutToAppear() {
    LogUtil.info('[lifeCycle] VAPComponent aboutToAppear')
    if (this.mCmpController) {
      this.mCmpController.attach(this); // 绑定控制器
    }
  }

  async play(uri: string, mixData?: Array<MixData>, cbFn?: () => void) {
    if (this.isRunning) {
      return
    }
    this.isRunning = true;

    this.uri = await downloadFile(uri, this.sandDir)
    if (mixData) {
      for (let element of mixData) {
        if (element.imgUri) {
          element.imgUri = await downloadFile(element.imgUri, this.sandDir)
        }
        this.mixData.push(element)
      }
    }

    this.jsCbfn = cbFn
    this.vapContext?.play(this.uri, this.mixData, this.doneFn);
  }

  doneFn = () => {
    LogUtil.log('enter doneFn loops ' + this.loops)
    this.isRunning = false;
    this.loops--;
    if (this.loops > 0) {
      this.vapContext?.play(this.uri, this.mixData, this.doneFn);
      LogUtil.log('loops ' + this.loops)
    } else {
      this.loops = 1
      this.jsCbfn ? this.jsCbfn() : ''
    }
  }

  pause() {
    if (!this.isRunning) {
      return
    }
    this.vapContext?.pause();
  }

  getVideoInfo(uri: string) {
    return this.vapContext?.getVideoInfo(uri);
  }

  stop() {
    if (!this.isRunning) {
      return
    }
    this.vapContext?.stop();
    this.loops = 1;
  }

  setLoop(loops: number): void {
    this.loops = loops
  }

  on(type: string, callback: (state?: number | string, ret?: number | AnimConfig) => void) {
    this.vapContext?.on(type, callback);
  }

  private fitXy() {
    this.vapPosition.width = this.containerWidth
    this.vapPosition.height = this.containerHeight
    this.vapPosition.top = 0
    this.vapPosition.left = 0
  }

  private changeArea() {
    this.fitXy()
    LogUtil.log("vapPosition " + JSON.stringify(this.vapPosition))
  }

  build() {
    Stack() {
      XComponent({
        id: 'XComponentId_' + util.generateRandomUUID(),
        type: 'surface',
        libraryname: 'vap'
      })
        .onLoad((context?: object) => {
          if (context) {
            this.vapContext = context as XComponentContext;
          }
        })
        .backgroundColor(Color.Transparent)
        .width(this.vapPosition.width)
        .height(this.vapPosition.height)
        .visibility(this.isRunning ? Visibility.Visible : Visibility.Hidden)
        .onAreaChange((old, new1) => {
          LogUtil.info('XComponent onAreaChange newWidth ' + old.width + ' newHeight ' + old.height +
            ' width ' + new1.width + ' height ' + new1.height)
        })
    }
    .height('100%')
    .width('100%')
    .onAreaChange((old, new1) => {
      LogUtil.info('onAreaChange newWidth ' + old.width + ' newHeight ' + old.height +
        ' width ' + new1.width + ' height ' + new1.height)
      this.containerWidth = new1.width as number
      this.containerHeight = new1.height as number
      if (this.videoSize) {
        this.changeArea()
      }
    })
  }
}

export class VAPComponentController {
  private mComponent: VAPComponent | null = null;

  attach(component: VAPComponent) {
    this.mComponent = component;
  }

  play(uri: string, mixData?: Array<MixData>, cbFn?: () => void): void {
    if (this.mComponent) {
      this.mComponent.play(uri, mixData, cbFn);
    }
  }

  pause(): void {
    if (this.mComponent) {
      return this.mComponent.pause();
    }
  }

  stop(): void {
    if (this.mComponent) {
      return this.mComponent.stop();
    }
  }

  setFitType(fitType: FitType): void {
    if (this.mComponent) {
      return this.mComponent.setFitType(fitType);
    }
  }

  getVideoInfo(uri: string): VideoInfo | undefined {
    if (this.mComponent) {
      return this.mComponent.getVideoInfo(uri);
    }
    return undefined
  }
}
