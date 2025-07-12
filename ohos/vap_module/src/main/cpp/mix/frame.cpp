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

#include "frame.h"

#include <algorithm>
#include "log.h"
#include "common_const.h"

using namespace CommonConst;

Frame::Frame(json jsonFrame)
{
    srcId = jsonFrame.at("srcId").get<std::string>();
    z = jsonFrame.at("z").get<int>();

    const auto& frameRect = jsonFrame.at("frame");
    frame = std::move(PointRect(frameRect.at(ZERO).get<int>(), frameRect.at(ONE).get<int>(),
        frameRect.at(TWO).get<int>(), frameRect.at(THREE).get<int>()));
    
    const auto& mFrameRect = jsonFrame.at("mFrame");
    mFrame = std::move(PointRect(mFrameRect.at(ZERO).get<int>(), mFrameRect.at(ONE).get<int>(),
        mFrameRect.at(TWO).get<int>(), mFrameRect.at(THREE).get<int>()));
    
    mt = jsonFrame.at("mt").get<int>();
    json j(frameRect);
}

FrameSet::FrameSet(json jsonObj)
{
    index = jsonObj.at("i").get<int>();
    auto objJsonArray = jsonObj.at("obj");
    size_t objLen = objJsonArray.size();
    for (int i = 0; i < objLen; i++) {
        auto frameJson = objJsonArray[i];
        Frame frame = Frame(frameJson);
        frames.push_back(frame);
    }
    std::sort(frames.begin(), frames.end());
}

FrameAll::FrameAll(json jsonObj)
{
    auto frameJsonArray = jsonObj.at("frame");
    size_t frameLen = frameJsonArray.size();
    LOGD("enter FrameAll frame size: %{public}lu", frameLen);
    for (int i = 0; i < frameLen; i++) {
        auto frameSetJson = frameJsonArray[i];
        auto frameSet = FrameSet(frameSetJson);
        frameAll.insert(std::make_pair(frameSet.index, frameSet));
    }
}

void Frame::PrintInfo()
{
    LOGD("srcId: %{public}s z: %{public}d, frame:[%{public}d, %{public}d, %{public}d, %{public}d],"
        "mFrame:[%{public}d, %{public}d, %{public}d, %{public}d], mt: %{public}d", srcId.c_str(), z,
        frame.x, frame.y, frame.w, frame.h, mFrame.x, mFrame.y, mFrame.w, mFrame.h, mt);
}