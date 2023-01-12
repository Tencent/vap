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
import { VapConfig } from './type';
import VapFrameParser from './vap-frame-parser';
import * as glUtil from './gl-util';
import VapVideo from './video';

const PER_SIZE = 9;

function computeCoord(x: number, y: number, w: number, h: number, vw: number, vh: number) {
  // leftX rightX bottomY topY
  return [x / vw, (x + w) / vw, (vh - y - h) / vh, (vh - y) / vh];
}

export default class WebglRenderVap extends VapVideo {
  private canvas: HTMLCanvasElement;
  private gl: WebGLRenderingContext;
  private vertexShader: WebGLShader;
  private fragmentShader: WebGLShader;
  private program: WebGLProgram;
  private textures: WebGLTexture[] = [];
  private videoTexture: WebGLTexture;
  private vertexBuffer: WebGLBuffer;
  private vapFrameParser: VapFrameParser;
  private imagePosLoc: WebGLUniformLocation;

  constructor(options?: VapConfig) {
    super();
    if (options) {
      this.play(options);
    }
  }

  play(options?: VapConfig) {
    if (options) {
      this.setOptions(options);
    }
    if (!this.options?.config) {
      console.error(`options.config cannot be empty.`);
      return this;
    }
    if (options) {
      this.initVideo();
      // 重新解析
      this.vapFrameParser = new VapFrameParser(this.options.config, this.options);
      this.vapFrameParser
        .init()
        .then(() => {
          this.initWebGL();
          this.initTexture();
          this.initVideoTexture();
          this.options.fps = this.vapFrameParser.config.info.fps || 30;
          super.play();
        })
        .catch((e) => {
          this.vapFrameParser = null;
          console.error('[Alpha video] parse vap frame error.', e);
          return this;
        });
    } else {
      super.play();
    }
    return this;
  }

  initWebGL() {
    let { canvas, gl, vertexShader, fragmentShader, program } = this;
    const { width, height } = this.options;
    if (!canvas) {
      canvas = document.createElement('canvas');
    }
    const { vapFrameParser } = this;
    const { w, h } = vapFrameParser.config.info;
    canvas.width = width || w;
    canvas.height = height || h;
    this.container.appendChild(canvas);

    if (!gl) {
      gl = canvas.getContext('webgl') || (canvas.getContext('experimental-webgl') as WebGLRenderingContext);
      gl.disable(gl.BLEND);
      gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
    }
    gl.viewport(0, 0, canvas.width, canvas.height);

    if (!vertexShader) {
      vertexShader = this.initVertexShader(gl);
    }

    if (fragmentShader && program) {
      glUtil.cleanWebGL(gl, { program, shaders: [fragmentShader] });
    }

    const { srcData } = vapFrameParser;
    fragmentShader = this.initFragmentShader(gl, Object.keys(srcData).length);
    program = glUtil.createProgram(gl, vertexShader, fragmentShader);

    this.canvas = canvas;
    this.gl = gl;
    this.vertexShader = vertexShader;
    this.fragmentShader = fragmentShader;
    this.program = program;
    this.imagePosLoc = null;
    return gl;
  }

  /**
   * 顶点着色器
   */
  initVertexShader(gl: WebGLRenderingContext) {
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
    );
  }

  /**
   * 片元着色器
   */
  initFragmentShader(gl: WebGLRenderingContext, textureSize) {
    const bgColor = `vec4(texture2D(u_image_video, v_texcoord).rgb, texture2D(u_image_video,v_alpha_texCoord).r);`;
    let sourceTexure = '';
    let sourceUniform = '';

    if (textureSize > 0) {
      const bufferSize = textureSize * PER_SIZE;
      const imgColor = [];
      const samplers = [];
      for (let i = 0; i < textureSize; i++) {
        imgColor.push(
          `if(ndx == ${i + 1}){
                color = texture2D(u_image${i + 1},uv);
            }`
        );
        samplers.push(`uniform sampler2D u_image${i + 1};`);
      }

      sourceUniform = `
            ${samplers.join('\n')}
            uniform float image_pos[${bufferSize}];
            vec4 getSampleFromArray(int ndx, vec2 uv) {
                vec4 color;
                ${imgColor.join(' else ')}
                return color;
            }
            `;
      sourceTexure = `
            vec4 srcColor,maskColor;
            vec2 srcTexcoord,maskTexcoord;
            int srcIndex;
            float x1,x2,y1,y2,mx1,mx2,my1,my2; //显示的区域

            for(int i=0;i<${bufferSize};i+= ${PER_SIZE}){
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
                         srcColor = getSampleFromArray(srcIndex,srcTexcoord);
                         maskColor = texture2D(u_image_video, maskTexcoord);
                         srcColor.a = srcColor.a*(maskColor.r);
                      
                         bgColor = vec4(srcColor.rgb*srcColor.a,srcColor.a) + (1.0-srcColor.a)*bgColor;
                      
                    }   
                }
            }
            `;
    }

    const fragmentShader = `
        precision lowp float;
        varying vec2 v_texcoord;
        varying vec2 v_alpha_texCoord;
        uniform sampler2D u_image_video;
        ${sourceUniform}
        
        void main(void) {
            vec4 bgColor = ${bgColor}
            ${sourceTexure}
            gl_FragColor = bgColor;
        }
        `;
    return glUtil.createShader(gl, gl.FRAGMENT_SHADER, fragmentShader);
  }

  initTexture() {
    const { gl, vapFrameParser, textures } = this;
    if (!vapFrameParser || !vapFrameParser.srcData) {
      return;
    }

    const resources = vapFrameParser.srcData;
    // 0分配给video
    let i = 1;
    for (const key in resources) {
      const resource = resources[key];
      const texture = textures[i - 1];
      if (texture) {
        // 复用
        gl.activeTexture(gl.TEXTURE0 + i);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, resource.img);
      } else {
        this.textures.push(glUtil.createTexture(gl, i, resource.img));
      }
      const sampler = gl.getUniformLocation(this.program, `u_image${i}`);
      gl.uniform1i(sampler, i);
      this.vapFrameParser.textureMap[resource.srcId] = i++;
    }
  }

  initVideoTexture() {
    const { gl, vapFrameParser, program } = this;
    if (!vapFrameParser || !vapFrameParser.config || !vapFrameParser.config.info) {
      return;
    }

    // video texture
    if (!this.videoTexture) {
      this.videoTexture = glUtil.createTexture(gl, 0);
    }

    const sampler = gl.getUniformLocation(program, `u_image_video`);
    gl.uniform1i(sampler, 0);
    gl.activeTexture(gl.TEXTURE0);

    const info = vapFrameParser.config.info;
    const { videoW: vW, videoH: vH } = info;
    const [rgbX, rgbY, rgbW, rgbH] = info.rgbFrame;
    const [aX, aY, aW, aH] = info.aFrame;
    const rgbCoord = computeCoord(rgbX, rgbY, rgbW, rgbH, vW, vH);
    const aCoord = computeCoord(aX, aY, aW, aH, vW, vH);
    const view = new Float32Array([
      ...[-1, 1, rgbCoord[0], rgbCoord[3], aCoord[0], aCoord[3]],
      ...[1, 1, rgbCoord[1], rgbCoord[3], aCoord[1], aCoord[3]],
      ...[-1, -1, rgbCoord[0], rgbCoord[2], aCoord[0], aCoord[2]],
      ...[1, -1, rgbCoord[1], rgbCoord[2], aCoord[1], aCoord[2]],
    ]);

    if (!this.vertexBuffer) {
      this.vertexBuffer = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);
    }
    gl.bufferData(gl.ARRAY_BUFFER, view, gl.STATIC_DRAW);

    // 将缓冲区对象分配给a_position变量、a_texCoord变量
    const size = view.BYTES_PER_ELEMENT;
    const aPosition = gl.getAttribLocation(program, 'a_position');
    gl.enableVertexAttribArray(aPosition);
    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, size * 6, 0); // 顶点着色器位置

    const aTexCoord = gl.getAttribLocation(program, 'a_texCoord');
    gl.enableVertexAttribArray(aTexCoord);
    gl.vertexAttribPointer(aTexCoord, 2, gl.FLOAT, false, size * 6, size * 2); // rgb像素位置

    const aAlphaTexCoord = gl.getAttribLocation(program, 'a_alpha_texCoord');
    gl.enableVertexAttribArray(aAlphaTexCoord);
    gl.vertexAttribPointer(aAlphaTexCoord, 2, gl.FLOAT, false, size * 6, size * 4); // rgb像素位置
  }

  drawFrame(_, info) {
    const { gl, vapFrameParser, video, options } = this;
    if (!gl) {
      super.drawFrame(_, info);
      return;
    }

    const frame =
      !options.loop && info?.presentedFrames > 0
        ? info.presentedFrames - 1
        : Math.round(video.currentTime * options.fps) + options.offset;
    // console.info('frame:', info.presentedFrames - 1, Math.round(this.video.currentTime * this.options.fps));
    const frameData = vapFrameParser.getFrame(frame);

    if (frameData?.obj) {
      let posArr = [];
      const { videoW: vW, videoH: vH, rgbFrame } = vapFrameParser.config.info;
      frameData.obj.forEach((frame) => {
        // 有可能用户没有传入src
        const imgIndex = vapFrameParser.textureMap[frame.srcId];
        if (imgIndex > 0) {
          posArr[posArr.length] = imgIndex;
          // frame坐标是最终展示坐标，这里glsl中计算使用视频坐标
          const [rgbX, rgbY] = rgbFrame;
          const [x, y, w, h] = frame.frame;
          const [mX, mY, mW, mH] = frame.mFrame;
          const coord = computeCoord(x + rgbX, y + rgbY, w, h, vW, vH);
          const mCoord = computeCoord(mX, mY, mW, mH, vW, vH);
          posArr = posArr.concat(coord).concat(mCoord);
        }
      });
      if (posArr.length) {
        this.imagePosLoc = this.imagePosLoc || gl.getUniformLocation(this.program, 'image_pos');
        gl.uniform1fv(this.imagePosLoc, new Float32Array(posArr));
      }
    }

    this.trigger('frame', frame + 1, frameData, vapFrameParser.config);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, video); // 指定二维纹理方式
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    super.drawFrame(_, info);
  }

  // 清理数据,为下一次播放做准备
  clear() {
    super.clear();
    const { gl } = this;
    // 清除界面，解决连续播放时，第一帧是上一个mp4最后一帧的问题
    gl.clear(gl.COLOR_BUFFER_BIT);
  }

  // 销毁,释放webgl资源,销毁后调用play,资源会重新初始化
  destroy() {
    super.destroy();
    const { canvas, gl, vertexShader, fragmentShader, program, textures, videoTexture, vertexBuffer } = this;
    if (canvas) {
      canvas.parentNode && canvas.parentNode.removeChild(canvas);
      this.canvas = null;
    }
    if (gl) {
      glUtil.cleanWebGL(gl, {
        program,
        shaders: [vertexShader, fragmentShader],
        textures: [...textures, videoTexture],
        buffers: [vertexBuffer],
      });
    }

    this.gl = null;
    this.vertexShader = null;
    this.fragmentShader = null;
    this.program = null;
    this.imagePosLoc = null;
    this.vertexBuffer = null;
    this.videoTexture = null;
    this.textures = [];
  }
}
