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
import WebglRenderVap from './webgl-render-vap';
let isCanWebGL: boolean;
/**
 * @param options
 * @constructor
 * @return {null}
 */
export default function (options?: VapConfig) {
  if (canWebGL()) {
    return new WebglRenderVap(options);
  } else {
    throw new Error('your browser not support webgl');
  }
}

export function canWebGL(): boolean {
  if (typeof isCanWebGL !== 'undefined') {
    return isCanWebGL;
  }
  try {
    // @ts-ignore
    if (!window.WebGLRenderingContext) {
      return false;
    }
    const canvas = document.createElement('canvas');
    let context = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

    isCanWebGL = !!context;
    context = null;
  } catch (err) {
    isCanWebGL = false;
  }
  return isCanWebGL;
}
