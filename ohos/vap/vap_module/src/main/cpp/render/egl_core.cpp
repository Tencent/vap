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

#include "egl_core.h"

#include <cstddef>
#include <cstdint>
#include <memory>
#include <misc/fastrpc.h>
#include <cstdio>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <EGL/eglplatform.h>
#include <GLES3/gl3.h>
#include <hilog/log.h>
#include <fstream>
#include <vector>

#include "mask_config.h"
#include "mask_render.h"
#include "common_const.h"

using namespace CommonConst;

const float FIFTY_PERCENT = 0.5;

void EGLCore::FitCenter()
{
    int32_t width = m_animConfig->width, height = m_animConfig->height;

    if (height <= 0 || width <= 0|| m_height <= 0) {
        LOGD("param is zero. height: %{public}d m_height: %{public}d ", height, m_height);
        return;
    }
    // 计算图像和目标区域的宽高比
    double ratioImage = 1.0 * width / height;
    double ratioTarget = 1.0 * m_width / m_height;

    // 选择缩放因子
    double scale;
    if (ratioImage > ratioTarget) {
        scale = 1.0 * m_width / width;
    } else {
        scale = 1.0 * m_height / height;
    }

    // 计算缩放后的图像尺寸
    int32_t newWidth = width * scale;
    int32_t newHeight = height * scale;

    // 计算图像在目标区域中的位置
    int32_t leftMargin = (m_width - newWidth) / TWO;
    int32_t topMargin = (m_height - newHeight) / TWO;

    m_viewportWidth = newWidth;
    m_viewportHeight = newHeight;
    m_viewportX = leftMargin;
    m_viewportY = topMargin;
}

void EGLCore::CenterCrop()
{
    int32_t width = m_animConfig->width,
            height = m_animConfig->height;

    if (height <= 0 || width <= 0|| m_height <= 0) {
        LOGD("param is zero. height: %{public}d m_height: %{public}d ", height, m_height);
        return;
    }
    // 计算图像和目标区域的宽高比
    double ratioImage = 1.0 * width / height;
    double ratioTarget = 1.0 * m_width / m_height;
    
    // 计算缩放后的图像尺寸
    int32_t newWidth;
    int32_t newHeight;

    if (ratioImage < ratioTarget) {
        newWidth = m_width;
        newHeight = 1.0 * m_width / ratioImage;
    } else {
        newHeight = m_height;
        newWidth = 1.0 * ratioImage * m_height;
    }

    // 计算裁剪区域的偏移
    int32_t leftMargin = (newWidth - m_width) / TWO;
    int32_t topMargin = (newHeight - m_height) / TWO;

    m_viewportWidth = newWidth;
    m_viewportHeight = newHeight;
    m_viewportX = -leftMargin;
    m_viewportY = -topMargin;
}

void EGLCore::FitXY()
{
    m_viewportWidth = m_width;
    m_viewportHeight = m_height;
    m_viewportX = 0;
    m_viewportY = 0;
}

void EGLCore::InitFitConfig()
{
    if (m_fitType == VideoFitType::FIT_CENTER) {
        FitCenter();
    } else if (m_fitType == VideoFitType::CENTER_CROP) {
        CenterCrop();
    } else {
        FitXY();
    }
    
    LOGD("InitFitConfig %{public}d viewport %{public}d %{public}d %{public}d %{public}d", m_fitType,
        m_viewportWidth, m_viewportHeight, m_viewportX, m_viewportY);
}

bool EGLCore::EglContextInit(EGLNativeWindowType window, int width, int height, std::string uri,
    std::map<std::string, MixInputData> &iptData)
{
    LOGD("EglContextInit execute");
    if ((nullptr == window) || (ZERO >= width) || (ZERO >= height)) {
        LOGE("EglContextInit: param error");
        return false;
    }

    m_width = width;
    m_height = height;
    
    m_animConfig = std::make_shared<AnimConfig>();
    m_animConfig->defaultVideoMode = m_defaultVideoMode;
    if (m_animConfig->isDefaultConfig || m_animConfig->ParseJson(uri) == false) {
        m_animConfig->DefaultConfig(m_videoWidth, m_videoHeight);
    }
    InitFitConfig();
    
    if (0 < m_width) {
        m_widthPercent = FIFTY_PERCENT * m_height / m_width;
    }
    m_eglWindow = window;

    // Init display.
    m_eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (EGL_NO_DISPLAY == m_eglDisplay) {
        LOGE("eglGetDisplay: unable to get EGL display");
        return false;
    }

    EGLint majorVersion;
    EGLint minorVersion;
    if (!eglInitialize(m_eglDisplay, &majorVersion, &minorVersion)) {
        LOGE("eglInitialize: unable to get initialize EGL display");
        return false;
    }

    // Select configuration.
    m_eglConfig = ChooseConfig();
    if (m_eglConfig == nullptr) {
        LOGE("GLContextInit config ERROR");
        return false;
    }
    auto ret = CreateEnvironment();
    
    m_render = std::make_unique<class YuvRender>(uri);
    m_render->SetAnimConfig(m_animConfig);
    
    if (m_animConfig->srcMapPtr) {
        m_mixRender = std::make_unique<class MixRender>(iptData);
        m_mixRender->SetAnimConfig(m_animConfig);
    }
    return ret;
}

static bool calClick(int32_t x, int32_t y, PointRect frame)
{
    return x >= frame.x && x <= (frame.x + frame.w)
        && y >= frame.y && y <= (frame.y + frame.h);
}

void EGLCore::GetCurrentClickTxt(int32_t eventX, int32_t eventY, std::string &clickRes)
{
    if (!m_mixRender || !m_mixRender->haveSrc) {
        LOGE("no src,  not have mix render");
        return;
    }
    int32_t viewWith = m_width;
    int32_t viewHeight = m_height;
    int32_t videoWith = m_animConfig->width;
    int32_t videoHeight = m_animConfig->height;

    if (viewWith == 0 || viewHeight == 0)
        return;
    
    int32_t x = eventX * videoWith / viewWith;
    int32_t y = eventY * videoHeight / viewHeight;
    
    auto frameIt = m_animConfig->frameAllPtr->frameAll.find(m_frameCurIdx);
    if (frameIt == m_animConfig->frameAllPtr->frameAll.end()) {
        LOGE("not find frame");
        return;
    }
    size_t perFrameSize = frameIt->second.frames.size();
    for (int i = 0; i < perFrameSize; i++) {
        Frame frame = frameIt->second.frames.at(i);
        std::string srcId = frame.srcId;
        auto it = m_animConfig->srcMapPtr->srcSMap.find(srcId);
        if (it != m_animConfig->srcMapPtr->srcSMap.end()) {
            // 找到了指定key的元素
            bool cal = calClick(x, y, frame.frame);
            Src src = it->second;
            if (cal) {
                clickRes = src.txt;
                break;
            }
            LOGD("cal click :%{public}d * %{public}d  cal :%{public}d txt: %{public}s", x, y, cal, src.txt.c_str());
        }
    }
}

EGLConfig EGLCore::ChooseConfig()
{
    std::vector<int> attribList;
    GetAttributes(attribList);
    EGLConfig configs = nullptr;
    int configsNum;

    if (!eglChooseConfig(m_eglDisplay, attribList.data(), &configs, 1, &configsNum)) {
        LOGE("eglChooseConfig: unable to choose configs");
        return nullptr;
    }
    return configs;
}

void EGLCore::GetAttributes(std::vector<int> &array)
{
    array = {
        EGL_RENDERABLE_TYPE,
        EGL_OPENGL_ES2_BIT,
        // 指定渲染api类别
        EGL_RED_SIZE,
        8,
        EGL_GREEN_SIZE,
        8, EGL_BLUE_SIZE,
        8,
        EGL_ALPHA_SIZE,
        8,
        EGL_DEPTH_SIZE,
        0,
        EGL_STENCIL_SIZE,
        0,
        EGL_NONE
    };
}

EGLContext EGLCore::CreateContext(EGLDisplay eglDisplay, EGLConfig eglConfig)
{
    std::vector<EGLint> attrs = {EGL_CONTEXT_CLIENT_VERSION, TWO, EGL_NONE};
    EGLContext eglContext = eglCreateContext(eglDisplay, eglConfig, EGL_NO_CONTEXT, attrs.data());
    return eglContext;
}

bool EGLCore::CreateEnvironment()
{
    // Create surface.
    if (nullptr == m_eglWindow) {
        LOGE("m_eglWindow is null");
        return false;
    }
    
    if (m_eglDisplay == EGL_NO_DISPLAY || m_eglConfig == nullptr) {
        return false;
    }
    
    m_eglSurface = eglCreateWindowSurface(m_eglDisplay, m_eglConfig, m_eglWindow, NULL);
    if (nullptr == m_eglSurface) {
        LOGE("eglCreateWindowSurface: unable to create surface");
        return false;
    }

    // Create context.
    m_eglContext = CreateContext(m_eglDisplay, m_eglConfig);
    if (!eglMakeCurrent(m_eglDisplay, m_eglSurface, m_eglSurface, m_eglContext)) {
        LOGE("eglMakeCurrent failed");
        return false;
    }
    
    return true;
}

void EGLCore::MixRenderFrame(int32_t frameCurIdx)
{
    if (!m_mixRender || !m_mixRender->haveSrc) {
        LOGE("no src, not have mix render");
        return;
    }
    MixConfigSize config = {
        m_animConfig->width,
        m_animConfig->height,
        m_animConfig->videoWidth,
        m_animConfig->videoHeight
    };
    
    auto frameIt = m_animConfig->frameAllPtr->frameAll.find(frameCurIdx);
    if (frameIt == m_animConfig->frameAllPtr->frameAll.end()) {
        LOGE("not find frame");
        return;
    }
    size_t perFrameSize = frameIt->second.frames.size();
    for (int i = 0; i < perFrameSize; i++) {
        Frame frame = frameIt->second.frames.at(i);
        std::string srcId = frame.srcId;
        auto it = m_animConfig->srcMapPtr->srcSMap.find(srcId);
        if (it != m_animConfig->srcMapPtr->srcSMap.end()) {
            // 找到了指定key的元素
            Src src = it->second;
            m_mixRender->SetVideoTextureId(m_render->GetExternalTexture());
            m_mixRender->RenderFrame(config, frame, src);
        } else {
            // 没有找到指定key的元素
            LOGE("not find key :%{public}s", srcId.c_str());
        }
    }
}

void EGLCore::Render(RenderData &renderData)
{
    if (renderData.data.empty()) {
        LOGE("Yuv data is empty, unable to render YUV");
        return;
    }
    if (!SeparateYUV(renderData.data, renderData.stride, renderData.sliceHeight, m_animConfig->videoWidth,
        m_animConfig->videoHeight)) {
        LOGE("unable to readYuvFile");
    }
    glViewport(m_viewportX, m_viewportY, m_viewportWidth, m_viewportHeight);
    m_render->RenderFrame();
    m_frameCurIdx = renderData.frameCurIdx;
    if (m_mixRender && m_mixRender->haveSrc) {
        MixRenderFrame(renderData.frameCurIdx);
    }

    FinishLoad();
}

template <typename T>
void addVecData(std::vector<unsigned char> &data, T &&value)
{
    data.emplace_back(std::forward<T>(value));
}

bool EGLCore::SeparateYUV(const std::vector<uint8_t> &dataVec,
    int alignWidth, int alignHeight, int videoWidth, int videoHeight)
{
    std::vector<unsigned char> data_y;
    std::vector<unsigned char> data_u;
    std::vector<unsigned char> data_v;
    data_y.reserve(videoWidth * videoHeight);
    data_u.reserve(videoWidth * videoHeight / FOUR);
    data_v.reserve(videoWidth * videoHeight / FOUR);
    
    const uint8_t *data = dataVec.data();

    for (int j = 0; j < alignHeight; j++) {
        if (alignHeight != videoHeight && j >= videoHeight)
            break;
        std::vector<unsigned char> oneLine;
        oneLine.assign(data + alignWidth * j, data + alignWidth * j + videoWidth);
        data_y.insert(data_y.end(), oneLine.begin(), oneLine.end());
    }
    for (int j = 0; j < videoHeight / TWO; j++) {
        std::vector<uint8_t> oneLine;
        oneLine.assign(data + alignWidth * alignHeight + alignWidth * j,
            data + alignWidth * alignHeight + alignWidth * j + videoWidth);
        if ((oneLine.size() % TWO) != 0) {
            LOGE("error uv data");
            break;
        }
        for (int k = 0; k < oneLine.size(); k += TWO) {
            addVecData(data_u, std::move(oneLine[k]));
            addVecData(data_v, std::move(oneLine[k + 1]));
        }
    }
    m_render->SetYUVData(m_animConfig->videoWidth,
        m_animConfig->videoHeight, data_y, data_u, data_v);
    return true;
}

bool EGLCore::FinishLoad()
{
    glFlush();
    glFinish();
    // 窗口显示，交换双缓冲区
    bool swap = eglSwapBuffers(m_eglDisplay, m_eglSurface);
    m_flag = true;
    return swap;
}

void EGLCore::Release()
{
    m_render->ClearFrame();
    FinishLoad();
    m_render->ReleaseTexture();
    if ((nullptr == m_eglDisplay) || (nullptr == m_eglSurface) || (!eglDestroySurface(m_eglDisplay, m_eglSurface))) {
        LOGE("Release eglDestroySurface failed");
    }

    if ((nullptr == m_eglDisplay) || (nullptr == m_eglContext) || (!eglDestroyContext(m_eglDisplay, m_eglContext))) {
        LOGE("Release eglDestroyContext failed");
    }

    if ((nullptr == m_eglDisplay) || !eglMakeCurrent(m_eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT)) {
        LOGE("eglMakeCurrent failed");
    }

    if ((nullptr == m_eglDisplay) || (!eglTerminate(m_eglDisplay))) {
        LOGE("Release eglTerminate failed");
    }
}
