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
package com.tencent.qgame.playerproj.animtool;

public class TLog {

    public static ITLog logger;

    public static void i(String tag, String msg) {
        if (logger != null) {
            logger.i(tag, msg);
        } else {
            System.out.println(tag + "\t" + msg);
        }
    }

    public static void e(String tag, String msg) {
        if (logger != null) {
            logger.e(tag, msg);
        } else {
            System.out.println(tag + "\tError:" + msg);
        }
    }

    public static void w(String tag, String msg) {
        if (logger != null) {
            logger.w(tag, msg);
        } else {
            System.out.println(tag + "\tWarning:" + msg);
        }
    }


    public interface ITLog {
        void i(String tag, String  msg);
        void e(String tag, String  msg);
        void w(String tag, String  msg);
    }
}
