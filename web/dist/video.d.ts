/// <reference types="node" />
import { VapConfig } from "./type";
export default class VapVideo {
    constructor(options: any);
    options: VapConfig;
    private fps;
    requestAnim: Function;
    container: HTMLElement;
    video: HTMLVideoElement;
    protected events: any;
    private _drawFrame;
    protected animId: number;
    protected useFrameCallback: boolean;
    private firstPlaying;
    private setBegin;
    private customEvent;
    precacheSource(source: any): Promise<string>;
    initVideo(): void;
    drawFrame(_: any, info: any): void;
    play(): void;
    pause(): void;
    setTime(t: any): void;
    requestAnimFunc(): ((cb: any) => number) | ((cb: any) => NodeJS.Timeout);
    cancelRequestAnimation(): void;
    destroy(): void;
    clear(): void;
    on(event: any, callback: any): this;
    onplaying(): void;
    onpause(): void;
    onended(): void;
    oncanplay(): void;
    onerror(err: any): void;
}
