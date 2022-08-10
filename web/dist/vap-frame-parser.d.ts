export default class FrameParser {
    constructor(source: any, headData: any);
    config: any;
    private headData;
    private frame;
    textureMap: any;
    private canvas;
    private ctx;
    srcData: any;
    init(): Promise<this>;
    initCanvas(): void;
    loadImg(url: string): Promise<unknown>;
    parseSrc(dataJson: any): Promise<void>;
    /**
     * 下载json文件
     * @param jsonUrl json外链
     * @returns {Promise}
     */
    getConfigBySrc(jsonUrl: string): Promise<unknown>;
    /**
     * 文字转换图片
     * @param item
     */
    makeTextImg(item: any): ImageData;
    getFrame(frame: any): any;
}
