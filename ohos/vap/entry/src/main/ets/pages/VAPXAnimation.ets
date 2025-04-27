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

import { MixData, VAPPlayer, VAPColor } from '@ohos/vap';
import { systemDateTime } from '@kit.BasicServicesKit';
import { LogUtil } from '../common/LogUtil';
import { util } from '@kit.ArkTS';
import { FitType } from '@ohos/vap';
import { VAPFontWeight } from '@ohos/vap';
import { VAPTextAlign } from '@ohos/vap';
import { SrcInfo, SrcType } from '@ohos/vap';
import text from '@ohos.graphics.text';

class ColorBean implements VAPColor {
  a: number = 255;
  r: number = 2;
  g: number = 255;
  b: number = 187
}

@Entry
@Component
struct VAPXAnimation {
  private vapPlayer: VAPPlayer | undefined = undefined;
  @State buttonEnabled: boolean = true;
  @State fitType: FitType = FitType.FIT_CENTER;
  @State textAlign: VAPTextAlign = VAPTextAlign.TEXT_ALIGN_LEFT;
  @State fontWeight: VAPFontWeight = VAPFontWeight.NORMAL;
  @State color: ColorBean = new ColorBean;
  @State showColor: number = 0;
  private srcInfo: SrcInfo[] | undefined = undefined
  private playTimes: number = 0;
  private stopTimes: number = 0;
  private pauseTimes: number = 0;
  private colorIdx: number = 0;
  private xComponentId: string = 'xcomponentId_' + util.generateRandomUUID()
  private videoPath: string = getContext(this).filesDir + "/123.mp4";

  @Styles tipTxt() {
    .backgroundColor('#fff')
    .foregroundColor('#000')
  }
  aboutToDisappear(): void {
    LogUtil.info('aboutToDisappear')
    this.vapPlayer?.stop()
  }

  onPageShow(): void {
    LogUtil.info('onPageShow')
    this.showColor = (((this.color.r & 0xff) << 16) | ((this.color.g & 0xff) << 8) | ((this.color.b & 0xff)))
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
    try {
      if (this.srcInfo) {
        let mixData: Array<MixData> = []
        this.srcInfo.map((ele, idx) => {
          if (ele.type == SrcType.IMG) {
            mixData.push({ tag: ele.tag, imgUri: '图片地址' })
          } else if (ele.type == SrcType.TXT) {
            mixData.push({ tag: ele.tag, txt: '文本信息', color: this.color })
          }
        })
        console.log('config mixData: ' + JSON.stringify(mixData))
      } else {
        console.log('error not get srcInfo')
      }

      let opts: Array<MixData> = [];
      if (this.srcInfo != undefined) {
        for (let s of this.srcInfo) {
          if (s.type == SrcType.IMG) {
            opts.push({
              tag: s.tag,
              imgUri: getContext(this).filesDir + '/head1.png'
            })
          } else if (s.type == SrcType.TXT) {
            opts.push({
              tag: s.tag,
              txt: "星河Harmony NEXT 星河Harmony NEXT",
              textAlign: this.textAlign, // VAPTextAlign.TEXT_ALIGN_JUSTIFY对齐方式规格见 https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-text-V5#textalign
              fontWeight: this.fontWeight,
              color: this.color
            })
          }
        }
      }
      this.buttonEnabled = false;

      let startTime = systemDateTime.getTime(true)

      this.vapPlayer?.play(this.videoPath, opts, () => {
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
              let info = this.vapPlayer.getVideoInfo(this.videoPath)
              console.log('getVideoInfo info ' + JSON.stringify(info))
              this.srcInfo = info?.srcInfos
            }
          })
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
          .visibility(this.buttonEnabled ? Visibility.Hidden : Visibility.Visible)

        Scroll() {
          Row({ space: 10 }) {
            Text('色彩分量:').fontWeight(FontWeight.Bold)
            Select([{ value: 'red' }, { value: 'green' }, { value: 'blue' }])
              .selected(0)
              .value('red')
              .onSelect((index: number) => {
                this.colorIdx = index
              })
            TextInput()
              .type(InputType.Number)
              .width(80)
              .maxLength(3)
              .onChange((value: string) => {
                if (this.colorIdx == 0) {
                  this.color.r = Number(value) & 0xff
                } else if (this.colorIdx == 1) {
                  this.color.g = Number(value) & 0xff
                } else if (this.colorIdx == 2) {
                  this.color.b = Number(value) & 0xff
                }
                this.showColor =
                  (((this.color.r & 0xff) << 16) | ((this.color.g & 0xff) << 8) | ((this.color.b & 0xff)))
              })
            Text('当前色彩:').tipTxt().fontWeight(FontWeight.Bold)
            Text().width(20).height(20).backgroundColor(this.showColor)

            Text('视频对齐:').fontWeight(FontWeight.Bold)
            Select([{ value: 'fix_xy' }, { value: 'fix_center' }, { value: 'center_crop' }])
              .selected(1)
              .value('fix_center')
              .onSelect((index: number) => {
                this.fitType = index
              })
            Text('字体权重:').fontWeight(FontWeight.Bold)
            Select([{ value: 'thin' }, { value: 'extra_light' }, { value: 'light' }, { value: 'normal' },
              { value: 'medium' }, { value: 'semi_bold' },
              { value: 'bold' }, { value: 'extra_bold' }, { value: 'black' }])
              .selected(3)
              .value('normal')
              .onSelect((index: number) => {
                this.fontWeight = index
              })
            Text('字体对齐:').fontWeight(FontWeight.Bold)
            Select([{ value: 'left' }, { value: 'right' }, { value: 'center' }, { value: 'justify' },
              { value: 'start' }, { value: 'end' }])
              .selected(0)
              .value('left')
              .onSelect((index: number) => {
                this.textAlign = index
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
        .opacity(0.6)
      }
      .backgroundImage($r('app.media.bg'))
      .backgroundImageSize(ImageSize.FILL)
      .height('93%')
      .width('100%')
      .alignContent(Alignment.Bottom)

      Row() {
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
      .margin({ top: 15 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Bottom)
    }
  }
}