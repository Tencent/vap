export default class FrameParser {
    constructor(source: any, headData: any);
    private config;
    private headData;
    private frame;
    private textureMap;
    private canvas;
    private ctx;
    private srcData;
    init(): Promise<this>;
    initCanvas(): void;
    loadImg(url: string): Promise<unknown>;
    parseSrc(dataJson: any): Promise<[unknown, unknown, unknown, unknown, unknown, unknown, unknown, unknown, unknown, unknown]>;
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
