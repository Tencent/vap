export interface VapConfig {
    container: HTMLElement;
    src: string;
    config: string | {
        [key: string]: any;
    };
    width: number;
    height: number;
    fps?: number;
    mute?: boolean;
    precache?: boolean;
    onLoadError?: (e: ErrorEvent) => void;
    onDestory?: () => void;
    [key: string]: any;
}
