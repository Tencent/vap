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

#include "src.h"
#include "log.h"
#include "common_const.h"

using namespace CommonConst;

std::map<std::string, SrcType> Src::string2SrcType = {
    {"unknown", SrcType::UNKNOWN}, {"img", SrcType::IMG}, {"txt", SrcType::TXT}};

std::map<std::string, LoadType> Src::string2LoadType = {
    {"unknown", LoadType::UNKNOWN}, {"net", LoadType::NET}, {"local", LoadType::LOCAL}};

std::map<std::string, FitType> Src::string2FitType = {{"fitXY", FitType::FIT_XY}, {"centerFull", FitType::CENTER_FULL}};

std::map<std::string, Style> Src::string2Style = {{"default", Style::DEFAULT}, {"b", Style::BOLD}};

Src::Src(json jsonSrc)
{
    srcId = jsonSrc.at("srcId").get<std::string>();
    std::string tmpStr = jsonSrc.at("srcType").get<std::string>();
    srcType = stringToSrcTypeFunc(tmpStr);
    tmpStr = jsonSrc.at("loadType").get<std::string>();
    loadType = stringToLoadTypeFunc(tmpStr);
    srcTag = jsonSrc.at("srcTag").get<std::string>();
    txt = srcTag;
    std::string colorStr;
    if (jsonSrc.find("color") != jsonSrc.end()) {
        colorStr = jsonSrc.at("color").get<std::string>();
        colorStr.erase(0, 1); // 去掉字符串开头的 #
        color = std::stoi(colorStr, nullptr, TWO_TIME_EIGHT);
        if (((color >> THREE_TIME_EIGHT) & 0xff) == 0) {
            color |= 0xff << THREE_TIME_EIGHT;
        }
    }
    if (jsonSrc.find("style") != jsonSrc.end()) {
        tmpStr = jsonSrc.at("style").get<std::string>();
        style = stringToStyleFunc(tmpStr);
    }
    w = jsonSrc.at("w").get<int32_t>();
    h = jsonSrc.at("h").get<int32_t>();
    tmpStr = jsonSrc.at("fitType").get<std::string>();
    fitType = stringToFitTypeFunc(tmpStr);
}

void Src::PrintInfo()
{
    LOGD("srcId: %{public}s srcType: %{public}d, loadType:%{public}d, srcTag:%{public}s,"
        "color:%{public}x, style:%{public}d, w:%{public}d, h:%{public}d, fitType: %{public}d, "
        "drawWidth: %{public}d,drawHeight: %{public}d, srcTextureId: %{public}d",
        srcId.c_str(), srcType, loadType, srcTag.c_str(), color, style, w, h, fitType, drawWidth, drawHeight,
        srcTextureId);
}

SrcMap::SrcMap(json jsonObj)
{
    auto srcJsonArray = jsonObj.at("src");
    size_t srcLen = srcJsonArray.size();
    for (int i = 0; i < srcLen; i++) {
        auto srcJson = srcJsonArray[i];
        Src src = Src(srcJson);
        if (src.srcType != SrcType::UNKNOWN) { // 不认识的srcType丢弃
            srcSMap.insert(std::make_pair(src.srcId, src));
        }
    }
}