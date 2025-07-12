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

#include <fstream>
#include "common_const.h"
#include "anim_config.h"

using namespace CommonConst;

AnimConfig::~AnimConfig()
{
    if (srcMapPtr) {
        srcMapPtr->srcSMap.clear();
    }
    if (frameAllPtr) {
        frameAllPtr->frameAll.clear();
    }
};

void AnimConfig::ParseBoxHead(std::vector<char> &boxHead, BoxHead &head)
{
    int32_t length = ZERO;
    length |= (boxHead[ZERO] & ONE_EIGHT_HEX) << THREE_TIME_EIGHT;
    length |= (boxHead[ZERO] & ONE_EIGHT_HEX) << TWO_TIME_EIGHT;
    length |= (boxHead[TWO] & ONE_EIGHT_HEX) << EIGHT;
    length |= (boxHead[THREE] & ONE_EIGHT_HEX);
    head.length = length;
    head.type.assign(&boxHead[FOUR], &boxHead[FOUR] + FOUR);
}

int AnimConfig::GetJson(std::string &jsonStr, std::string &uri)
{
    std::ifstream file(uri, std::ios::binary);
    int ret = NEGATIVE_ONE;
    if (!file.is_open()) {
        LOGE("json Failed to open file");
        return ret;
    }
    std::vector<char> buffer(EIGHT);
    while (file.read(buffer.data(), EIGHT)) {
        if (file.eof()) {
            LOGD("json end of file");
            break;
        }
        BoxHead boxHead;
        ParseBoxHead(buffer, boxHead);

        if (boxHead.type.compare("vapc") == ZERO) { // memcmp(boxHead.type.data(), "vapc", 4) == 0
            LOGD("json length: %{public}d", boxHead.length);
            std::vector<char> cont(boxHead.length);
            file.read(cont.data(), boxHead.length);
            jsonStr.assign(cont.begin(), cont.end());
            ret = 0;
            break;
        }
        if (isH265_) {
            file.seekg(ONE - EIGHT, std::ios::cur);
        }
    }
    file.close();
    return ret;
}

bool AnimConfig::ParseJson(std::string uri, bool isNeedParseFrame)
{
    LOGD("Enter ParseJson");
    if (isInit) {
        LOGD("Json data has been initialized");
        return true;
    }
    std::string strJson;
    json jsonObj;
    if (GetJson(strJson, uri) == NEGATIVE_ONE) {
        LOGE("AnimConfig::String2Json failed");
        return false;
    }
    if (strJson.empty()) {
        LOGE("AnimConfig not get json");
        return false;
    }
    jsonObj = json::parse(strJson);
    if (jsonObj.find("info") == jsonObj.end()) {
        LOGE("jsonObj: not find info");
        return false;
    }
    const auto &info = jsonObj.at("info");

    this->width = info.at("w").get<int>();
    this->height = info.at("h").get<int>();
    this->totalFrames = info.at("f").get<int>();
    this->videoWidth = info.at("videoW").get<int>();
    this->videoHeight = info.at("videoH").get<int>();
    this->orien = info.at("orien").get<Orien>();
    this->fps = info.at("fps").get<int>();
    this->isMix = info.at("isVapx").get<int>() == ONE;
    const auto& a = info.at("aFrame");
    this->alphaPointRect = std::move(PointRect(a.at(ZERO).get<int>(), a.at(ONE).get<int>(),
        a.at(TWO).get<int>(), a.at(THREE).get<int>()));
    const auto& c = info.at("rgbFrame");
    this->rgbPointRect = std::move(PointRect(c.at(ZERO).get<int>(), c.at(ONE).get<int>(),
        c.at(TWO).get<int>(), c.at(THREE).get<int>()));

    if (jsonObj.find("src") != jsonObj.end()) {
        srcMapPtr = std::make_shared<SrcMap>(jsonObj);
    } else {
        LOGW("json: not find src");
    }

    if (isNeedParseFrame && jsonObj.find("frame") != jsonObj.end()) {
        frameAllPtr = std::make_shared<FrameAll>(jsonObj);
    } else {
        LOGW("json: not find frame");
    }
    
    isInit = true;
    LOGD("end ParseJson");
    return true;
}

void AnimConfig::DefaultConfig(int32_t width, int32_t height)
{
    this->videoWidth = width;
    this->videoHeight = height;
    
    switch (defaultVideoMode) {
        case VIDEO_MODE_SPLIT_VERTICAL:
            this->width = width;
            this->height = height / TWO;
            this->alphaPointRect   = {ZERO, ZERO, this->width, this->height};
            this->rgbPointRect = {ZERO, this->height, this->width, this->height};
            break;
        case VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE:
            this->width = width / TWO;
            this->height = height;
            this->rgbPointRect = {ZERO, ZERO, this->width, this->height};
            this->alphaPointRect = {this->width, ZERO, this->width, this->height};
            break;
        case VIDEO_MODE_SPLIT_VERTICAL_REVERSE:
            this->width = width;
            this->height = height / TWO;
            this->rgbPointRect = {ZERO, ZERO, this->width, this->height};
            this->alphaPointRect = {ZERO, this->height, this->width, this->height};
            break;
        default:
            this->width = width / TWO;
            this->height = height;
            this->alphaPointRect   = {ZERO, ZERO, this->width, this->height};
            this->rgbPointRect = {this->width, ZERO, this->width, this->height};
            break;
    }
}


void AnimConfig::GetSrc(std::map<std::string, Src> &src)
{
    if (!srcMapPtr) {
        LOGW("this file not have src prop");
    } else {
        src = srcMapPtr->srcSMap;
    }
}
