import { VapConfig } from './type';
import VapVideo from './video';
export default class WebglRenderVap extends VapVideo {
    private canvas;
    private gl;
    private vertexShader;
    private fragmentShader;
    private program;
    private textures;
    private videoTexture;
    private vertexBuffer;
    private vapFrameParser;
    private imagePosLoc;
    constructor(options?: VapConfig);
    play(options?: VapConfig): this;
    initWebGL(): WebGLRenderingContext;
    /**
     * 顶点着色器
     */
    initVertexShader(gl: WebGLRenderingContext): WebGLShader;
    /**
     * 片元着色器
     */
    initFragmentShader(gl: WebGLRenderingContext, textureSize: any): WebGLShader;
    initTexture(): void;
    initVideoTexture(): void;
    drawFrame(_: any, info: any): void;
    clear(): void;
    destroy(): void;
}
