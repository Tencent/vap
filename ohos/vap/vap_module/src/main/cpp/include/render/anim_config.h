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

#ifndef VAP_CONFIG_H
#define VAP_CONFIG_H

#include <cstdint>
#include <nlohmann/json.hpp>
#include <stdint.h>
#include "frame.h"
#include "src.h"
#include "vertex_util.h"

#include <stdint.h>
#include "vertex_util.h"

using json = nlohmann::json;

enum Orien {
    ORIEN_DEFAULT = 0,  // 兼容模式
    ORIEN_PORTRAIT, // 适配竖屏的视频
    ORIEN_LANDSCAPE // 适配横屏的视频
};

enum VideoMode {
    // 视频对齐方式 (兼容老版本视频模式)
    VIDEO_MODE_SPLIT_HORIZONTAL = 1, // 视频左右对齐（alpha左\rgb右）
    VIDEO_MODE_SPLIT_VERTICAL, // 视频上下对齐（alpha上\rgb下）
    VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE, // 视频左右对齐（rgb左\alpha右）
    VIDEO_MODE_SPLIT_VERTICAL_REVERSE // 视频上下对齐（rgb上\alpha下）
};

struct BoxHead {
    int32_t length;
    std::string type;
};

class AnimConfig {
public:
    AnimConfig(bool isH265 = false)
    {
        isH265_ = isH265;
    };
    ~AnimConfig();
    bool ParseJson(std::string uri, bool isNeedParseFrame = true);
    void GetSrc(std::map<std::string, Src> &src);
    void DefaultConfig(int32_t width, int32_t height);

    int32_t version = 2; // 不同版本号不兼容
    int32_t totalFrames = 0; // 总帧数
    int32_t width = 0; // 需要显示视频的真实宽高
    int32_t height = 0;
    int32_t videoWidth = 0; // 视频实际宽高
    int32_t videoHeight = 0;
    Orien orien = ORIEN_DEFAULT; // 0-兼容模式 1-竖屏 2-横屏
    int32_t fps = 0;
    bool isMix = false; // 是否为融合动画
    PointRect alphaPointRect = PointRect(0, 0, 0, 0); // alpha区域
    PointRect rgbPointRect = PointRect(0, 0, 0, 0); // rgb区域
    bool isDefaultConfig = false; // 没有vapc配置时默认逻辑
    VideoMode defaultVideoMode = VIDEO_MODE_SPLIT_HORIZONTAL;
    std::shared_ptr<SrcMap> srcMapPtr = nullptr;
    std::shared_ptr<FrameAll> frameAllPtr = nullptr;
private:
	void ParseBoxHead(std::vector<char> &boxHead, BoxHead &head);
    int GetJson(std::string &jsonStr, std::string &uri);
    
    bool isInit = false;
    bool isH265_ = false;
};

#endif // VAP_CONFIG_H
