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

#ifndef VAP_EGL_CORE_H
#define VAP_EGL_CORE_H

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <cstdint>
#include <memory>
#include <vector>
#include "mask_render.h"
#include "mix_render.h"
#include "data_info.h"
#include "yuv_render.h"

struct RenderData {
    std::vector<uint8_t> data;
    int32_t stride;
    int32_t sliceHeight;
    int32_t frameCurIdx;
};

class EGLCore {
public:
    explicit EGLCore(){};
    ~EGLCore() {}
    bool EglContextInit(EGLNativeWindowType window, int width, int height, std::string uri,
        std::map<std::string, MixInputData> &iptData);
    
    void SetFitType(VideoFitType fitType)
    {
        m_fitType = fitType;
    }
    
    void SetVideoMode(VideoMode videoMode)
    {
        m_defaultVideoMode = videoMode;
        if (m_animConfig) {
            m_animConfig->isDefaultConfig = true;
        }
    }
    
    void SetVideoSize(int32_t width, int32_t height, std::string mime)
    {
        m_videoWidth = width;
        m_videoHeight = height;
        m_isH265 = mime == MIME_VIDEO_HEVC;
    }
    bool CreateEnvironment();
    void Release();
    void Render(RenderData &renderData);
    bool SeparateYUV(const std::vector<uint8_t> &data,
        int alignWidth, int alignHeight, int videoWidth, int videoHeight);
    bool FinishLoad();
    void GetCurrentClickTxt(int32_t eventX, int32_t eventY, std::string &clickRes);
    
    void UpdateSize(int width, int height)
    {
        LOGD("enter UpdateSize %{public}d * %{public}d ", width, height);
        m_width = width;
        m_height = height;
    }
    
    std::shared_ptr<AnimConfig> m_animConfig;
private:
    VideoMode m_defaultVideoMode = VIDEO_MODE_SPLIT_HORIZONTAL;
    EGLConfig ChooseConfig();
    void GetAttributes(std::vector<int> &array);
    EGLContext CreateContext(EGLDisplay eglDisplay, EGLConfig eglConfig);
    void MixRenderFrame(int32_t frameCurIdx);
    void InitFitConfig();
    void FitCenter();
    void CenterCrop();
    void FitXY();

private:
    EGLNativeWindowType m_eglWindow;
    EGLDisplay m_eglDisplay = EGL_NO_DISPLAY;
    EGLConfig m_eglConfig = EGL_NO_CONFIG_KHR;
    EGLSurface m_eglSurface = EGL_NO_SURFACE;
    EGLContext m_eglContext = EGL_NO_CONTEXT;
    GLuint m_program;
    bool m_flag = false;
    int m_width;
    int m_height;
    GLfloat m_widthPercent;
    unsigned char *buf[3] = {0};
    std::unique_ptr<class YuvRender> m_render = nullptr;
    std::unique_ptr<class MixRender> m_mixRender = nullptr;
    std::unique_ptr<MaskRender> m_maskRender = nullptr;
    
    int32_t m_frameCurIdx;
    VideoFitType m_fitType = VideoFitType::FIT_XY;
    int32_t m_viewportWidth = 0;
    int32_t m_viewportHeight = 0;
    int32_t m_viewportX = 0;
    int32_t m_viewportY = 0;
    
    int32_t m_videoWidth = 0;
    int32_t m_videoHeight = 0;
    bool m_isH265 = false;
};
#endif // VAP_EGL_CORE_H
