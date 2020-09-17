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
export default class VapVideo {
  constructor(options) {
    if (!options.container || !options.src) {
      return console.warn('[Alpha video]: options container and src cannot be empty!')
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
        config: ''
      },
      options
    )
    this.fps = 20
    this.requestAnim = this.requestAnimFunc(this.fps)
    this.container = this.options.container
    if (!this.options.src || !this.options.config || !this.options.container) {
      console.error('参数出错：src(视频地址)、config(配置文件地址)、container(dom容器)')
    } else {
      // 创建video
      this.initVideo()
    }
  }

  precacheSource(source) {
    const URL = window.webkitURL || window.URL;
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
              const raw = atob(
                fileReader.result.slice(fileReader.result.indexOf(",") + 1)
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
    const options = this.options
    // 创建video
    const video = (this.video = document.createElement('video'))
    video.crossOrigin = 'anonymous'
    video.autoplay = false
    video.preload = 'auto'
    video.autoload = true
    if(options.mute){
      video.muted = true
      video.volume = 0
    }
    video.style.display = 'none'
    video.loop = !!options.loop
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
    // 绑定事件
    this.events = {}
    ;['playing', 'pause', 'ended', 'error'].forEach(item => {
      this.on(item, this['on' + item].bind(this))
    })
  }
  drawFrame() {
    this._drawFrame = this._drawFrame || this.drawFrame.bind(this)
    this.animId = this.requestAnim(this._drawFrame)
  }

  play() {
    const prom = this.video && this.video.play()

    if (prom && prom.then) {
      prom.catch(e => {
        if (!this.video) {
          return
        }
        this.video.muted = true
        this.video.volume = 0
        this.video.play().catch(e => {
          ;(this.events.error || []).forEach(item => {
            item(e)
          })
        })
      })
    }
  }

  requestAnimFunc() {
    const me = this
    if (window.requestAnimationFrame) {
      let index = -1
      return function(cb) {
        index++
        return requestAnimationFrame(() => {
          if (!(index % (60 / me.fps))) {
            return cb()
          }
          me.animId = me.requestAnim(cb)
        })
      }
    }
    return function(cb) {
      return setTimeout(cb, 1000 / me.fps)
    }
  }

  cancelRequestAnimation() {
    if (window.cancelAnimationFrame) {
      cancelAnimationFrame(this.animId)
    }
    clearTimeout(this.animId)
  }

  destroy() {
    if (this.video) {
      this.video.parentNode && this.video.parentNode.removeChild(this.video)
      this.video = null
    }
    this.cancelRequestAnimation(this.animId)
  }

  clear() {
    this.destroy()
  }

  on(event, callback) {
    const cbs = this.events[event] || []
    cbs.push(callback)
    this.events[event] = cbs
    this.video.addEventListener(event, callback)
    return this
  }

  onplaying() {
    if (!this.firstPlaying) {
      this.firstPlaying = true
      this.drawFrame()
    }
  }

  onpause() {}

  onended() {
    this.destroy()
  }

  onerror(err) {
    console.error('[Alpha video]: play error: ', err)
    this.destroy()
  }
}
