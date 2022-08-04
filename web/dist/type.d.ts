export interface VapConfig {
    container: HTMLElement;
    src: string;
    config: string | {
        [key: string]: any;
    };
    fps?: number;
    loop: boolean;
    mute?: boolean;
    precache?: boolean;
    accurate: boolean;
    onLoadError?: (e: ErrorEvent) => void;
    onDestory?: () => void;
    [key: string]: any;
}
