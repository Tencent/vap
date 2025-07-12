/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { http } from '@kit.NetworkKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';

function extractFileName(url: string): string {
  // 使用正则表达式匹配 URL 中的文件名部分
  const matches = url.match(/\/([^\/?#]+)[^\/]*$/);
  if (matches && matches.length > 1) {
    return matches[1];
  }
  // 如果没有匹配到，则返回空字符串或者你想要的默认值
  return '';
}

function startsWithHttp(url: string): boolean {
  return url.startsWith("http");
}

function writeFile(filePath: string, buf: ArrayBuffer) {
  let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  fs.writeSync(file.fd, buf);
  fs.closeSync(file);
}

export async function downloadFile(url: string, dir?: string) {
  console.log('enter downloadFile: ' + JSON.stringify(url));
  if(!startsWithHttp(url)) {
    return url;
  }
  const fileName = extractFileName(url);
  let filePath = '/storage/Users/currentUser/Documents/' + fileName
  if(dir) {
    filePath = dir + '/' + fileName
  }
  let res = fs.accessSync(filePath);
  if (res) {
    return filePath;
  }

  let httpRequest = http.createHttp();
  try {
    let data = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.ARRAY_BUFFER,
    })
    let buf:ArrayBuffer = data.result as ArrayBuffer;
    writeFile(filePath, buf)
  } catch (err) {
    console.error("accessSync failed with error message: " + err.message + ", error code: " + err.code);
    filePath = ''
  } finally {
    httpRequest.destroy();
  }
  return filePath
  // let promise:Promise<string> = new Promise((resolve: Function, reject: Function) => {
  //   let httpRequest = http.createHttp();
  //   httpRequest.request(url, {
  //     method: http.RequestMethod.GET,
  //     expectDataType: http.HttpDataType.ARRAY_BUFFER,
  //   }).then((data) => {
  //     let buf:ArrayBuffer = data.result as ArrayBuffer;
  //     writeFile(filePath, buf)
  //     resolve(filePath);
  //   }).catch((err: BusinessError) => {
  //     console.error("accessSync failed with error message: " + err.message + ", error code: " + err.code);
  //     reject(err)
  //   }).finally(()=>{
  //     httpRequest.destroy();
  //   })
  // })
  // let result: string = await promise
  // return result;
}


export function downMediaFile(url:string, callback: AsyncCallback<string>) {
  if(undefined == callback) {
    return
  }
  if(!startsWithHttp(url)) {
    callback(undefined, url);
  }
  let httpRequest = http.createHttp();
  const fileName = extractFileName(url);
  console.error('fileName:' + JSON.stringify(fileName));
  let filePath = '/storage/Users/currentUser/Documents/' + fileName

  try {
    let res = fs.accessSync(filePath);
    if (res) {
      callback(undefined, filePath);
    } else {
      httpRequest.on('headersReceive', (header) => {
        console.info('header: ' + JSON.stringify(header));
      });
      httpRequest.request(
        // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
        url,
        {
          method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
          // 开发者根据自身业务需要添加header字段
          // header: {
          //   'Content-Type': 'video/mp4'
          // },
          expectDataType: http.HttpDataType.ARRAY_BUFFER, // 可选，指定返回数据的类型
        }, (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          let buf:ArrayBuffer = data.result as ArrayBuffer;

          console.info('Result:' + JSON.stringify(buf.byteLength));
          console.info('resultType:' + JSON.stringify(data.resultType));
          console.info('code:' + JSON.stringify(data.responseCode));
          // data.header为HTTP响应头，可根据业务需要进行解析
          console.info('header:' + JSON.stringify(data.header));
          console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
          let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          fs.writeSync(file.fd, buf);
          fs.closeSync(file);
          callback(undefined, filePath);
          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        } else {
          console.error('error:' + JSON.stringify(err));
          // 取消订阅HTTP响应头事件
          httpRequest.off('headersReceive');
          callback(err, '');
          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        }
      });
      console.info("file not exists");
    }
  } catch(error) {
    let err: BusinessError = error as BusinessError;
    console.error("accessSync failed with error message: " + err.message + ", error code: " + err.code);
  }
}
