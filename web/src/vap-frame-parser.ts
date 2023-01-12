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
export default class FrameParser {
  constructor(source, headData) {
    this.config = source || {};
    this.headData = headData;
    this.frame = [];
    this.textureMap = {};
  }

  public config;
  private headData;
  private frame;
  public textureMap;
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D | null;
  public srcData;

  async init() {
    // 判断是url还是json对象
    if (/\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\.json/.test(this.config)) {
      this.config = await this.getConfigBySrc(this.config);
    }
    await this.parseSrc(this.config);
    this.frame = this.config.frame || [];
    return this;
  }

  initCanvas() {
    if (!this.canvas) {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      canvas.style.display = 'none';
      document.body.appendChild(canvas);
      this.ctx = ctx;
      this.canvas = canvas;
    }
  }

  loadImg(url: string) {
    return new Promise((resolve, reject) => {
      // console.log('load img:', url)
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = function () {
        resolve(this);
      };
      img.onerror = function (e) {
        console.error('frame 资源加载失败:' + url);
        reject(new Error('frame 资源加载失败:' + url));
      };
      img.src = url;
    });
  }

  parseSrc(dataJson) {
    const src = (this.srcData = {});
    return Promise.all(
      (dataJson.src || []).map(async (item) => {
        item.img = null;
        if (!this.headData[item.srcTag.slice(1, item.srcTag.length - 1)] && !this.headData[item.srcTag]) {
          console.warn(`vap: 融合信息没有传入：${item.srcTag}`);
        } else {
          if (item.srcType === 'txt') {
            if (this.headData['fontStyle'] && !item['fontStyle']) {
              item['fontStyle'] = this.headData['fontStyle'];
            }
            item.textStr =
              this.headData[item.srcTag] ||
              item.srcTag.replace(/\[(.*)\]/, ($0, $1) => {
                return this.headData[$1];
              });
            this.initCanvas();
            item.img = this.makeTextImg(item);
          } else if (item.srcType === 'img') {
            item.imgUrl =
              this.headData[item.srcTag] ||
              item.srcTag.replace(/\[(.*)\]/, ($0, $1) => {
                return this.headData[$1];
              });
            try {
              item.img = await this.loadImg(item.imgUrl);
            } catch (e) {}
          }
          if (item.img) {
            src[item.srcId] = item;
          }
        }
      })
    ).then(() => {
      if (this.canvas) {
        this.canvas.parentNode.removeChild(this.canvas);
      }
    });
  }

  /**
   * 下载json文件
   * @param jsonUrl json外链
   * @returns {Promise}
   */
  getConfigBySrc(jsonUrl: string) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', jsonUrl, true);
      xhr.responseType = 'json';
      xhr.onload = function () {
        if (xhr.status === 200 || (xhr.status === 304 && xhr.response)) {
          const res = xhr.response;
          resolve(res);
        } else {
          reject(new Error('http response invalid' + xhr.status));
        }
      };
      xhr.send();
    });
  }

  /**
   * 文字转换图片
   * @param item
   */
  makeTextImg(item) {
    const { textStr, w, h, color, style, fontStyle } = item;
    const ctx = this.ctx;
    ctx.canvas.width = w;
    ctx.canvas.height = h;
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'center';
    const getFontStyle = function () {
      const fontSize = Math.min(w / textStr.length, h - 8); // 需留一定间隙
      const font = [`${fontSize}px`, 'Arial'];
      if (style === 'b') {
        font.unshift('bold');
      }
      return font.join(' ');
    };
    if (!fontStyle) {
      ctx.font = getFontStyle();
      ctx.fillStyle = color;
    } else if (typeof fontStyle == 'string') {
      ctx.font = fontStyle;
      ctx.fillStyle = color;
    } else if (typeof fontStyle == 'object') {
      ctx.font = fontStyle['font'] || getFontStyle();
      ctx.fillStyle = fontStyle['color'] || color;
    } else if (typeof fontStyle == 'function') {
      ctx.font = getFontStyle();
      ctx.fillStyle = color;
      fontStyle.call(null, ctx, item);
    }
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    ctx.fillText(textStr, w / 2, h / 2);
    // console.log('frame : ' + textStr, ctx.canvas.toDataURL('image/png'))
    return ctx.getImageData(0, 0, w, h);
  }
  getFrame(frame) {
    return this.frame.find((item) => {
      return item.i === frame;
    });
  }
}
