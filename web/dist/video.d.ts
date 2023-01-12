import { VapConfig } from './type';
export default class VapVideo {
    options: VapConfig;
    requestAnim: (cb: any) => number;
    container: HTMLElement;
    video: HTMLVideoElement;
    protected events: {
        [key: string]: Array<(...info: any[]) => void>;
    };
    private _drawFrame;
    protected animId: number;
    protected useFrameCallback: boolean;
    private firstPlaying;
    private setBegin;
    private customEvent;
    setOptions(options: VapConfig): this;
    precacheSource(source: any): Promise<string>;
    initVideo(): void;
    drawFrame(_: any, _info: any): void;
    play(): void;
    pause(): void;
    setTime(t: any): void;
    requestAnimFunc(): (cb: any) => number;
    cancelRequestAnimation(): void;
    clear(): void;
    destroy(): void;
    on(event: any, callback: any): this;
    once(event: any, callback: any): this;
    trigger(eventName: any, ...e: any[]): void;
    offAll(): this;
    onplaying(): void;
    oncanplay(): void;
    onerror(err: any): void;
}
