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

#ifndef VAP_PLUGIN_RENDER_H
#define VAP_PLUGIN_RENDER_H

#include <string>
#include <unordered_map>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <napi/native_api.h>

#include "egl_core.h"
#include "napi/n_func_arg.h"
#include "player.h"

const std::string PROP_TAG = "tag";
const std::string PROP_TXT = "txt";
const std::string PROP_IMAGE = "imgUri";
const std::string PROP_COLOR = "color";
const std::string PROP_FONT_WEIGHT = "fontWeight";
const std::string PROP_TEXT_ALIGN = "textAlign";

class PluginRender {
public:
    explicit PluginRender(std::string &id);
    ~PluginRender()
    {
        if (player_) {
            player_->StartRelease();
        }
        m_instance.clear();
    }
    static std::shared_ptr<PluginRender> GetInstance(std::string &id, bool onlyFind = true);
    static void Release(std::string &id);
    static std::string GetXComponentId(napi_env env, napi_callback_info info);
    
    static napi_value Play(napi_env env, napi_callback_info info);
    static napi_value On(napi_env env, napi_callback_info info);
    static napi_value Pause(napi_env env, napi_callback_info info);
    static napi_value Stop(napi_env env, napi_callback_info info);
    static napi_value SetLoop(napi_env env, napi_callback_info info);
    static napi_value SetFitType(napi_env env, napi_callback_info info);
    static napi_value GetVideoInfo(napi_env env, napi_callback_info info);
    static napi_value SetVideoMode(napi_env env, napi_callback_info info);
    static napi_value SetSpeed(napi_env env, napi_callback_info info);
    static napi_value Off(napi_env env, napi_callback_info info);
    
    void Export(napi_env env, napi_value exports);

public:
    static std::unordered_map<std::string, std::shared_ptr<PluginRender>> m_instance; // 标个点
    static OH_NativeXComponent_Callback m_callback;
    void ParseCallback(napi_ref &callbackRef, napi_env env, napi_value val, std::string type);
    
    std::string m_id;
    std::function<void(const std::string&)> deleteRenderCallback_ {nullptr};
    void *m_window = nullptr;
    OH_NativeXComponent *m_component = nullptr;
    uint64_t m_width;
    uint64_t m_height;
    std::unique_ptr<Player> player_ = nullptr;
    
    napi_env env_ = nullptr;
    bool surfaceDestroyed_ = false;
};
#endif // VAP_PLUGIN_RENDER_H
