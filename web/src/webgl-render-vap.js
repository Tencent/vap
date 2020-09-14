/*
 * Tencent is pleased to support the open source community by making vap available.
 *
 * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * Licensed under the MIT License (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 *
 * http://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and
 * limitations under the License.
 */
import VapFrameParser from './vap-frame-parser'
import * as glUtil from './gl-util'
import VapVideo from './video'

let clearTimer = null
let instances = {}
const PER_SIZE = 9

function computeCoord(x, y, w, h, vw, vh) {
    // leftX rightX bottomY topY
    return [x / vw, (x + w) / vw, (vh - y - h) / vh, (vh - y) / vh]
}

export default class WebglRenderVap extends VapVideo {
    constructor(options) {
        super(options)
        this.insType = this.options.type
        if (instances[this.insType]) {
            this.instance = instances[this.insType]
        } else {
            this.instance = instances[this.insType] = {}
        }
        this.textures = []
        this.buffers = []
        this.shaders = []
        this.init()
    }

    async init() {
        this.setCanvas()
        if (this.options.config) {
            try {
                this.vapFrameParser = await new VapFrameParser(this.options.config, this.options).init()
                this.resources = this.vapFrameParser.srcData
            } catch (e) {
                console.error('[Alpha video] parse vap frame error.', e)
            }
        }
        this.resources = this.resources || {}
        this.initWebGL()
        this.play()
    }
    setCanvas() {
        let canvas = this.instance.canvas
        const { width, height } = this.options
        if (!canvas) {
            canvas = this.instance.canvas = document.createElement('canvas')
        }
        canvas.width = width
        canvas.height = height
        this.container.appendChild(canvas)
    }

    initWebGL() {
        const { canvas } = this.instance
        let { gl, vertexShader, fragmentShader, program } = this.instance
        if (!canvas) {
            return
        }
        if (!gl) {
            this.instance.gl = gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl')
            gl.enable(gl.BLEND)
            gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
            gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
        }
        if (gl) {
            gl.viewport(0, 0, canvas.width, canvas.height)
            if (!vertexShader) {
                vertexShader = this.instance.vertexShader = this.initVertexShader()
            }
            if (!fragmentShader) {
                fragmentShader = this.instance.fragmentShader = this.initFragmentShader()
            }
            if (!program) {
                program = this.instance.program = glUtil.createProgram(gl, vertexShader, fragmentShader)
            }
            this.program = program
            this.initTexture()
            this.initVideoTexture()
            return gl
        }
    }

    /**
     * 顶点着色器
     */
    initVertexShader() {
        const { gl } = this.instance
        return glUtil.createShader(
            gl,
            gl.VERTEX_SHADER,
            `attribute vec2 a_position; // 接受顶点坐标
             attribute vec2 a_texCoord; // 接受纹理坐标
             attribute vec2 a_alpha_texCoord; // 接受纹理坐标
             varying vec2 v_alpha_texCoord; // 接受纹理坐标
             varying   vec2 v_texcoord; // 传递纹理坐标给片元着色器
             void main(void){
                gl_Position = vec4(a_position, 0.0, 1.0); // 设置坐标
                v_texcoord = a_texCoord; // 设置纹理坐标
                v_alpha_texCoord = a_alpha_texCoord; // 设置纹理坐标
             }`
        )
    }

    /**
     * 片元着色器
     */
    initFragmentShader() {
        const { gl } = this.instance
        const bgColor = `vec4(texture2D(u_image_video, v_texcoord).rgb, texture2D(u_image_video,v_alpha_texCoord).r);`
        const textureSize = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS) - 1
        // const textureSize =0
        let sourceTexure = ''
        let sourceUniform = ''
        if (textureSize > 0) {
            const imgColor = []
            for (let i = 0; i < textureSize; i++) {
                imgColor.push(
                    `if(ndx == ${i}){
                        color = texture2D(textures[${i}],uv);
                    }`
                )
            }

            sourceUniform = `
            uniform sampler2D u_image[${textureSize}];
            uniform float image_pos[${textureSize * PER_SIZE}];
            vec4 getSampleFromArray(sampler2D textures[${textureSize}], int ndx, vec2 uv) {
                vec4 color;
                ${imgColor.join(' else ')}
                return color;
            }
            `
            sourceTexure = `
            vec4 srcColor,maskColor;
            vec2 srcTexcoord,maskTexcoord;
            int srcIndex;
            float x1,x2,y1,y2,mx1,mx2,my1,my2; //显示的区域

            for(int i=0;i<${textureSize * PER_SIZE};i+= ${PER_SIZE}){
                if ((int(image_pos[i]) > 0)) {
                  srcIndex = int(image_pos[i]);
    
                    x1 = image_pos[i+1];
                    x2 = image_pos[i+2];
                    y1 = image_pos[i+3];
                    y2 = image_pos[i+4];
                    
                    mx1 = image_pos[i+5];
                    mx2 = image_pos[i+6];
                    my1 = image_pos[i+7];
                    my2 = image_pos[i+8];
    
    
                    if (v_texcoord.s>x1 && v_texcoord.s<x2 && v_texcoord.t>y1 && v_texcoord.t<y2) {
                        srcTexcoord = vec2((v_texcoord.s-x1)/(x2-x1),(v_texcoord.t-y1)/(y2-y1));
                         maskTexcoord = vec2(mx1+srcTexcoord.s*(mx2-mx1),my1+srcTexcoord.t*(my2-my1));
                         srcColor = getSampleFromArray(u_image,srcIndex,srcTexcoord);
                         maskColor = texture2D(u_image_video, maskTexcoord);
                         srcColor.a = srcColor.a*(maskColor.r);
                      
                         bgColor = vec4(srcColor.rgb*srcColor.a,srcColor.a) + (1.0-srcColor.a)*bgColor;
                      
                    }   
                }
            }
            `
        }

        const fragmentSharder = `
        precision lowp float;
        varying vec2 v_texcoord;
        varying vec2 v_alpha_texCoord;
        uniform sampler2D u_image_video;
        ${sourceUniform}
        
        void main(void) {
            vec4 bgColor = ${bgColor}
            ${sourceTexure}
            // bgColor = texture2D(u_image[0], v_texcoord);
            gl_FragColor = bgColor;
        }
        `
        return glUtil.createShader(gl, gl.FRAGMENT_SHADER, fragmentSharder)
    }

    initTexture() {
        const { gl } = this.instance
        let i = 1
        if (!this.vapFrameParser || !this.vapFrameParser.srcData) {
            return
        }
        const resources = this.vapFrameParser.srcData
        for (const key in resources) {
            const resource = resources[key]
            this.textures.push(glUtil.createTexture(gl, i, resource.img))
            const sampler = gl.getUniformLocation(this.program, `u_image[${i}]`)
            gl.uniform1i(sampler, i)
            this.vapFrameParser.textureMap[resource.srcId] = i++
        }
        const dumpTexture = gl.createTexture()
        gl.activeTexture(gl.TEXTURE0)
        gl.bindTexture(gl.TEXTURE_2D, dumpTexture)
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

        this.videoTexture = glUtil.createTexture(gl, i)
        const sampler = gl.getUniformLocation(this.program, `u_image_video`)
        gl.uniform1i(sampler, i)
    }

    initVideoTexture() {
        const { gl } = this.instance
        const vertexBuffer = gl.createBuffer()
        this.buffers.push(vertexBuffer)
        if (!this.vapFrameParser || !this.vapFrameParser.config || !this.vapFrameParser.config.info) {
            return
        }
        const info = this.vapFrameParser.config.info
        const ver = []
        const { videoW: vW, videoH: vH } = info
        const [rgbX, rgbY, rgbW, rgbH] = info.rgbFrame
        const [aX, aY, aW, aH] = info.aFrame
        const rgbCoord = computeCoord(rgbX, rgbY, rgbW, rgbH, vW, vH)
        const aCoord = computeCoord(aX, aY, aW, aH, vW, vH)
        ver.push(...[-1, 1, rgbCoord[0], rgbCoord[3], aCoord[0], aCoord[3]])
        ver.push(...[1, 1, rgbCoord[1], rgbCoord[3], aCoord[1], aCoord[3]])
        ver.push(...[-1, -1, rgbCoord[0], rgbCoord[2], aCoord[0], aCoord[2]])
        ver.push(...[1, -1, rgbCoord[1], rgbCoord[2], aCoord[1], aCoord[2]])
        const view = new Float32Array(ver)
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer)
        gl.bufferData(gl.ARRAY_BUFFER, view, gl.STATIC_DRAW)

        this.aPosition = gl.getAttribLocation(this.program, 'a_position')
        gl.enableVertexAttribArray(this.aPosition)
        this.aTexCoord = gl.getAttribLocation(this.program, 'a_texCoord')
        gl.enableVertexAttribArray(this.aTexCoord)
        this.aAlphaTexCoord = gl.getAttribLocation(this.program, 'a_alpha_texCoord')
        gl.enableVertexAttribArray(this.aAlphaTexCoord)
        // 将缓冲区对象分配给a_position变量、a_texCoord变量
        const size = view.BYTES_PER_ELEMENT
        gl.vertexAttribPointer(this.aPosition, 2, gl.FLOAT, false, size * 6, 0) // 顶点着色器位置
        gl.vertexAttribPointer(this.aTexCoord, 2, gl.FLOAT, false, size * 6, size * 2) // rgb像素位置
        gl.vertexAttribPointer(this.aAlphaTexCoord, 2, gl.FLOAT, false, size * 6, size * 4) // rgb像素位置
    }

    drawFrame() {
        const gl = this.instance.gl
        if (!gl) {
            super.drawFrame()
            return
        }
        gl.clear(gl.COLOR_BUFFER_BIT)
        if (this.vapFrameParser) {
            const frame = Math.floor(this.video.currentTime * this.options.fps)
            const frameData = this.vapFrameParser.getFrame(frame)
            let posArr = []

            if (frameData && frameData.obj) {
                frameData.obj.forEach((frame, index) => {
                    posArr[posArr.length] = +this.vapFrameParser.textureMap[frame.srcId]

                    const info = this.vapFrameParser.config.info
                    const { videoW: vW, videoH: vH } = info
                    const [x, y, w, h] = frame.frame
                    const [mX, mY, mW, mH] = frame.mFrame
                    const coord = computeCoord(x, y, w, h, vW, vH)
                    const mCoord = computeCoord(mX, mY, mW, mH, vW, vH)
                    posArr = posArr.concat(coord).concat(mCoord)
                })
            }
            //
            const size = (gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS) - 1) * PER_SIZE
            posArr = posArr.concat(new Array(size - posArr.length).fill(0))
            this._imagePos = this._imagePos || gl.getUniformLocation(this.program, 'image_pos')
            gl.uniform1fv(this._imagePos, new Float32Array(posArr))
        }
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, this.video) // 指定二维纹理方式
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
        super.drawFrame()
    }

    destroy() {
        const { canvas, gl } = this.instance
        if (this.textures && this.textures.length) {
            for (let i = 0; i < this.textures.length; i++) {
                gl.deleteTexture(this.textures[i])
            }
        }
        if (canvas) {
            canvas.parentNode && canvas.parentNode.removeChild(canvas)
        }
        // glUtil.cleanWebGL(gl, this.shaders, this.program, this.textures, this.buffers)
        super.destroy()
        this.clearMemoryCache()
    }

    clearMemoryCache() {
        if (clearTimer) {
            clearTimeout(clearTimer)
        }

        clearTimer = setTimeout(() => {
            instances = {}
        }, 30 * 60 * 1000)
    }
}
