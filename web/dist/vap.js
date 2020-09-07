(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  (global.howLongUntilLunch = factory());
}(this, (function () { 'use strict';

  var classCallCheck = function (instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  };

  var createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  var get = function get(object, property, receiver) {
    if (object === null) object = Function.prototype;
    var desc = Object.getOwnPropertyDescriptor(object, property);

    if (desc === undefined) {
      var parent = Object.getPrototypeOf(object);

      if (parent === null) {
        return undefined;
      } else {
        return get(parent, property, receiver);
      }
    } else if ("value" in desc) {
      return desc.value;
    } else {
      var getter = desc.get;

      if (getter === undefined) {
        return undefined;
      }

      return getter.call(receiver);
    }
  };

  var inherits = function (subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
    if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
  };

  var possibleConstructorReturn = function (self, call) {
    if (!self) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return call && (typeof call === "object" || typeof call === "function") ? call : self;
  };

  var slicedToArray = function () {
    function sliceIterator(arr, i) {
      var _arr = [];
      var _n = true;
      var _d = false;
      var _e = undefined;

      try {
        for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) {
          _arr.push(_s.value);

          if (i && _arr.length === i) break;
        }
      } catch (err) {
        _d = true;
        _e = err;
      } finally {
        try {
          if (!_n && _i["return"]) _i["return"]();
        } finally {
          if (_d) throw _e;
        }
      }

      return _arr;
    }

    return function (arr, i) {
      if (Array.isArray(arr)) {
        return arr;
      } else if (Symbol.iterator in Object(arr)) {
        return sliceIterator(arr, i);
      } else {
        throw new TypeError("Invalid attempt to destructure non-iterable instance");
      }
    };
  }();

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
  var FrameParser = function () {
      function FrameParser(source, headData) {
          classCallCheck(this, FrameParser);

          this.config = source || {};
          this.headData = headData;
          this.frame = [];
          this.textureMap = {};
      }

      createClass(FrameParser, [{
          key: 'init',
          value: function init() {
              var _this2 = this;

              return Promise.resolve().then(function () {
                  _this2.initCanvas();
                  return _this2.parseSrc(_this2.config);
              }).then(function () {
                  _this2.canvas.parentNode.removeChild(_this2.canvas);
                  _this2.frame = _this2.config.frame || [];
                  return _this2;
              });
          }
      }, {
          key: 'initCanvas',
          value: function initCanvas() {
              var canvas = document.createElement('canvas');
              var ctx = canvas.getContext('2d');
              canvas.style.display = 'none';
              document.body.appendChild(canvas);
              this.ctx = ctx;
              this.canvas = canvas;
          }
      }, {
          key: 'loadImg',
          value: function loadImg(url) {
              return new Promise(function (resolve, reject) {
                  // console.log('load img:', url)
                  var img = new Image();
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
      }, {
          key: 'parseSrc',
          value: function parseSrc(dataJson) {
              var _this = this;

              var src = this.srcData = {};
              return Promise.all((dataJson.src || []).map(function (item) {
                  return Promise.resolve().then(function () {
                      if (item.srcType === 'txt') {
                          item.textStr = item.srcTag.replace(/\[(.*)\]/, function ($0, $1) {
                              return _this.headData[$1];
                          });
                          item.img = _this.makeTextImg(item);
                      } else {
                          if (item.srcType === 'img') {
                              item.imgUrl = item.srcTag.replace(/\[(.*)\]/, function ($0, $1) {
                                  return _this.headData[$1];
                              });
                              return Promise.resolve().then(function () {
                                  return _this.loadImg(item.imgUrl + '?t=' + Date.now());
                              }).then(function (_resp) {
                                  item.img = _resp;
                              }).catch(function (e) {
                                  return Promise.resolve();
                              });
                          }
                      }
                  }).then(function () {
                      src[item.srcId] = item;
                  });
              }));
          }
          /**
           * 文字转换图片
           * @param {*} param0
           */

      }, {
          key: 'makeTextImg',
          value: function makeTextImg(_ref) {
              var textStr = _ref.textStr,
                  w = _ref.w,
                  h = _ref.h,
                  color = _ref.color,
                  style = _ref.style;

              var ctx = this.ctx;
              ctx.canvas.width = w;
              ctx.canvas.height = h;
              var fontSize = Math.min(parseInt(w / textStr.length, 10), h - 8); // 需留一定间隙
              var font = [fontSize + 'px', 'Arial'];
              if (style === 'b') {
                  font.unshift('bold');
              }
              ctx.font = font.join(' ');
              ctx.textBaseline = 'middle';
              ctx.textAlign = 'center';
              ctx.fillStyle = color;
              ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
              ctx.fillText(textStr, w / 2, h / 2);
              // console.log('frame : ' + textStr, ctx.canvas.toDataURL('image/png'))
              return ctx.getImageData(0, 0, w, h);
          }
      }, {
          key: 'getFrame',
          value: function getFrame(frame) {
              return this.frame.find(function (item) {
                  return item.i === frame;
              });
          }
      }]);
      return FrameParser;
  }();

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
  function createShader(gl, type, source) {
      var shader = gl.createShader(type);
      gl.shaderSource(shader, source);
      gl.compileShader(shader);
      // if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      //     console.error(gl.getShaderInfoLog(shader))
      // }
      return shader;
  }

  function createProgram(gl, vertexShader, fragmentShader) {
      var program = gl.createProgram();
      gl.attachShader(program, vertexShader);
      gl.attachShader(program, fragmentShader);
      gl.linkProgram(program);
      // if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      //     console.error(gl.getProgramInfoLog(program))
      // }
      gl.useProgram(program);
      return program;
  }

  function createTexture(gl, index, imgData) {
      var texture = gl.createTexture();
      var textrueIndex = gl.TEXTURE0 + index;
      gl.activeTexture(textrueIndex);
      gl.bindTexture(gl.TEXTURE_2D, texture);
      // gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      if (imgData) {
          gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, imgData);
      }
      return texture;
  }

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
  var VapVideo = function () {
      function VapVideo(options) {
          classCallCheck(this, VapVideo);

          if (!options.container || !options.src) {
              return console.warn('[Alpha video]: options container and src cannot be empty!');
          }
          this.options = Object.assign({
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
              config: ''
          }, options);
          this.fps = 20;
          this.requestAnim = this.requestAnimFunc(this.fps);
          this.container = this.options.container;
          if (!this.options.src || !this.options.config || !this.options.container) {
              console.error('参数出错：src(视频地址)、config(配置文件地址)、container(dom容器)');
          } else {
              // 创建video
              this.initVideo();
          }
      }

      createClass(VapVideo, [{
          key: 'initVideo',
          value: function initVideo() {
              var _this = this;

              var options = this.options;
              // 创建video
              var video = this.video = document.createElement('video');
              video.crossOrigin = 'anonymous';
              video.autoplay = false;
              // video.muted = true
              // video.volume = 0
              video.style.display = 'none';
              video.src = options.src;
              video.loop = !!options.loop;
              // 这里要插在body上，避免container移动带来无法播放的问题
              document.body.appendChild(this.video);
              // 绑定事件
              this.events = {};['playing', 'pause', 'ended', 'error'].forEach(function (item) {
                  _this.on(item, _this['on' + item].bind(_this));
              });
              video.load();
          }
      }, {
          key: 'drawFrame',
          value: function drawFrame() {
              this._drawFrame = this._drawFrame || this.drawFrame.bind(this);
              this.animId = this.requestAnim(this._drawFrame);
          }
      }, {
          key: 'play',
          value: function play() {
              var _this2 = this;

              var prom = this.video && this.video.play();

              if (prom && prom.then) {
                  prom.catch(function (e) {
                      if (!_this2.video) {
                          return;
                      }
                      _this2.video.muted = true;
                      _this2.video.volume = 0;
                      _this2.video.play().catch(function (e) {
  (_this2.events.error || []).forEach(function (item) {
                              item(e);
                          });
                      });
                  });
              }
          }
      }, {
          key: 'requestAnimFunc',
          value: function requestAnimFunc() {
              var me = this;
              if (window.requestAnimationFrame) {
                  var index = -1;
                  return function (cb) {
                      index++;
                      return requestAnimationFrame(function () {
                          if (!(index % (60 / me.fps))) {
                              return cb();
                          }
                          me.animId = me.requestAnim(cb);
                      });
                  };
              }
              return function (cb) {
                  return setTimeout(cb, 1000 / me.fps);
              };
          }
      }, {
          key: 'cancelRequestAnimation',
          value: function cancelRequestAnimation() {
              if (window.cancelAnimationFrame) {
                  cancelAnimationFrame(this.animId);
              }
              clearTimeout(this.animId);
          }
      }, {
          key: 'destroy',
          value: function destroy() {
              if (this.video) {
                  this.video.parentNode && this.video.parentNode.removeChild(this.video);
                  this.video = null;
              }
              this.cancelRequestAnimation(this.animId);
          }
      }, {
          key: 'clear',
          value: function clear() {
              this.destroy();
          }
      }, {
          key: 'on',
          value: function on(event, callback) {
              var cbs = this.events[event] || [];
              cbs.push(callback);
              this.events[event] = cbs;
              this.video.addEventListener(event, callback);
              return this;
          }
      }, {
          key: 'onplaying',
          value: function onplaying() {
              if (!this.firstPlaying) {
                  this.firstPlaying = true;
                  this.drawFrame();
              }
          }
      }, {
          key: 'onpause',
          value: function onpause() {}
      }, {
          key: 'onended',
          value: function onended() {
              this.destroy();
          }
      }, {
          key: 'onerror',
          value: function onerror(err) {
              console.error('[Alpha video]: play error: ', err);
              this.destroy();
          }
      }]);
      return VapVideo;
  }();

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

  var clearTimer = null;
  var instances = {};
  var PER_SIZE = 9;

  function computeCoord(x, y, w, h, vw, vh) {
      // leftX rightX bottomY topY
      return [x / vw, (x + w) / vw, (vh - y - h) / vh, (vh - y) / vh];
  }

  var WebglRenderVap = function (_VapVideo) {
      inherits(WebglRenderVap, _VapVideo);

      function WebglRenderVap(options) {
          classCallCheck(this, WebglRenderVap);

          var _this = possibleConstructorReturn(this, (WebglRenderVap.__proto__ || Object.getPrototypeOf(WebglRenderVap)).call(this, options));

          _this.insType = _this.options.type;
          if (instances[_this.insType]) {
              _this.instance = instances[_this.insType];
          } else {
              _this.instance = instances[_this.insType] = {};
          }
          _this.textures = [];
          _this.buffers = [];
          _this.shaders = [];
          _this.init();
          return _this;
      }

      createClass(WebglRenderVap, [{
          key: 'init',
          value: function init() {
              var _this3 = this;

              return Promise.resolve().then(function () {
                  _this3.setCanvas();
                  if (_this3.options.config) {
                      return Promise.resolve().then(function () {
                          return new FrameParser(_this3.options.config, _this3.options).init();
                      }).then(function (_resp) {
                          _this3.vapFrameParser = _resp;
                          _this3.resources = _this3.vapFrameParser.srcData;
                      }).catch(function (e) {
                          console.error('[Alpha video] parse vap frame error.', e);
                      });
                  }
              }).then(function () {
                  _this3.resources = _this3.resources || {};
                  _this3.initWebGL();
                  _this3.play();
              });
          }
      }, {
          key: 'setCanvas',
          value: function setCanvas() {
              var canvas = this.instance.canvas;
              var _options = this.options,
                  width = _options.width,
                  height = _options.height;

              if (!canvas) {
                  canvas = this.instance.canvas = document.createElement('canvas');
              }
              canvas.width = width;
              canvas.height = height;
              this.container.appendChild(canvas);
          }
      }, {
          key: 'initWebGL',
          value: function initWebGL() {
              var canvas = this.instance.canvas;
              var _instance = this.instance,
                  gl = _instance.gl,
                  vertexShader = _instance.vertexShader,
                  fragmentShader = _instance.fragmentShader,
                  program = _instance.program;

              if (!canvas) {
                  return;
              }
              if (!gl) {
                  this.instance.gl = gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
                  gl.enable(gl.BLEND);
                  gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
                  gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
              }
              if (gl) {
                  gl.viewport(0, 0, canvas.width, canvas.height);
                  if (!vertexShader) {
                      vertexShader = this.instance.vertexShader = this.initVertexShader();
                  }
                  if (!fragmentShader) {
                      fragmentShader = this.instance.fragmentShader = this.initFragmentShader();
                  }
                  if (!program) {
                      program = this.instance.program = createProgram(gl, vertexShader, fragmentShader);
                  }
                  this.program = program;
                  this.initTexture();
                  this.initVideoTexture();
                  return gl;
              }
          }

          /**
           * 顶点着色器
           */

      }, {
          key: 'initVertexShader',
          value: function initVertexShader() {
              var gl = this.instance.gl;

              return createShader(gl, gl.VERTEX_SHADER, 'attribute vec2 a_position; // \u63A5\u53D7\u9876\u70B9\u5750\u6807\n             attribute vec2 a_texCoord; // \u63A5\u53D7\u7EB9\u7406\u5750\u6807\n             attribute vec2 a_alpha_texCoord; // \u63A5\u53D7\u7EB9\u7406\u5750\u6807\n             varying vec2 v_alpha_texCoord; // \u63A5\u53D7\u7EB9\u7406\u5750\u6807\n             varying   vec2 v_texcoord; // \u4F20\u9012\u7EB9\u7406\u5750\u6807\u7ED9\u7247\u5143\u7740\u8272\u5668\n             void main(void){\n                gl_Position = vec4(a_position, 0.0, 1.0); // \u8BBE\u7F6E\u5750\u6807\n                v_texcoord = a_texCoord; // \u8BBE\u7F6E\u7EB9\u7406\u5750\u6807\n                v_alpha_texCoord = a_alpha_texCoord; // \u8BBE\u7F6E\u7EB9\u7406\u5750\u6807\n             }');
          }

          /**
           * 片元着色器
           */

      }, {
          key: 'initFragmentShader',
          value: function initFragmentShader() {
              var gl = this.instance.gl;

              var bgColor = 'vec4(texture2D(u_image_video, v_texcoord).rgb, texture2D(u_image_video,v_alpha_texCoord).r);';
              var textureSize = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS) - 1;
              // const textureSize =0
              var sourceTexure = '';
              var sourceUniform = '';
              if (textureSize > 0) {
                  var imgColor = [];
                  for (var i = 0; i < textureSize; i++) {
                      imgColor.push('if(ndx == ' + i + '){\n                        color = texture2D(textures[' + i + '],uv);\n                    }');
                  }

                  sourceUniform = '\n            uniform sampler2D u_image[' + textureSize + '];\n            uniform float image_pos[' + textureSize * PER_SIZE + '];\n            vec4 getSampleFromArray(sampler2D textures[' + textureSize + '], int ndx, vec2 uv) {\n                vec4 color;\n                ' + imgColor.join(' else ') + '\n                return color;\n            }\n            ';
                  sourceTexure = '\n            vec4 srcColor,maskColor;\n            vec2 srcTexcoord,maskTexcoord;\n            int srcIndex;\n            float x1,x2,y1,y2,mx1,mx2,my1,my2; //\u663E\u793A\u7684\u533A\u57DF\n\n            for(int i=0;i<' + textureSize * PER_SIZE + ';i+= ' + PER_SIZE + '){\n                if ((int(image_pos[i]) > 0)) {\n                  srcIndex = int(image_pos[i]);\n    \n                    x1 = image_pos[i+1];\n                    x2 = image_pos[i+2];\n                    y1 = image_pos[i+3];\n                    y2 = image_pos[i+4];\n                    \n                    mx1 = image_pos[i+5];\n                    mx2 = image_pos[i+6];\n                    my1 = image_pos[i+7];\n                    my2 = image_pos[i+8];\n    \n    \n                    if (v_texcoord.s>x1 && v_texcoord.s<x2 && v_texcoord.t>y1 && v_texcoord.t<y2) {\n                        srcTexcoord = vec2((v_texcoord.s-x1)/(x2-x1),(v_texcoord.t-y1)/(y2-y1));\n                         maskTexcoord = vec2(mx1+srcTexcoord.s*(mx2-mx1),my1+srcTexcoord.t*(my2-my1));\n                         srcColor = getSampleFromArray(u_image,srcIndex,srcTexcoord);\n                         maskColor = texture2D(u_image_video, maskTexcoord);\n                         srcColor.a = srcColor.a*(maskColor.r);\n                      \n                         bgColor = vec4(srcColor.rgb*srcColor.a,srcColor.a) + (1.0-srcColor.a)*bgColor;\n                      \n                    }   \n                }\n            }\n            ';
              }

              var fragmentSharder = '\n        precision lowp float;\n        varying vec2 v_texcoord;\n        varying vec2 v_alpha_texCoord;\n        uniform sampler2D u_image_video;\n        ' + sourceUniform + '\n        \n        void main(void) {\n            vec4 bgColor = ' + bgColor + '\n            ' + sourceTexure + '\n            // bgColor = texture2D(u_image[0], v_texcoord);\n            gl_FragColor = bgColor;\n        }\n        ';
              return createShader(gl, gl.FRAGMENT_SHADER, fragmentSharder);
          }
      }, {
          key: 'initTexture',
          value: function initTexture() {
              var gl = this.instance.gl;

              var i = 1;
              if (!this.vapFrameParser || !this.vapFrameParser.srcData) {
                  return;
              }
              var resources = this.vapFrameParser.srcData;
              for (var key in resources) {
                  var resource = resources[key];
                  this.textures.push(createTexture(gl, i, resource.img));
                  var _sampler = gl.getUniformLocation(this.program, 'u_image[' + i + ']');
                  gl.uniform1i(_sampler, i);
                  this.vapFrameParser.textureMap[resource.srcId] = i++;
              }
              this.videoTexture = createTexture(gl, i);
              var sampler = gl.getUniformLocation(this.program, 'u_image_video');
              gl.uniform1i(sampler, i);
          }
      }, {
          key: 'initVideoTexture',
          value: function initVideoTexture() {
              var gl = this.instance.gl;

              var vertexBuffer = gl.createBuffer();
              this.buffers.push(vertexBuffer);
              if (!this.vapFrameParser || !this.vapFrameParser.config || !this.vapFrameParser.config.info) {
                  return;
              }
              var info = this.vapFrameParser.config.info;
              var ver = [];
              var vW = info.videoW,
                  vH = info.videoH;

              var _info$rgbFrame = slicedToArray(info.rgbFrame, 4),
                  rgbX = _info$rgbFrame[0],
                  rgbY = _info$rgbFrame[1],
                  rgbW = _info$rgbFrame[2],
                  rgbH = _info$rgbFrame[3];

              var _info$aFrame = slicedToArray(info.aFrame, 4),
                  aX = _info$aFrame[0],
                  aY = _info$aFrame[1],
                  aW = _info$aFrame[2],
                  aH = _info$aFrame[3];

              var rgbCoord = computeCoord(rgbX, rgbY, rgbW, rgbH, vW, vH);
              var aCoord = computeCoord(aX, aY, aW, aH, vW, vH);
              ver.push.apply(ver, [-1, 1, rgbCoord[0], rgbCoord[3], aCoord[0], aCoord[3]]);
              ver.push.apply(ver, [1, 1, rgbCoord[1], rgbCoord[3], aCoord[1], aCoord[3]]);
              ver.push.apply(ver, [-1, -1, rgbCoord[0], rgbCoord[2], aCoord[0], aCoord[2]]);
              ver.push.apply(ver, [1, -1, rgbCoord[1], rgbCoord[2], aCoord[1], aCoord[2]]);
              var view = new Float32Array(ver);
              gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
              gl.bufferData(gl.ARRAY_BUFFER, view, gl.STATIC_DRAW);

              this.aPosition = gl.getAttribLocation(this.program, 'a_position');
              gl.enableVertexAttribArray(this.aPosition);
              this.aTexCoord = gl.getAttribLocation(this.program, 'a_texCoord');
              gl.enableVertexAttribArray(this.aTexCoord);
              this.aAlphaTexCoord = gl.getAttribLocation(this.program, 'a_alpha_texCoord');
              gl.enableVertexAttribArray(this.aAlphaTexCoord);
              // 将缓冲区对象分配给a_position变量、a_texCoord变量
              var size = view.BYTES_PER_ELEMENT;
              gl.vertexAttribPointer(this.aPosition, 2, gl.FLOAT, false, size * 6, 0); // 顶点着色器位置
              gl.vertexAttribPointer(this.aTexCoord, 2, gl.FLOAT, false, size * 6, size * 2); // rgb像素位置
              gl.vertexAttribPointer(this.aAlphaTexCoord, 2, gl.FLOAT, false, size * 6, size * 4); // rgb像素位置
          }
      }, {
          key: 'drawFrame',
          value: function drawFrame() {
              var _this2 = this;

              var gl = this.instance.gl;
              if (!gl) {
                  get(WebglRenderVap.prototype.__proto__ || Object.getPrototypeOf(WebglRenderVap.prototype), 'drawFrame', this).call(this);
                  return;
              }
              gl.clear(gl.COLOR_BUFFER_BIT);
              if (this.vapFrameParser) {
                  var frame = Math.floor(this.video.currentTime * this.options.fps);
                  var frameData = this.vapFrameParser.getFrame(frame);
                  var posArr = [];

                  if (frameData && frameData.obj) {
                      frameData.obj.forEach(function (frame, index) {
                          posArr[posArr.length] = +_this2.vapFrameParser.textureMap[frame.srcId];

                          var info = _this2.vapFrameParser.config.info;
                          var vW = info.videoW,
                              vH = info.videoH;

                          var _frame$frame = slicedToArray(frame.frame, 4),
                              x = _frame$frame[0],
                              y = _frame$frame[1],
                              w = _frame$frame[2],
                              h = _frame$frame[3];

                          var _frame$mFrame = slicedToArray(frame.mFrame, 4),
                              mX = _frame$mFrame[0],
                              mY = _frame$mFrame[1],
                              mW = _frame$mFrame[2],
                              mH = _frame$mFrame[3];

                          var coord = computeCoord(x, y, w, h, vW, vH);
                          var mCoord = computeCoord(mX, mY, mW, mH, vW, vH);
                          posArr = posArr.concat(coord).concat(mCoord);
                      });
                  }
                  //
                  var size = (gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS) - 1) * PER_SIZE;
                  posArr = posArr.concat(new Array(size - posArr.length).fill(0));
                  this._imagePos = this._imagePos || gl.getUniformLocation(this.program, 'image_pos');
                  gl.uniform1fv(this._imagePos, new Float32Array(posArr));
              }
              gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, this.video); // 指定二维纹理方式
              gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
              get(WebglRenderVap.prototype.__proto__ || Object.getPrototypeOf(WebglRenderVap.prototype), 'drawFrame', this).call(this);
          }
      }, {
          key: 'destroy',
          value: function destroy() {
              var canvas = this.instance.canvas;

              if (canvas) {
                  canvas.parentNode && canvas.parentNode.removeChild(canvas);
              }
              // glUtil.cleanWebGL(gl, this.shaders, this.program, this.textures, this.buffers)
              get(WebglRenderVap.prototype.__proto__ || Object.getPrototypeOf(WebglRenderVap.prototype), 'destroy', this).call(this);
              this.clearMemoryCache();
          }
      }, {
          key: 'clearMemoryCache',
          value: function clearMemoryCache() {
              if (clearTimer) {
                  clearTimeout(clearTimer);
              }

              clearTimer = setTimeout(function () {
                  instances = {};
              }, 30 * 60 * 1000);
          }
      }]);
      return WebglRenderVap;
  }(VapVideo);

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
  var isCanWebGL = void 0;
  /**
   * @param options
   * @constructor
   * @return {null}
   */
  function index (options) {
      if (canWebGL()) {
          return new WebglRenderVap(Object.assign({}, options));
      } else {
          throw new Error('your browser not support webgl');
      }
  }

  function canWebGL() {
      if (typeof isCanWebGL !== 'undefined') {
          return isCanWebGL;
      }
      try {
          if (!window.WebGLRenderingContext) {
              return false;
          }
          var canvas = document.createElement('canvas');
          var context = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

          isCanWebGL = !!context;
          context = null;
      } catch (err) {
          isCanWebGL = false;
      }
      return isCanWebGL;
  }

  return index;

})));
