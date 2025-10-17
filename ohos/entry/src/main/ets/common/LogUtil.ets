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
export class LogUtil {
  public static OFF: number = 1
  public static LOG: number = 2
  public static DEBUG: number = 3
  public static INFO: number = 4
  public static WARN: number = 5
  public static ERROR: number = 6
  public static ALL: number = 7
  public static mLogLevel:number = LogUtil.ALL;

  public static debug(message: string, ...args: Object[]) {
    if (LogUtil.mLogLevel >= LogUtil.DEBUG) {
      console.debug(message, args)
    }
  }

  public static info(message: string, ...args: Object[]) {
    if (LogUtil.mLogLevel >= LogUtil.INFO) {
      console.info(message, args)
    }
  }

  public static log(message: string, ...args: Object[]) {
    if (LogUtil.mLogLevel >= LogUtil.LOG) {
      console.log(message, args)
    }
  }

  public static warn(message: string, ...args: Object[]) {
    if (LogUtil.mLogLevel >= LogUtil.WARN) {
      console.warn(message, args)
    }
  }

  // error 不做拦截
  public static error(message: string, ...args: Object[]) {
    if(LogUtil.mLogLevel >= LogUtil.ERROR) {
      console.error(message, args)
    }
  }
}