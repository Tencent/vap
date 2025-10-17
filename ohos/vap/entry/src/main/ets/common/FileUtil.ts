/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
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
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common'

import fs from '@ohos.file.fs';
import { http } from '@kit.NetworkKit';

export class FileUtil {

   copyRawfileToContext(context:common.UIAbilityContext) {
    let filePath = context.filesDir;
    try {
      context.resourceManager.getRawFileList("").then((value: Array<string>) => {
        value.forEach(fileName => {
          let fileContent: ArrayBufferLike = context.resourceManager.getRawFileContentSync(fileName).buffer;
          let newFile = fs.openSync(filePath + "/" + fileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          fs.writeSync(newFile.fd, fileContent);
          fs.close(newFile);
        });

      }).catch((error: BusinessError) => {
        console.error(`promise getRawFileList failed, error code: ${error.code}, message: ${error.message}.`);
      });
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      console.error(`promise getRawFileList failed, error code: ${code}, message: ${message}.`);
    }
  }

  async downloadFile(url:string,context:common.UIAbilityContext): Promise<string>{
    const fileName = this.extractFileName(url);
    let filePath = context.filesDir+"/" + fileName
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
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, buf);
      fs.closeSync(file);
    } catch (err) {
      console.error("accessSync failed with error message: " + err.message + ", error code: " + err.code);
      filePath = ''
    } finally {
      httpRequest.destroy();
    }
    return filePath
  }

   extractFileName(url: string): string {
    const matches = url.match(/\/([^\/?#]+)[^\/]*$/);
    if (matches && matches.length > 1) {
      return matches[1];
    }
    return '';
  }

}


