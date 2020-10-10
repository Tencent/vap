export interface VapConfig {
  container: HTMLElement;
  src: string;
  config: string | {[key:string]:any};
  width: number;
  height: number;
  fps?: number;
  mute?: boolean;
  precache?: boolean;
  [key:string]:any;
}