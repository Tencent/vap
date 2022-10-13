export interface VapConfig {
  container: HTMLElement;
  src: string;
  config: string | { [key: string]: any };
  fps?: number;
  width?: number;
  height?: number;
  // 循环播放
  loop: boolean;
  mute?: boolean;
  precache?: boolean;
  // 使用requestVideoFrameCallback对齐帧数据
  accurate: boolean;
  onLoadError?: (e: ErrorEvent) => void;
  onDestory?: () => void;
  [key: string]: any;
}
