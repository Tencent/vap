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

import { DownloadData, VAPPlayer } from '@ohos/vap';
import { systemDateTime } from '@kit.BasicServicesKit';
import { LogUtil } from '../common/LogUtil';
import { util } from '@kit.ArkTS';
import { VAPComponent, FitType, MixData, VideoMode } from '@ohos/vap';

@Entry
@Component
struct GeneralAnimation {
  private vapPlayer: VAPPlayer | undefined = undefined;
  @State buttonEnabled: boolean = true;
  @State fitType: FitType = FitType.FIT_CENTER;
  private playTimes: number = 0;
  private stopTimes: number = 0;
  private pauseTimes: number = 0;
  private xComponentId: string = 'xcomponentId_' + util.generateRandomUUID();

  aboutToDisappear(): void {
    LogUtil.info('aboutToDisappear')
    this.vapPlayer?.stop()
  }

  onPageShow(): void {
    LogUtil.info('onPageShow')
  }

  onPageHide(): void {
    LogUtil.info('onPageHide')
    this.vapPlayer?.stop()
  }

  play() {
    if (this.vapPlayer === undefined) {
      LogUtil.error('plz create XComponent first')
      return
    }
    this.vapPlayer?.setFitType(this.fitType)
    this.vapPlayer?.setVideoMode(VideoMode.VIDEO_MODE_SPLIT_HORIZONTAL)
    try {
      let opts: Array<MixData> = new Array();
      this.buttonEnabled = false;

      this.vapPlayer?.setDownloadAttribute(50000, (data: DownloadData) => {
        console.log(`download progress: ${JSON.stringify(data)}`);
      });

      let startTime = systemDateTime.getTime(true)

      this.vapPlayer?.setLoop(3); // 动画循环播放3次
      this.vapPlayer?.play(getContext(this).filesDir + "/great_gift.mp4", opts, () => {
        LogUtil.info("js get callback")
        this.buttonEnabled = true;
      });
      let endTime = systemDateTime.getTime(true)
      LogUtil.info(this.playTimes + " play cost " + (endTime - startTime) / 1000)
    } catch (e) {
      LogUtil.error(this.playTimes + " play error " + JSON.stringify(e));
    }
    this.playTimes++;
  }

  pause() {
    try {
      let startTime = systemDateTime.getTime(true);
      this.vapPlayer?.pause();
      let endTime = systemDateTime.getTime(true)
      LogUtil.info(this.pauseTimes + " pause cost " + (endTime - startTime) / 1000)
    } catch (e) {
      LogUtil.error(this.pauseTimes + " pause error " + JSON.stringify(e));
    }
    this.pauseTimes++;
  }

  stop() {
    try {
      let startTime = systemDateTime.getTime(true);
      this.vapPlayer?.stop();
      let endTime = systemDateTime.getTime(true)
      LogUtil.info(this.stopTimes + " stop cost " + (endTime - startTime) / 1000)
    } catch (e) {
      LogUtil.error(this.stopTimes + " stop error " + JSON.stringify(e));
    }
    this.stopTimes++;
  }

  build() {
    Column() {
      Stack() {
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
          })
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
          .visibility(this.buttonEnabled ? Visibility.Hidden : Visibility.Visible)
      }.backgroundImage($r('app.media.bg'))
      .backgroundImageSize(ImageSize.FILL)
      .height('90%')
      .width('100%')

      Scroll() {
        Row() {
          Select([{ value: 'fix_xy' }, { value: 'fix_center' }, { value: 'center_crop' }])
            .selected(1)
            .value('fix_center')
            .onSelect((index: number) => {
              console.info('Select: ' + index)
              this.fitType = index
            })
          Button('Play')
            .fontWeight(500)
            .onClick(() => {
              this.play()
            })
            .width('200')
            .enabled(this.buttonEnabled)
          Button('pause')
            .onClick(() => {
              this.pause()
            })
          Button('stop')
            .onClick(() => {
              this.stop()
            })
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .padding({ bottom: 10 })
      .margin({ left: 5, right: 5 })
      .border({
        color: Color.Grey,
        style: BorderStyle.Solid,
        radius: 5,
        width: 2
      })
      .backgroundColor(Color.White)
    }
  }
}