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
import {VapConfig} from "./type";

export default class VapVideo {
  constructor(options) {
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
        // 视频宽度
        width: 375,
        // 视频高度
        height: 375,
        // 容器
        container: null,
        // 是否预加载视频资源
        precache: false,
        // 是否静音播放
        mute: false,
        config: '',
        accurate: false
      },
      options
    );
    this.fps = 20;
    this.setBegin = true;
    this.useFrameCallback = false;
    this.requestAnim = this.requestAnimFunc();
    this.container = this.options.container;
    if (!this.options.src || !this.options.config || !this.options.container) {
      console.error('参数出错：src(视频地址)、config(配置文件地址)、container(dom容器)');
    } else {
      // 创建video
      this.initVideo();
    }
  }

  public options:VapConfig;
  private fps:number;
  public requestAnim:Function;
  public container:HTMLElement;
  public video:HTMLVideoElement;
  private events;
  private _drawFrame: Function;
  private animId: number;
  private useFrameCallback: boolean;
  private firstPlaying: boolean;
  private setBegin: boolean;

  precacheSource(source): Promise<string> {
    const URL = (window as any).webkitURL || window.URL;
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open("GET", source, true);
      xhr.responseType = "blob";
      xhr.onload = function() {
        if (xhr.status === 200 || xhr.status === 304) {
          const res = xhr.response;
          if (/iphone|ipad|ipod/i.test(navigator.userAgent)) {
            const fileReader = new FileReader();

            fileReader.onloadend = function() {
              const resultStr = (fileReader.result as string);
              const raw = atob(
                resultStr.slice(resultStr.indexOf(",") + 1)
              );
              const buf = Array(raw.length);
              for (let d = 0; d < raw.length; d++) {
                buf[d] = raw.charCodeAt(d);
              }
              const arr = new Uint8Array(buf);
              const blob = new Blob([arr], { type: "video/mp4" });
              resolve(URL.createObjectURL(blob));
            };
            fileReader.readAsDataURL(xhr.response);
          } else {
            resolve(URL.createObjectURL(res));
          }
        } else {
          reject(new Error("http response invalid" + xhr.status));
        }
      };
      xhr.send();
    });
  }


  initVideo() {
    const options = this.options;
    // 创建video
    const video = (this.video = document.createElement('video'));
    video.crossOrigin = 'anonymous';
    video.autoplay = false;
    video.preload = 'auto';
    video.setAttribute('playsinline','')
    video.setAttribute('webkit-playsinline','')
    if(options.mute){
      video.muted = true;
      video.volume = 0;
    }
    video.style.display = 'none';
    video.loop = !!options.loop;
    if(options.precache) {
      this.precacheSource(options.src)
        .then(blob => {
          console.log("sample precached.");
          video.src = blob;
          document.body.appendChild(video);
        })
        .catch(e=>{
          console.error(e);
        });
    }else{
      video.src = options.src;
      // 这里要插在body上，避免container移动带来无法播放的问题
      document.body.appendChild(this.video);
      video.load();
    }
    if ( 'requestVideoFrameCallback' in this.video ) {
      this.useFrameCallback = !!this.options.accurate;
    }
    // 绑定事件
    this.events = {}
    ;['playing', 'pause', 'ended', 'error', 'canplay'].forEach(item => {
      this.on(item, this['on' + item].bind(this));
    })
  }
  drawFrame(_, info) {
    this._drawFrame = this._drawFrame || this.drawFrame.bind(this, _, info);
    if ( this.useFrameCallback ) {
      // @ts-ignore
      this.animId = this.video.requestVideoFrameCallback( this.drawFrame.bind(this) );
    } else {
      this.animId = this.requestAnim(this._drawFrame);
    }
  }

  play() {
    const prom = this.video && this.video.play();

    if (prom && prom.then) {
      prom.catch(e => {
        if (!this.video) {
          return;
        }
        this.video.muted = true;
        this.video.volume = 0;
        this.video.play().catch(e => {
          (this.events.error || []).forEach(item => {
            item(e);
          })
        })
      })
    }
  }

  pause() {
    this.video && this.video.pause();
  }

  setTime(t) {
    if (this.video) {
      this.video.currentTime = t
    }
  }

  requestAnimFunc() {
    const me = this;
    if (window.requestAnimationFrame) {
      let index = -1;
      return function(cb) {
        index++;
        return requestAnimationFrame(() => {
          if (!(index % (60 / me.fps))) {
            return cb();
          }
          me.animId = me.requestAnim(cb);
        })
      }
    }
    return function(cb) {
      return setTimeout(cb, 1000 / me.fps)
    }
  }

  cancelRequestAnimation() {
    if (this.useFrameCallback) {
      try {
        // @ts-ignore
        this.video.cancelVideoFrameCallback(this.animId);
      } catch (e) {}
    }else if (window.cancelAnimationFrame) {
      cancelAnimationFrame(this.animId);
    } else {
      clearTimeout(this.animId);
    }
  }

  destroy() {
    this.cancelRequestAnimation();
    if (this.video) {
      this.video.parentNode && this.video.parentNode.removeChild(this.video);
      this.video = null
    }
    this.options.onDestory && this.options.onDestory();
  }

  clear() {
    this.destroy();
  }

  on(event, callback:EventListenerObject) {
    const cbs = this.events[event] || [];
    cbs.push(callback);
    this.events[event] = cbs;
    this.video.addEventListener(event, callback);
    return this
  }

  onplaying() {
    if (!this.firstPlaying) {
      this.firstPlaying = true;
      if ( this.useFrameCallback ) {
        // @ts-ignore
        this.animId = this.video.requestVideoFrameCallback( this.drawFrame.bind(this) );
      } else {
        this.drawFrame(null, null)
      }
    }
  }

  onpause() {}

  onended() {
    this.destroy();
  }

  oncanplay() {
    const begin = this.options.beginPoint
    if (begin && this.setBegin) {
      this.setBegin = false
      this.video.currentTime = begin
    }
  }

  onerror(err) {
    console.error('[Alpha video]: play error: ', err);
    this.destroy();
    this.options.onLoadError && this.options.onLoadError(err);
  }
}
