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

#ifndef VAP_PLUGIN_MANAGER_H
#define VAP_PLUGIN_MANAGER_H

#include <string>
#include <unordered_map>

#include <js_native_api.h>
#include <js_native_api_types.h>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <napi/native_api.h>

#include "plugin_render.h"

class PluginManager {
public:
    ~PluginManager();

    static PluginManager *GetInstance()
    {
        return &PluginManager::m_pluginManager;
    }

    static napi_value GetContext(napi_env env, napi_callback_info info);

    /* ************************APP Lifecycle****************************** */
    static napi_value NapiOnCreate(napi_env env, napi_callback_info info);
    static napi_value NapiOnShow(napi_env env, napi_callback_info info);
    static napi_value NapiOnHide(napi_env env, napi_callback_info info);
    static napi_value NapiOnDestroy(napi_env env, napi_callback_info info);

    /* ***********************ArkTS Page : Lifecycle********************** */
    static napi_value NapiToAppear(napi_env env, napi_callback_info info);
    static napi_value NapiToDisappear(napi_env env, napi_callback_info info);
    static napi_value NapiOnPageShow(napi_env env, napi_callback_info info);
    static napi_value NapiOnPageHide(napi_env env, napi_callback_info info);

    void SetNativeXComponent(std::string &id, OH_NativeXComponent *nativeXComponent);
    PluginRender *GetRender(std::string &id);
    void Export(napi_env env, napi_value exports);

private:
    static void RegisterLifecycle(napi_env env, napi_value exports, int64_t value);

private:
    static PluginManager m_pluginManager;

    std::unordered_map<std::string, OH_NativeXComponent *> m_nativeXComponentMap;
    std::unordered_map<std::string, PluginRender *> m_pluginRenderMap;
};
#endif // VAP_PLUGIN_MANAGER_H