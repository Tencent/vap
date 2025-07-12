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

export enum VAPFontWeight {
  // 100-900
  THIN,
  EXTRA_LIGHT,
  LIGHT,
  NORMAL,
  MEDIUM,
  SEMI_BOLD,
  BOLD,
  EXTRA_BOLD,
  BLACK
}
;

export interface VAPColor {
  a: number,
  r: number,
  g: number,
  b: number
}
;

export enum VAPTextAlign {
  TEXT_ALIGN_LEFT,
  TEXT_ALIGN_RIGHT,
  TEXT_ALIGN_CENTER,
  TEXT_ALIGN_JUSTIFY,
  TEXT_ALIGN_START,
  TEXT_ALIGN_END,
}
;

export interface MixData {
  tag: string
  txt?: string
  imgUri?: string
  color?: VAPColor
  fontWeight?: VAPFontWeight
  textAlign?: VAPTextAlign
}
;

export enum FitType {
  FIT_XY,
  FIT_CENTER,
  CENTER_CROP,
}

export enum VapState {
  UNKNOWN,
  READY,
  START,
  RENDER,
  COMPLETE,
  DESTROY,
  FAILED
}
;

export enum Orien {
  ORIEN_DEFAULT = 0, // 兼容模式
  ORIEN_PORTRAIT, // 适配竖屏的视频
  ORIEN_LANDSCAPE // 适配横屏的视频
}
;

export interface PointRect {
  x: number,
  y: number,
  w: number,
  h: number
}
;

export interface AnimConfig {
  version: number
  totalFrames: number
  width: number
  height: number
  videoWidth: number
  videoHeight: number
  orien: Orien
  fps: number
  isMix: boolean
  alphaPointRect: PointRect
  rgbPointRect: PointRect
  currentFrame: number
}
;

export enum SrcType {
  UNKNOWN,
  IMG,
  TXT,
}
;

export interface SrcInfo {
  tag: string;
  type: SrcType;
}
;

export interface VideoInfo {
  width: number;
  height: number;
  srcInfos: Array<SrcInfo>
}
;

export enum VideoMode {
  // 视频对齐方式 (兼容老版本视频模式)
  VIDEO_MODE_SPLIT_HORIZONTAL = 1, // 视频左右对齐（alpha左\rgb右）
  VIDEO_MODE_SPLIT_VERTICAL, // 视频上下对齐（alpha上\rgb下）
  VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE, // 视频左右对齐（rgb左\alpha右）
  VIDEO_MODE_SPLIT_VERTICAL_REVERSE // 视频上下对齐（rgb上\alpha下）
};

export enum VAPSpeed {
  VAP_Speed_1_00_X = 1.0,
  VAP_Speed_0_50_X = 0.5,
  VAP_Speed_1_50_X = 1.5,
  VAP_Speed_2_00_X = 2.0
};

export interface XComponentContext {
  play(uri: string, mixData?: Array<MixData>, cbFn?: () => void, id?:string): void

  on(type: string, callback: (state?: VapState | string, ret?: number | AnimConfig | undefined) => void, id?: string): void

  off(type: string, id?:string): void

  pause(id?:string): void

  stop(id?:string): void

  setLoop(loops: number, id?: string): void

  getVideoInfo(uri: string, id?: string): VideoInfo | undefined

  setFitType(fitType: FitType, id?: string): void

  setVideoMode(videoMode: VideoMode, id?: string): void

  setSpeed(speed: VAPSpeed, id?: string): void
};

export class DownloadData {
  receiveSize: number = 0;
  totalSize: number = 0;
};