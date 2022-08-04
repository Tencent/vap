import { VapConfig } from './type';
import VapVideo from './video';
export default class WebglRenderVap extends VapVideo {
    private canvas;
    private gl;
    private vertexShader;
    private fragmentShader;
    private program;
    private textures;
    private buffers;
    private vapFrameParser;
    private aPosition;
    private aTexCoord;
    private aAlphaTexCoord;
    private _imagePos;
    constructor(options?: VapConfig);
    play(options?: VapConfig): this;
    initWebGL(): any;
    /**
     * 顶点着色器
     */
    initVertexShader(gl: WebGLRenderingContext): WebGLShader;
    /**
     * 片元着色器
     */
    initFragmentShader(gl: WebGLRenderingContext): WebGLShader;
    initTexture(): void;
    initVideoTexture(): void;
    drawFrame(_: any, info: any): void;
    clear(): void;
    destroy(): void;
}
