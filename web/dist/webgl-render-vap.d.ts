import { VapConfig } from "./type";
import VapVideo from './video';
export default class WebglRenderVap extends VapVideo {
    constructor(options: VapConfig);
    private insType;
    private textures;
    private buffers;
    private shaders;
    private vapFrameParser;
    private resources;
    private instance;
    private program;
    private videoTexture;
    private aPosition;
    private aTexCoord;
    private aAlphaTexCoord;
    private _imagePos;
    init(): Promise<void>;
    setCanvas(): void;
    initWebGL(): any;
    /**
     * 顶点着色器
     */
    initVertexShader(): any;
    /**
     * 片元着色器
     */
    initFragmentShader(): any;
    initTexture(): void;
    initVideoTexture(): void;
    drawFrame(): void;
    destroy(): void;
    clearMemoryCache(): void;
}
