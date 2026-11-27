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

#include <cstdint>
#include <string>
#include <cstdio>

#include <ace/xcomponent/native_interface_xcomponent.h>
#include <hilog/log.h>

#include "plugin_manager.h"

PluginManager PluginManager::m_pluginManager;

static const size_t GET_CONTEXT_PARAM_CNT = 1;

enum ContextType {
    APP_LIFECYCLE,
    PAGE_LIFECYCLE,
};

PluginManager::~PluginManager()
{
    for (auto iter = m_nativeXComponentMap.begin(); iter != m_nativeXComponentMap.end(); ++iter) {
        if (nullptr != iter->second) {
            // delete iter->second;
            iter->second = nullptr;
        }
    }
    m_nativeXComponentMap.clear();

    for (auto iter = m_pluginRenderMap.begin(); iter != m_pluginRenderMap.end(); ++iter) {
        if (nullptr != iter->second) {
            delete iter->second;
            iter->second = nullptr;
        }
    }
    m_pluginRenderMap.clear();
}

napi_value PluginManager::GetContext(napi_env env, napi_callback_info info)
{
    if ((nullptr == env) || (nullptr == info)) {
        LOGE("GetContext env or info is null");
        return nullptr;
    }

    size_t argCnt = GET_CONTEXT_PARAM_CNT;
    napi_value args[GET_CONTEXT_PARAM_CNT] = { nullptr };
    if (napi_ok != napi_get_cb_info(env, info, &argCnt, args, nullptr, nullptr)) {
        LOGE("GetContext napi_get_cb_info failed");
    }

    if (GET_CONTEXT_PARAM_CNT != argCnt) {
        napi_throw_type_error(env, NULL, "Wrong number of arguments");
        return nullptr;
    }

    napi_valuetype valuetype;
    if (napi_ok != napi_typeof(env, args[0], &valuetype)) {
        napi_throw_type_error(env, NULL, "napi_typeof failed");
        return nullptr;
    }

    if (napi_number != valuetype) {
        napi_throw_type_error(env, NULL, "Wrong type of arguments");
        return nullptr;
    }

    int64_t value;
    if (napi_ok != napi_get_value_int64(env, args[0], &value)) {
        napi_throw_type_error(env, NULL, "napi_get_value_int64 failed");
        return nullptr;
    }

    napi_value exports;
    if (napi_ok != napi_create_object(env, &exports)) {
        napi_throw_type_error(env, NULL, "napi_create_object failed");
        return nullptr;
    }

    RegisterLifecycle(env, exports, value);

    return exports;
}

void PluginManager::RegisterLifecycle(napi_env env, napi_value exports, int64_t value)
{
    if ((nullptr == env) || (nullptr == exports)) {
        LOGE("RegisterLifecycle: env or exports is null");
        return;
    }

    switch (value) {
        case APP_LIFECYCLE: {
            LOGD("RegisterLifecycle: APP_LIFECYCLE");
            /* ****  Register App Lifecycle  **** */
            napi_property_descriptor desc[] = {
                {"onCreate", nullptr, PluginManager::NapiOnCreate, nullptr, nullptr, nullptr, napi_default, nullptr},
                {"onShow", nullptr, PluginManager::NapiOnShow, nullptr, nullptr, nullptr, napi_default, nullptr},
                {"onHide", nullptr, PluginManager::NapiOnHide, nullptr, nullptr, nullptr, napi_default, nullptr},
                {"onDestroy", nullptr, PluginManager::NapiOnDestroy, nullptr, nullptr, nullptr, napi_default, nullptr}
            };
            napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
            break;
        }
        case PAGE_LIFECYCLE: {
            LOGD("RegisterLifecycle: PAGE_LIFECYCLE");
            /* ****  Register Page Lifecycle  **** */
            napi_property_descriptor desc[] = {
                {"aboutToAppear", nullptr, PluginManager::NapiToAppear,
                    nullptr, nullptr, nullptr, napi_default, nullptr},
                {"aboutToDisappear", nullptr, PluginManager::NapiToDisappear,
                    nullptr, nullptr, nullptr, napi_default, nullptr},
                {"onPageShow", nullptr, PluginManager::NapiOnPageShow,
                    nullptr, nullptr, nullptr, napi_default, nullptr},
                {"onPageHide", nullptr, PluginManager::NapiOnPageHide,
                    nullptr, nullptr, nullptr, napi_default, nullptr}
            };
            napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
            break;
        }
        default: {
            LOGE("RegisterLifecycle: wrong type of value");
            break;
        }
    }
}

void PluginManager::Export(napi_env env, napi_value exports)
{
    if ((nullptr == env) || (nullptr == exports)) {
        LOGE("Export: env or exports is null");
        return;
    }

    napi_value exportInstance = nullptr;
    if (napi_ok != napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance)) {
        LOGE("Export: napi_get_named_property fail");
        return;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_ok != napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent))) {
        LOGE("Export: napi_unwrap fail");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize)) {
        LOGE("Export: OH_NativeXComponent_GetXComponentId fail");
        return;
    }

    std::string id(idStr);
    auto context = PluginManager::GetInstance();
    if ((nullptr != context) && (nullptr != nativeXComponent)) {
        context->SetNativeXComponent(id, nativeXComponent);
        auto render = context->GetRender(id);
        OH_NativeXComponent_RegisterCallback(nativeXComponent, &PluginRender::m_callback);
        if (nullptr != render) {
            render->Export(env, exports);
        }
    }
}

void PluginManager::SetNativeXComponent(std::string &id, OH_NativeXComponent *nativeXComponent)
{
    if (nullptr == nativeXComponent) {
        return;
    }

    if (m_nativeXComponentMap.find(id) == m_nativeXComponentMap.end()) {
        m_nativeXComponentMap[id] = nativeXComponent;
        return;
    }

    if (m_nativeXComponentMap[id] != nativeXComponent) {
        m_nativeXComponentMap[id] = nativeXComponent;
    }
}

PluginRender *PluginManager::GetRender(std::string &id)
{
    if (m_pluginRenderMap.find(id) == m_pluginRenderMap.end()) {
        PluginRender *instance = PluginRender::GetInstance(id);
        m_pluginRenderMap[id] = instance;
        return instance;
    }

    return m_pluginRenderMap[id];
}

napi_value PluginManager::NapiOnCreate(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiOnCreate");
    return nullptr;
}

napi_value PluginManager::NapiOnShow(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiOnShow");
    return nullptr;
}

napi_value PluginManager::NapiOnHide(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiOnHide");
    return nullptr;
}

napi_value PluginManager::NapiOnDestroy(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiOnDestroy");
    return nullptr;
}

napi_value PluginManager::NapiToAppear(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiToAppear");
    return nullptr;
}

napi_value PluginManager::NapiToDisappear(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiToDisappear");
    return nullptr;
}

napi_value PluginManager::NapiOnPageShow(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiOnPageShow");
    return nullptr;
}

napi_value PluginManager::NapiOnPageHide(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "PluginManager", "NapiOnPageHide");
    return nullptr;
}