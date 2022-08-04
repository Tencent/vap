export declare function createShader(gl: WebGLRenderingContext, type: number, source: string): WebGLShader;
export declare function createProgram(gl: WebGLRenderingContext, vertexShader: WebGLShader, fragmentShader: WebGLShader): WebGLProgram;
export declare function createTexture(gl: WebGLRenderingContext, index: number, imgData?: TexImageSource): WebGLTexture;
export declare function cleanWebGL(gl: WebGLRenderingContext, { shaders, program, textures, buffers }: {
    shaders?: any[];
    program?: any;
    textures?: any[];
    buffers?: any[];
}): void;
