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

import { VAPPlayer, VapState } from '@ohos/vap';
import { systemDateTime } from '@kit.BasicServicesKit';
import { LogUtil } from '../common/LogUtil';
import { util } from '@kit.ArkTS';
import { FitType, MixData, VideoMode } from '@ohos/vap';
import { router } from '@kit.ArkUI';

// 场景： 应用开屏效果， 可点击跳过
@Entry
@Component
struct GeneralAnimation {
  private vapPlayer: VAPPlayer | undefined = undefined;
  @State showVideo: boolean = true;
  @State fitType: FitType = FitType.CENTER_CROP;
  private videoName: string = "demo.mp4";
  private xComponentId: string = 'xComponentId_xx';

  aboutToDisappear(): void {
    LogUtil.info('aboutToDisappear')
  }

  onPageShow(): void {
    LogUtil.info('onPageShow')
  }

  onPageHide(): void {
    LogUtil.info('onPageHide')
    this.vapPlayer?.stop()
  }

  on() {
    this.vapPlayer?.on('stateChange', (state, ret) => {
      LogUtil.info(`vapPlayer on state: ${state}`)
      if (state === VapState.COMPLETE) {
        LogUtil.info(`vapPlayer play complete: ${state}`)
      }
      if (state === VapState.FAILED && ret) {
        LogUtil.error(`vapPlayer error: ${JSON.stringify(ret)}`)
      }
      if (state === VapState.DESTROY) {
        this.vapPlayer = undefined
        this.showVideo = false;
        LogUtil.info(`vapPlayer DESTROY: ${state}`)
      }
    })
  }

  play() {
    if (this.vapPlayer === undefined) {
      LogUtil.error('plz create XComponent first')
      return
    }

    this.on();

    this.vapPlayer?.setFitType(this.fitType)
    this.vapPlayer?.setVideoMode(VideoMode.VIDEO_MODE_SPLIT_HORIZONTAL)
    try {
      let opts: Array<MixData> = [];

      let startTime = systemDateTime.getTime(true)

      this.vapPlayer?.play(getContext(this).filesDir + "/" + this.videoName, opts, () => {
        LogUtil.info("js get callback")
        this.showVideo = false
      });
      let endTime = systemDateTime.getTime(true)
      LogUtil.info(" play cost " + (endTime - startTime) / 1000)
    } catch (e) {
      LogUtil.error(" play error " + JSON.stringify(e));
    }
  }

  pause() {
    try {
      let startTime = systemDateTime.getTime(true);
      this.vapPlayer?.pause();
      let endTime = systemDateTime.getTime(true)
      LogUtil.info(" pause cost " + (endTime - startTime) / 1000)
    } catch (e) {
      LogUtil.error(" pause error " + JSON.stringify(e));
    }
  }

  stop() {
    try {
      let startTime = systemDateTime.getTime(true);
      this.vapPlayer?.stop();
      let endTime = systemDateTime.getTime(true)
      LogUtil.info("stop cost " + (endTime - startTime) / 1000)
    } catch (e) {
      LogUtil.error("stop error " + JSON.stringify(e));
    }
  }

  build() {
    Column() {
      Stack() {
        if (!this.showVideo) {
          Column() {
            Button("返回")
              .onClick(() => {
                router.back()
              })
            Text("进入主页")
            Text("占位文本")
              .width('100%')
              .textAlign(TextAlign.Center)
              .border({ width: 1 })
              .padding(10)
              .fontColor(Color.Blue)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .height('100%')
        } else {
          XComponent({
            id: this.xComponentId,
            type: 'surface',
            libraryname: 'vap'
          })
            .onLoad((context?: object) => {
              if (context) {
                this.vapPlayer = new VAPPlayer(this.xComponentId);
                this.vapPlayer.setContext(context);
              }
              this.play()
            })
            .backgroundColor(Color.Transparent)
            .width('100%')
            .height('100%')

          Button('Skip')
            .fontWeight(500)
            .onClick(() => {
              this.stop()
              this.showVideo = false
              this.vapPlayer = undefined //必须，建议使用之前的visibility控制显示 容器都没了，还能调用方法！！！
            })
            .borderRadius(4)
            .height(40)
            .width(200)
        }
      }.backgroundImage($r('app.media.bg'))
      .backgroundImageSize(ImageSize.FILL)
      .height('100%')
      .width('100%')
    }
  }
}