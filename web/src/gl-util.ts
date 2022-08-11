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
export function createShader(gl: WebGLRenderingContext, type: number, source: string) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  // if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
  //     console.error(gl.getShaderInfoLog(shader))
  // }
  return shader;
}

export function createProgram(gl: WebGLRenderingContext, vertexShader: WebGLShader, fragmentShader: WebGLShader) {
  const program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  // if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
  //     console.error(gl.getProgramInfoLog(program))
  // }
  gl.useProgram(program);
  return program;
}

export function createTexture(gl: WebGLRenderingContext, index: number, imgData?: TexImageSource) {
  const texture = gl.createTexture();
  const textrueIndex = gl.TEXTURE0 + index;
  gl.activeTexture(textrueIndex);
  gl.bindTexture(gl.TEXTURE_2D, texture);
  // gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  if (imgData) {
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, imgData);
  }
  return texture;
}

export function cleanWebGL(gl: WebGLRenderingContext, { shaders = [], program = null, textures = [], buffers = [] }) {
  try {
    textures.forEach((t) => {
      gl.deleteTexture(t);
    });
    buffers.forEach((b) => {
      gl.deleteBuffer(b);
    });
    if (program) {
      shaders.forEach((shader) => {
        gl.detachShader(program, shader);
        gl.deleteShader(shader);
      });
      gl.deleteProgram(program);
    }
  } catch (e) {}
}
