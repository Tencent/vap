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

export default class VapVideo {
  public options: VapConfig;
  public requestAnim: (cb: any) => number;
  public container: HTMLElement;
  public video: HTMLVideoElement;
  protected events: { [key: string]: Array<(...info: any[]) => void> } = {};
  private _drawFrame: () => void;
  protected animId: number;
  protected useFrameCallback: boolean;
  private firstPlaying = true;
  private setBegin: boolean;
  private customEvent: Array<string> = ['frame', 'percentage', ''];

  setOptions(options: VapConfig) {
    if (!options.container || !options.src) {
      console.warn('[Alpha video]: options container and src cannot be empty!');
    }
    this.options = Object.assign(
      {
        // 视频url
        src: '',
        // 循环播放
        loop: false,
        fps: 20,
        // 容器
        container: null,
        // 是否预加载视频资源
        precache: false,
        // 是否静音播放
        mute: false,
        config: '',
        accurate: false,
        // 帧偏移, 一般没用, 预留支持问题素材
        offset: 0,
      },
      options
    );
    this.setBegin = true;
    this.useFrameCallback = false;
    this.container = this.options.container;
    if (!this.options.src || !this.options.config || !this.options.container) {
      console.error('参数出错：src(视频地址)、config(配置文件地址)、container(dom容器)');
    }
    return this;
  }

  precacheSource(source): Promise<string> {
    const URL = (window as any).webkitURL || window.URL;
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', source, true);
      xhr.responseType = 'blob';
      xhr.onload = function () {
        if (xhr.status === 200 || xhr.status === 304) {
          const res = xhr.response;
          if (/iphone|ipad|ipod/i.test(navigator.userAgent)) {
            const fileReader = new FileReader();

            fileReader.onloadend = function () {
              const resultStr = fileReader.result as string;
              const raw = atob(resultStr.slice(resultStr.indexOf(',') + 1));
              const buf = Array(raw.length);
              for (let d = 0; d < raw.length; d++) {
                buf[d] = raw.charCodeAt(d);
              }
              const arr = new Uint8Array(buf);
              const blob = new Blob([arr], { type: 'video/mp4' });
              resolve(URL.createObjectURL(blob));
            };
            fileReader.readAsDataURL(xhr.response);
          } else {
            resolve(URL.createObjectURL(res));
          }
        } else {
          reject(new Error('http response invalid' + xhr.status));
        }
      };
      xhr.send();
    });
  }

  initVideo() {
    const options = this.options;
    // 创建video
    let video = this.video;
    if (!video) {
      video = this.video = document.createElement('video');
    }
    video.crossOrigin = 'anonymous';
    video.autoplay = false;
    video.preload = 'auto';
    video.setAttribute('playsinline', '');
    video.setAttribute('webkit-playsinline', '');
    if (options.mute) {
      video.muted = true;
      video.volume = 0;
    }
    video.style.display = 'none';
    video.loop = !!options.loop;
    if (options.precache) {
      this.precacheSource(options.src)
        .then((blob) => {
          console.log('sample precached.');
          video.src = blob;
          document.body.appendChild(video);
        })
        .catch((e) => {
          console.error(e);
        });
    } else {
      video.src = options.src;
      // 这里要插在body上，避免container移动带来无法播放的问题
      document.body.appendChild(this.video);
      video.load();
    }

    this.firstPlaying = true;
    if ('requestVideoFrameCallback' in this.video) {
      this.useFrameCallback = !!this.options.accurate;
    }
    this.cancelRequestAnimation();

    // 绑定事件
    this.offAll();
    ['playing', 'error', 'canplay'].forEach((item) => {
      this.on(item, this['on' + item].bind(this));
    });
  }

  drawFrame(_, _info) {
    this._drawFrame = this._drawFrame || this.drawFrame.bind(this);
    if (this.useFrameCallback) {
      // @ts-ignore
      this.animId = this.video.requestVideoFrameCallback(this._drawFrame);
    } else {
      this.animId = this.requestAnim(this._drawFrame);
    }
  }

  play() {
    if (this.useFrameCallback) {
      // @ts-ignore
      this.animId = this.video.requestVideoFrameCallback(this.drawFrame.bind(this));
    } else {
      this.requestAnim = this.requestAnimFunc();
    }

    const prom = this.video && this.video.play();
    if (prom && prom.then) {
      prom.catch((e) => {
        if (!this.video) {
          return;
        }
        this.video.muted = true;
        this.video.volume = 0;
        this.video.play().catch((e) => {
          this.trigger('error', e);
        });
      });
    }
  }

  pause() {
    this.video && this.video.pause();
  }

  setTime(t) {
    if (this.video) {
      this.video.currentTime = t;
    }
  }

  requestAnimFunc() {
    const { fps = 30 } = this.options;
    if (window.requestAnimationFrame) {
      let index = -1;
      return (cb) => {
        index++;
        return requestAnimationFrame(() => {
          if (!(index % (60 / fps))) {
            return cb();
          }
          this.animId = this.requestAnim(cb);
        });
      };
    }
    return function (cb) {
      return window.setTimeout(cb, 1000 / fps);
    };
  }

  cancelRequestAnimation() {
    if (!this.animId) {
      return;
    }
    if (this.useFrameCallback) {
      try {
        // @ts-ignore
        this.video.cancelVideoFrameCallback(this.animId);
      } catch (e) {
        console.error(e);
      }
    } else if (window.cancelAnimationFrame) {
      cancelAnimationFrame(this.animId);
    } else {
      clearTimeout(this.animId);
    }
    this.animId = 0;
  }

  clear() {
    this.cancelRequestAnimation();
  }

  destroy() {
    this.cancelRequestAnimation();
    if (this.video) {
      this.offAll();
      this.video.parentNode && this.video.parentNode.removeChild(this.video);
      this.video = null;
    }
    this.options.onDestroy && this.options.onDestroy();
  }

  on(event, callback: any) {
    const cbs = this.events[event] || [];
    cbs.push(callback);
    this.events[event] = cbs;
    if (this.customEvent.indexOf(event) === -1) {
      this.video.addEventListener(event, callback);
    }
    return this;
  }

  once(event, callback: any) {
    const once = (...e) => {
      const cbs = this.events[event];
      cbs.splice(cbs.indexOf(once), 1);
      this.video.removeEventListener(event, once);
      callback(...e);
    };
    return this.on(event, once);
  }

  trigger(eventName, ...e) {
    try {
      (this.events[eventName] || []).forEach((item) => {
        item(...e);
      });
    } catch (e) {
      console.error(e);
    }
  }

  offAll() {
    Object.keys(this.events).forEach((name) => {
      const cbs = this.events[name];
      if (cbs && cbs.length) {
        cbs.forEach((cb) => {
          this.video.removeEventListener(name, cb);
        });
      }
    });
    this.events = {};
    return this;
  }

  onplaying() {
    if (this.firstPlaying) {
      this.firstPlaying = false;
      if (!this.useFrameCallback) {
        this.drawFrame(null, null);
      }
    }
  }

  oncanplay() {
    const begin = this.options.beginPoint;
    if (begin && this.setBegin) {
      this.setBegin = false;
      this.video.currentTime = begin;
    }
  }

  onerror(err) {
    console.error('[Alpha video]: play error: ', err);
    this.destroy();
    this.options.onLoadError && this.options.onLoadError(err);
  }
}
