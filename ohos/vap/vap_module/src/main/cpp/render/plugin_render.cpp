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

#include "plugin_render.h"

#include <multimedia/image_framework/image/image_source_native.h>
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <cstdint>
#include <string>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <log.h>
#include <uv.h>
#include <optional>

#include "napi/n_func_arg.h"

std::unordered_map<std::string, std::shared_ptr<PluginRender>> PluginRender::m_instance;
OH_NativeXComponent_Callback PluginRender::m_callback;

static void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window)
{
    LOGD("OnSurfaceCreatedCB");
    if ((nullptr == component) || (nullptr == window)) {
        LOGE("OnSurfaceCreatedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + ONE] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + ONE;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        LOGE("OnSurfaceCreatedCB: Unable to get XComponent id");
        return;
    }
    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    uint64_t width;
    uint64_t height;
    int32_t xSize = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    if ((OH_NATIVEXCOMPONENT_RESULT_SUCCESS == xSize) && (nullptr != render)) {
        render->m_window = window;
        render->m_component = component;
        render->m_width = width;
        render->m_height= height;
        render->player_ = std::make_unique<Player>();
    }
}

static void OnSurfaceChangedCB(OH_NativeXComponent *component, void *window)
{
    LOGD("OnSurfaceChangedCB");
    if ((nullptr == component) || (nullptr == window)) {
        LOGE("OnSurfaceChangedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + ONE] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + ONE;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        LOGE("OnSurfaceChangedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (nullptr != render) {
        uint64_t width = 0;
        uint64_t height = 0;
        OH_NativeXComponent_GetXComponentSize(render->m_component, render->m_window, &width, &height);
        if (render->player_->eglCore_) {
            render->player_->eglCore_->UpdateSize(width, height);
        }
    }
}

static void OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window)
{
    LOGD("OnSurfaceDestroyedCB");
    if ((nullptr == component) || (nullptr == window)) {
        LOGE("OnSurfaceDestroyedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + ONE] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + ONE;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        LOGE("OnSurfaceDestroyedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (nullptr != render) {
        render->player_->NoticeDestroyed();
    }
    PluginRender::Release(id);
    render->deleteRenderCallback_(id);
    PluginRender::m_instance.erase(id);
}

static void DispatchTouchEventCB(OH_NativeXComponent *component, void *window)
{
    LOGD("DispatchTouchEventCB");
    if ((nullptr == component) || (nullptr == window)) {
        LOGE("DispatchTouchEventCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + ONE] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + ONE;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        LOGE("DispatchTouchEventCB: Unable to get XComponent id");
        return;
    }
    
    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (nullptr != render) {
        LOGD("surface touch");
        OH_NativeXComponent_TouchEvent touchEvent;
        int32_t ret = OH_NativeXComponent_GetTouchEvent(component, window, &touchEvent);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGI("Touch Info : x = %{public}f, y = %{public}f screenx = %{public}f, screeny = %{public}f",
                 touchEvent.x, touchEvent.y, touchEvent.screenX, touchEvent.screenY);
            for (uint32_t i = 0; i < touchEvent.numPoints; i++) {
                LOGI("Touch Info : dots[%{public}d] id %{public}d x = %{public}f, y = %{public}f", i,
                     touchEvent.touchPoints[i].id, touchEvent.touchPoints[i].x, touchEvent.touchPoints[i].y);
                LOGI("Touch Info : screenx = %{public}f, screeny = %{public}f",
                     touchEvent.touchPoints[i].screenX, touchEvent.touchPoints[i].screenY);
                OH_NativeXComponent_TouchPointToolType toolType;
                float tiltX = 0.0;
                float tiltY = 0.0;
                int32_t ret = OH_NativeXComponent_GetTouchPointToolType(component, i, &toolType);
                ret = OH_NativeXComponent_GetTouchPointTiltX(component, i, &tiltX);
                ret = OH_NativeXComponent_GetTouchPointTiltY(component, i, &tiltY);
                LOGI("Touch Info : [%{public}d] %{public}u, %{public}f, %{public}f",
                     i, toolType, tiltX, tiltY);
            }
            render->player_->XComponentClick(touchEvent.x, touchEvent.y);
        } else {
            LOGE("Touch fail");
        }
    }
}

PluginRender::PluginRender(std::string &id)
{
    this->m_id = id;
    OH_NativeXComponent_Callback *renderCallback = &PluginRender::m_callback;
    renderCallback->OnSurfaceCreated = OnSurfaceCreatedCB;
    renderCallback->OnSurfaceChanged = OnSurfaceChangedCB;
    renderCallback->OnSurfaceDestroyed = OnSurfaceDestroyedCB;
    renderCallback->DispatchTouchEvent = DispatchTouchEventCB;
}

std::shared_ptr<PluginRender> PluginRender::GetInstance(std::string &id, bool onlyFind)
{
    if (onlyFind) {
        return m_instance.find(id) == m_instance.end() ? nullptr : m_instance[id];
    }

    if (m_instance.find(id) == m_instance.end()) {
        std::shared_ptr<PluginRender> instance = std::make_shared<PluginRender>(id);
        m_instance[id] = instance;
        return instance;
    } else {
        return m_instance[id];
    }
}

std::string PluginRender::GetXComponentId(napi_env env, napi_callback_info info)
{
    napi_value thisArg = nullptr;
    napi_value exportInstance = nullptr;
    OH_NativeXComponent *nativeXComponent = nullptr;
    std::string id = "";

    napi_get_cb_info(env, info, NULL, NULL, &thisArg, NULL);
    bool isExit = false;
    napi_has_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &isExit);
    if (!isExit || (napi_ok != napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance))) {
        LOGE("Play: napi_get_named_property fail");
        return id;
    }
    
    if (exportInstance == nullptr) {
        LOGE("Play: napi_get_named_property fail");
        return id;
    }
    
    if (napi_ok != napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent))) {
        LOGE("Play: napi_unwrap fail");
        return id;
    }
    
    if (nativeXComponent == nullptr) {
        return id;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + ONE] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + ONE;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize)) {
        LOGE("Play: Unable to get XComponent id");
        return id;
    }
    id = idStr;
    return id;
}

napi_value PluginRender::Pause(napi_env env, napi_callback_info info)
{
    LOGD("enter pause");
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ZERO, NARG_CNT::ONE)) {
        return nullptr;
    }
    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, resData, length] = nVal.ToUTF8String();
    std::string id = resData.get();

    LOGD("Pause render id:%{public}s", id.c_str());
    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (render) {
        render->player_->PauseAndResume();
    }
    return nullptr;
    LOGD("end pause");
}

napi_value PluginRender::Stop(napi_env env, napi_callback_info info)
{
    LOGD("enter Stop");
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ZERO, NARG_CNT::ONE)) {
        return nullptr;
    }
    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, resData, length] = nVal.ToUTF8String();
    std::string id = resData.get();
    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (render && render->player_) {
        render->player_->Stop();
    }
    LOGD("end Stop");
    return nullptr;
}

napi_value PluginRender::SetLoop(napi_env env, napi_callback_info info)
{
    LOGD("enter SetLoop");
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        return nullptr;
    }
    napi_value v1 = funcArg.GetArg(NARG_POS::SECOND);
    NVal nVal(env, v1);
    auto [succ, resData, length] = nVal.ToUTF8String();
    std::string id = resData.get();
    
    LOGD("SetLoop render id:%{public}s", id.c_str());
    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (render) {
        napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
        NVal nVal(env, v1);
        auto [succ, resData] = nVal.ToInt32();
        LOGD("SetLoop loop: %{public}d", resData);
        if (succ) {
            render->player_->SetLoop(resData);
        } else {
            LOGE("SetLoop cont get val");
        }
    }
    LOGD("end SetLoop");
    return nullptr;
}

static void GenSrcInfo(napi_env env, std::map<std::string, Src> &src, napi_value &srcInfos)
{
    size_t i = 0;
    for (auto ele: src) {
        auto srcInfo = NVal::CreateObject(env);
        auto srcId = NVal::CreateInt64(env, atoi(ele.first.c_str()));
        auto tag = NVal::CreateUTF8String(env, ele.second.srcTag);
        auto type = NVal::CreateInt64(env, static_cast<int>(ele.second.srcType));
        srcInfo.AddProp("srcId", srcId.val_);
        srcInfo.AddProp("tag", tag.val_);
        srcInfo.AddProp("type", type.val_);
        napi_status status = napi_set_element(env, srcInfos, i, srcInfo.val_);
        if (status != napi_ok) {
            LOGE("Failed to create srcInfos with napi wrapper object.");
        }
        i++;
    }
}

napi_value PluginRender::GetVideoInfo(napi_env env, napi_callback_info info)
{
    LOGD("enter GetVideoInfo");
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        return nullptr;
    }
    napi_value jsId = funcArg.GetArg(NARG_POS::SECOND);
    NVal jsIdVal(env, jsId);
    auto [jsIdSucc, jsIdResData, jsIdLength] = jsIdVal.ToUTF8String();
    std::string id = jsIdResData.get();

    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (!render) {
        LOGE("get env error");
        return nullptr;
    }

    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, resStr, length] = nVal.ToUTF8String();
    if (!succ) {
        LOGE("arg type error.");
        return nullptr;
    }
    AnimConfig animConfig;
    animConfig.ParseJson(resStr.get(), false);
    
    std::map<std::string, Src> src;
    animConfig.GetSrc(src);
    napi_value srcInfos = nullptr;
    
    if (!src.empty()) {
        napi_status status = napi_create_array(env, &srcInfos);
        if (status == napi_ok) {
            GenSrcInfo(env, src, srcInfos);
        }
    }
    
    auto videoInfo = NVal::CreateObject(env);
    auto width = NVal::CreateInt64(env, animConfig.width);
    auto height = NVal::CreateInt64(env, animConfig.height);
    videoInfo.AddProp("width", width.val_);
    videoInfo.AddProp("height", height.val_);
    videoInfo.AddProp("srcInfos", srcInfos);
    return videoInfo.val_;
}

napi_value PluginRender::SetFitType(napi_env env, napi_callback_info info)
{
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        return nullptr;
    }
    napi_value jsId = funcArg.GetArg(NARG_POS::SECOND);
    NVal jsIdVal(env, jsId);
    auto [jsIdSucc, jsIdResData, jsIdLength] = jsIdVal.ToUTF8String();
    std::string id = jsIdResData.get();
    
    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (!render) {
        LOGE("Not get render");
        return nullptr;
    }
    
    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, res] = nVal.ToInt32();
    if (!succ) {
        LOGE("cont first int arg error");
        return nullptr;
    }
    VideoFitType fitType = VideoFitType::FIT_XY;
    if (res == static_cast<int>(VideoFitType::FIT_XY) ||
       res == static_cast<int>(VideoFitType::FIT_CENTER) ||
       res == static_cast<int>(VideoFitType::CENTER_CROP)) {
        fitType = static_cast<VideoFitType>(res);
    } else {
        LOGE("invalid fitType %{public}d", res);
        return nullptr;
    }
    LOGD("SetFitType %{public}d %{public}d ", static_cast<int32_t>(fitType), res);
    render->player_->SetFitType(fitType);
    return nullptr;
}

napi_value PluginRender::SetVideoMode(napi_env env, napi_callback_info info)
{
    LOGD("enter SetVideoMode");
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        return nullptr;
    }
    napi_value jsId = funcArg.GetArg(NARG_POS::SECOND);
    NVal jsIdVal(env, jsId);
    auto [jsIdSucc, jsIdResData, jsIdLength] = jsIdVal.ToUTF8String();
    std::string id = jsIdResData.get();

    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (!render) {
        LOGE("Not get render");
        return nullptr;
    }
    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, res] = nVal.ToInt32();
    if (!succ) {
        LOGE("cont first int arg error");
        return nullptr;
    }
    VideoMode videoMode = VIDEO_MODE_SPLIT_HORIZONTAL;
    if (res == static_cast<int>(VideoMode::VIDEO_MODE_SPLIT_HORIZONTAL) ||
       res == static_cast<int>(VideoMode::VIDEO_MODE_SPLIT_VERTICAL) ||
       res == static_cast<int>(VideoMode::VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE) ||
       res == static_cast<int>(VideoMode::VIDEO_MODE_SPLIT_VERTICAL_REVERSE)) {
        videoMode = static_cast<VideoMode>(res);
    } else {
        LOGE("invalid fitType %{public}d", res);
        return nullptr;
    }
    LOGD("SetVideoMode %{public}d %{public}d ", static_cast<int32_t>(videoMode), res);
    render->player_->SetVideoMode(videoMode);
    return nullptr;
}

napi_value PluginRender::SetSpeed(napi_env env, napi_callback_info info)
{
    LOGD("enter SetSpeed");
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        return nullptr;
    }
    napi_value jsId = funcArg.GetArg(NARG_POS::SECOND);
    NVal jsIdVal(env, jsId);
    auto [jsIdSucc, jsIdResData, jsIdLength] = jsIdVal.ToUTF8String();
    std::string id = jsIdResData.get();

    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (!render) {
        LOGE("Not get render");
        return nullptr;
    }
    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, res] = nVal.ToFloat();
    if (!succ) {
        LOGE("cont first int arg error");
        return nullptr;
    }
    float speed = std::clamp(res, 0.25f, 4.0f);
    LOGD("SetSpeed in: %{public}f -- %{public}f", res, speed);
    render->player_->SetSpeed(speed);
    return nullptr;
}

void PluginRender::Export(napi_env env, napi_value exports)
{
    if ((nullptr == env) || (nullptr == exports)) {
        LOGE("Export: env or exports is null");
        return;
    }
    this->env_ = env;

    napi_property_descriptor desc[] = {
        { "play", nullptr, PluginRender::Play, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "on", nullptr, PluginRender::On, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "off", nullptr, PluginRender::Off, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "pause", nullptr, PluginRender::Pause, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "stop", nullptr, PluginRender::Stop, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "setLoop", nullptr, PluginRender::SetLoop, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "setFitType", nullptr, PluginRender::SetFitType, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "setVideoMode", nullptr, PluginRender::SetVideoMode, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "getVideoInfo", nullptr, PluginRender::GetVideoInfo, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "setSpeed", nullptr, PluginRender::SetSpeed, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    if (napi_ok != napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc)) {
        LOGE("Export: napi_define_properties failed");
    }
}

static std::optional<OH_Drawing_TextAlign> intToTextAlign(int value)
{
    switch (value) {
        case static_cast<int>(OH_Drawing_TextAlign::TEXT_ALIGN_CENTER):
            return OH_Drawing_TextAlign::TEXT_ALIGN_CENTER;
        case static_cast<int>(OH_Drawing_TextAlign::TEXT_ALIGN_JUSTIFY):
            return OH_Drawing_TextAlign::TEXT_ALIGN_JUSTIFY;
        case static_cast<int>(OH_Drawing_TextAlign::TEXT_ALIGN_START):
            return OH_Drawing_TextAlign::TEXT_ALIGN_START;
        case static_cast<int>(OH_Drawing_TextAlign::TEXT_ALIGN_END):
            return OH_Drawing_TextAlign::TEXT_ALIGN_END;
        case static_cast<int>(OH_Drawing_TextAlign::TEXT_ALIGN_LEFT):
            return OH_Drawing_TextAlign::TEXT_ALIGN_LEFT;
        case static_cast<int>(OH_Drawing_TextAlign::TEXT_ALIGN_RIGHT):
            return OH_Drawing_TextAlign::TEXT_ALIGN_RIGHT;
        default:
            return std::nullopt;
    }
}

static std::optional<OH_Drawing_FontWeight> intToFontWeight(int value)
{
    switch (value) {
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_100):
            return OH_Drawing_FontWeight::FONT_WEIGHT_100;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_200):
            return OH_Drawing_FontWeight::FONT_WEIGHT_200;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_300):
            return OH_Drawing_FontWeight::FONT_WEIGHT_300;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_400):
            return OH_Drawing_FontWeight::FONT_WEIGHT_400;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_500):
            return OH_Drawing_FontWeight::FONT_WEIGHT_500;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_600):
            return OH_Drawing_FontWeight::FONT_WEIGHT_600;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_700):
            return OH_Drawing_FontWeight::FONT_WEIGHT_700;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_800):
            return OH_Drawing_FontWeight::FONT_WEIGHT_800;
        case static_cast<int>(OH_Drawing_FontWeight::FONT_WEIGHT_900):
            return OH_Drawing_FontWeight::FONT_WEIGHT_900;
        default:
            return std::nullopt;
    }
}

static void ParseMixParamTag(NVal &nValOneOpt, std::string &tag)
{
    if (nValOneOpt.HasProp(PROP_TAG)) {
        auto [succ, resData, length] = nValOneOpt.GetProp(PROP_TAG).ToUTF8String();
        if (succ) {
            LOGD("parse mix tag %{public}s", resData.get());
            tag = resData.get();
        } else {
            LOGE("parse mix tag not set");
            return;
        }
    }
}

static void ParseMixParamTxt(NVal &nValOneOpt, MixInputData &mixInputData)
{
    if (nValOneOpt.HasProp(PROP_TXT)) {
        LOGD("parse mix txt");
        auto [txtSucc, resData, length] = nValOneOpt.GetProp(PROP_TXT).ToUTF8String();
        if (txtSucc) {
            mixInputData.txt = resData.get();
            LOGD("parse mix txt %{public}s", resData.get());
        }
    }
}

static void ParseMixParamImg(NVal &nValOneOpt, MixInputData &mixInputData)
{
    if (nValOneOpt.HasProp(PROP_IMAGE)) {
        LOGD("parse mix img");
        auto [imgSucc, resData, length] = nValOneOpt.GetProp(PROP_IMAGE).ToUTF8String();
        if (imgSucc) {
            mixInputData.imgUri = resData.get();
        }
    }
}

static void ParseMixParamColor(NVal &nValOneOpt, MixInputData &mixInputData)
{
    if (nValOneOpt.HasProp(PROP_COLOR)) {
        auto colorNVal = nValOneOpt.GetProp(PROP_COLOR);
        if (colorNVal) {
            auto [succA, a] = colorNVal.GetProp("a").ToUint32();
            auto [succR, r] = colorNVal.GetProp("r").ToUint32();
            auto [succG, g] = colorNVal.GetProp("g").ToUint32();
            auto [succB, b] = colorNVal.GetProp("b").ToUint32();
            
            if (succA && succB && succR && succG) {
                mixInputData.color = {a, r, g, b};
                mixInputData.isSet |= SET_COLOR;
                LOGD("parse mix color %{public}x argb: %{public}02x-%{public}02x-%{public}02x-%{public}02x",
                    mixInputData.isSet, a, r, g, b);
            }
        }
    }
}

static void ParseMixParamFontWeight(NVal &nValOneOpt, MixInputData &mixInputData)
{
    if (nValOneOpt.HasProp(PROP_FONT_WEIGHT)) {
        auto [succ, resData] = nValOneOpt.GetProp(PROP_FONT_WEIGHT).ToInt32();
        if (succ) {
            auto fontWeight = intToFontWeight(resData);
            if (fontWeight) {
                mixInputData.fontWeight = fontWeight.value();
                mixInputData.isSet |= SET_FONT_WEIGHT;
                LOGD("parse mix fontWeight %{public}x fw: %{public}d", mixInputData.isSet, resData);
            }
        }
    }
}

static void ParseMixParamTextAlign(NVal &nValOneOpt, MixInputData &mixInputData)
{
    if (nValOneOpt.HasProp(PROP_TEXT_ALIGN)) {
        auto [succ, resData] = nValOneOpt.GetProp(PROP_TEXT_ALIGN).ToInt32();
        if (succ) {
            auto textAlign = intToTextAlign(resData);
            if (textAlign) {
                mixInputData.textAlign = textAlign.value();
                mixInputData.isSet |= SET_TEXT_ALIGN;
                LOGD("parse mix textAlign %{public}x ta: %{public}d", mixInputData.isSet, resData);
            }
        }
    }
}

static void ParseMixParam(std::map<std::string, MixInputData> &mixData, napi_env env, NFuncArg &funcArg)
{
    napi_value v2 = funcArg.GetArg(NARG_POS::SECOND);
    if (!v2) {
        LOGE("not get second param");
        return;
    }
    
    NVal nVal2(env, v2);
    auto [succ1, isArray] = nVal2.IsArray();
    if (!succ1 || !isArray) {
        LOGE("the second param is not array");
        return;
    }
    uint32_t len = ZERO;
    napi_get_array_length(env, v2, &len);
    if (len == ZERO) {
        LOGE("the array is empty");
        return;
    }
    
    for (uint32_t i = 0; i < len; i++) {
        napi_value element;
        napi_get_element(env, v2, i, &element);
        NVal nValOneOpt(env, element);
        MixInputData mixInputData;
        
        std::string tag;
        ParseMixParamTag(nValOneOpt, tag);
        ParseMixParamTxt(nValOneOpt, mixInputData);
        ParseMixParamImg(nValOneOpt, mixInputData);
        ParseMixParamColor(nValOneOpt, mixInputData);
        ParseMixParamFontWeight(nValOneOpt, mixInputData);
        ParseMixParamTextAlign(nValOneOpt, mixInputData);
        
        LOGD("parse mix data tag%{public}s ta: %{public}d fw: %{public}d", tag.c_str(),
            mixInputData.textAlign, mixInputData.fontWeight);
        mixData.insert(std::make_pair(tag, mixInputData));
    }
}

static void CreateAnimConfig(napi_env env, JSAnimConfig &jsAnimConfig, NVal &animConfig)
{
    auto alphaRect = NVal::CreateObject(env);
    auto x = NVal::CreateInt64(env, jsAnimConfig.alphaPointRect.x);
    auto y = NVal::CreateInt64(env, jsAnimConfig.alphaPointRect.y);
    auto w = NVal::CreateInt64(env, jsAnimConfig.alphaPointRect.w);
    auto h = NVal::CreateInt64(env, jsAnimConfig.alphaPointRect.h);
    alphaRect.AddProp("x", x.val_);
    alphaRect.AddProp("y", y.val_);
    alphaRect.AddProp("w", w.val_);
    alphaRect.AddProp("h", h.val_);
    
    auto rgbRect = NVal::CreateObject(env);
    auto x1 = NVal::CreateInt64(env, jsAnimConfig.rgbPointRect.x);
    auto y1 = NVal::CreateInt64(env, jsAnimConfig.rgbPointRect.y);
    auto w1 = NVal::CreateInt64(env, jsAnimConfig.rgbPointRect.w);
    auto h1 = NVal::CreateInt64(env, jsAnimConfig.rgbPointRect.h);
    rgbRect.AddProp("x", x1.val_);
    rgbRect.AddProp("y", y1.val_);
    rgbRect.AddProp("w", w1.val_);
    rgbRect.AddProp("h", h1.val_);
    
    auto version = NVal::CreateInt64(env, jsAnimConfig.version);
    auto totalFrames = NVal::CreateInt64(env, jsAnimConfig.totalFrames);
    auto width = NVal::CreateInt64(env, jsAnimConfig.width);
    auto height = NVal::CreateInt64(env, jsAnimConfig.height);
    auto videoWidth = NVal::CreateInt64(env, jsAnimConfig.videoWidth);
    auto videoHeight = NVal::CreateInt64(env, jsAnimConfig.videoHeight);
    auto orien = NVal::CreateInt64(env, jsAnimConfig.orien);
    auto fps = NVal::CreateInt64(env, jsAnimConfig.fps);
    auto isMix = NVal::CreateBool(env, jsAnimConfig.isMix);
    auto currentFrame = NVal::CreateInt64(env, jsAnimConfig.currentFrame);
    
    animConfig.AddProp("version", version.val_);
    animConfig.AddProp("totalFrames", totalFrames.val_);
    animConfig.AddProp("width", width.val_);
    animConfig.AddProp("height", height.val_);
    animConfig.AddProp("videoWidth", videoWidth.val_);
    animConfig.AddProp("videoHeight", videoHeight.val_);
    animConfig.AddProp("orien", orien.val_);
    animConfig.AddProp("fps", fps.val_);
    animConfig.AddProp("isMix", isMix.val_);
    animConfig.AddProp("alphaPointRect", alphaRect.val_);
    animConfig.AddProp("rgbPointRect", rgbRect.val_);
    animConfig.AddProp("currentFrame", currentFrame.val_);
}

void Callback(void *asyncContext)
{
    LOGD("enter Callback");
    if (asyncContext == nullptr) {
        LOGE("Callback asyncContext is nullptr");
        return;
    }
    uv_loop_s *loop = nullptr;
    CallbackContext *context = (CallbackContext *)asyncContext;
    napi_status status = napi_get_uv_event_loop(context->env, &loop);
    if (status != napi_ok) {
        LOGE("Callback con not napi_get_uv_event_loop %{public}d", status);
        delete context;
        return;
    }
    uv_work_t *work = new uv_work_t;
    work->data = context;
    uv_queue_work(loop, work, [](uv_work_t *work) { LOGD("enter uv_work_t Callback"); },
        [](uv_work_t *work, int status) {
            LOGD("enter complete Callback");
            CallbackContext *context = (CallbackContext *)work->data;
            napi_handle_scope scope = nullptr;
            napi_status ret = napi_open_handle_scope(context->env, &scope);
            napi_value callback = nullptr;
            ret = napi_get_reference_value(context->env, context->callbackRef, &callback);
            if (ret != napi_ok) {
                LOGE("callback napi_get_reference_value error %{public}d", ret);
            } else if (context && context->vapState == VapState::FAILED) {
                napi_value ret[2];
                napi_create_int32(context->env, context->vapState, &ret[0]);
                napi_create_int32(context->env, context->err, &ret[1]);
                napi_value res = nullptr;
                napi_call_function(context->env, nullptr, callback, 2, ret, &res);
            } else if (context && (context->vapState == VapState::RENDER || context->vapState == VapState::START)) {
                auto animConfig = NVal::CreateObject(context->env);
                CreateAnimConfig(context->env, context->jsAnimConfig, animConfig);
                napi_value ret[2];
                napi_create_int32(context->env, context->vapState, &ret[0]);
                ret[1] = animConfig.val_;
                napi_value res = nullptr;
                napi_call_function(context->env, nullptr, callback, 2, ret, &res);
            } else if (context) {
                napi_value rev = nullptr;
                napi_create_int32(context->env, context->vapState, &rev);
                napi_value res = nullptr;
                napi_call_function(context->env, nullptr, callback, 1, &rev, &res);
            }

            if (context->vapState == VapState::UNKNOWN) {
                napi_delete_reference(context->env, context->callbackRef);
            }
            napi_close_handle_scope(context->env, scope);
            delete context;
            delete work;
        });
}

void PluginRender::ParseCallback(napi_ref &callbackRef, napi_env env, napi_value val, std::string type)
{
    LOGD("enter ParseCallback %{public}s", type.c_str());
    if (!val) {
        LOGE("not get callback param");
        return;
    }
    
    napi_status createRet = napi_create_reference(env, val, 1, &callbackRef);
    if (createRet != napi_ok) {
        LOGE("napi_create_reference error-%{public}d", createRet);
        return;
    }
}

napi_value PluginRender::Play(napi_env env, napi_callback_info info)
{
    LOGD("enter Play");
    std::string id = "";
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::FOUR)) {
        return nullptr;
    }

    napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
    NVal nVal(env, v1);
    auto [succ, resData, length] = nVal.ToUTF8String();
    std::string str = resData.get();
    
    if (funcArg.GetMaxArgc() >= FOUR) {
        napi_value jsId = funcArg.GetArg(NARG_POS::FOURTH);
        NVal idVal(env, jsId);
        auto [succ, resData, length] = idVal.ToUTF8String();
        id = resData.get();
    }

    if (id.empty()) {
        return nullptr;
    }

    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (render) {
        std::string uri = str;
        if (uri.empty()) {
            LOGE("Play: uri empty");
            return nullptr;
        }
        VAPInfo info;
        std::map<std::string, MixInputData> mixData;
        if (funcArg.GetMaxArgc() >= TWO) {
            ParseMixParam(mixData, env, funcArg);
        }
        if (render->player_ == nullptr) {
            return nullptr;
        }
        if (funcArg.GetMaxArgc() >= THREE) {
            std::string type = "playDone";
            napi_value v3 = funcArg.GetArg(NARG_POS::THIRD);
            napi_ref callbackRef = nullptr;
            render->ParseCallback(callbackRef, env, v3, type);
            render->env_ = env;
            render->player_->SetCallback(CallbackType::PLAY_DONE, callbackRef, &Callback);
        }
        info.uri = uri;
        info.window = static_cast<NativeWindow*>(render->m_window);
        info.width = render->m_width;
        info.height = render->m_height;
        info.iptData = mixData;
        render->player_->env_ = env;
        render->player_->Init(info);
        LOGD("Player Start executed");
    }
    return nullptr;
}

napi_value PluginRender::On(napi_env env, napi_callback_info info)
{
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::TWO, NARG_CNT::THREE)) {
        return nullptr;
    }

    napi_value v1 = funcArg.GetArg(NARG_POS::THIRD);
    NVal nVal(env, v1);
    auto [succ, resData, length] = nVal.ToUTF8String();
    std::string id = resData.get();

    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (render && render->player_) {
        if (render->player_->IsRunning()) {
            LOGE("the player is running...plz call this func before play.");
            return nullptr;
        }
        napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
        NVal nVal(env, v1);
        auto [succ, resData, length] = nVal.ToUTF8String();
        std::string str = resData.get();
        LOGD("Get Count of argc %{public}zu str:%{public}s", funcArg.GetMaxArgc(), str.c_str());
        if (str != "stateChange" && str != "click") {
            LOGE("not support event");
            return nullptr;
        }
        void (*callback)(void *context) = nullptr;
        napi_ref callbackRef = nullptr;
        if (funcArg.GetMaxArgc() >= TWO) {
            napi_value v2 = funcArg.GetArg(NARG_POS::SECOND);
            callback = &Callback;
            render->ParseCallback(callbackRef, env, v2, str);
            render->env_ = env;
        }
        if (callback && callbackRef) {
            render->player_->env_ = env;
            if (str == "click") {
                render->player_->SetCallback(CallbackType::CLICK, callbackRef, callback);
            } else if (str == "stateChange") {
                render->player_->SetCallback(CallbackType::STATE_CHANGE, callbackRef, callback);
            }
        }
    }
    return nullptr;
}

napi_value PluginRender::Off(napi_env env, napi_callback_info info)
{
    NFuncArg funcArg(env, info);
    if (!funcArg.InitArgs(NARG_CNT::ONE, NARG_CNT::TWO)) {
        LOGE("func 'off' Init args error.");
        return nullptr;
    }
    napi_value jsId = funcArg.GetArg(NARG_POS::SECOND);
    NVal nVal(env, jsId);
    auto [succ, resData, length] = nVal.ToUTF8String();
    std::string id = resData.get();
    LOGD("Off listener id:%{public}s", id.c_str());
    if (id.empty()) {
        LOGE("GetXComponentId error");
        return nullptr;
    }
    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (render) {
        if (render->player_->IsRunning()) {
            LOGE("the player is running...plz call this func before play.");
            return nullptr;
        }
        napi_value v1 = funcArg.GetArg(NARG_POS::FIRST);
        NVal nVal(env, v1);
        auto [succ, resData, length] = nVal.ToUTF8String();
        std::string str = resData.get();
        LOGD("Get Count of argc %{public}zu str:%{public}s", funcArg.GetMaxArgc(), str.c_str());
        CallbackType type = CallbackType::UNKNOWN;
        if (str == "stateChange") {
            type = CallbackType::STATE_CHANGE;
        } else if (str == "click") {
            type = CallbackType::CLICK;
        } else {
            LOGE("not support event");
            return nullptr;
        }
        render->player_->ClearCallback(type);
    }
    return nullptr;
}

void PluginRender::Release(std::string &id)
{
    std::shared_ptr<PluginRender> render = PluginRender::GetInstance(id);
    if (nullptr != render) {
        render->surfaceDestroyed_ = true;
    }
}
