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

#ifndef VAP_MIX_RENDER_H
#define VAP_MIX_RENDER_H

#include <cstdint>
#include <native_drawing/drawing_text_typography.h>
#include <vector>

#include "anim_config.h"
#include "frame.h"
#include "mix_shader.h"
#include "resource_request.h"
#include "src.h"
#include "texture_load_util.h"
#include "vertex_util.h"

struct MixConfigSize {
    int32_t width;
    int32_t height;
    int32_t videoWidth;
    int32_t videoHeight;
};

#define SET_COLOR 0x01
#define SET_TEXT_ALIGN 0x02
#define SET_FONT_WEIGHT 0x04

struct MixInputData {
    std::string txt = "DEFAULT_TEXT";
    std::string imgUri = "DEFAULT_URI";
    
    uint8_t isSet = 0;
    ColorARGB color;
    OH_Drawing_TextAlign textAlign;
    OH_Drawing_FontWeight fontWeight;
};

class MixRender {
public:
    MixRender(std::map<std::string, MixInputData> iptData);
    ~MixRender();
    
    void Init();
    void GenSrcTexture(Src src, BitMap &bitmap, const MixInputData mixData);
    void RenderFrame(MixConfigSize config, Frame frame, Src src);
    void SetVideoTextureId(GLuint id);
    void SetAnimConfig(std::shared_ptr<AnimConfig> animConfig)
    {
        m_animConfig = animConfig;
        Init();
    }
    
    GLuint videoTextureId;
    std::unique_ptr<MixShader> m_shader;
    VertexUtil m_vertexArray;
    VertexUtil m_srcArray;
    VertexUtil m_maskArray;
    std::shared_ptr<AnimConfig> m_animConfig;
    bool haveSrc = false;
    
private:
    void GenSrcCoordsArray(VertexUtil &array, int32_t fw, int32_t fh, int32_t sw, int32_t sh, FitType fitType);
    
    std::vector<GLuint> m_textureIds;
    std::map<std::string, MixInputData> m_mixData;
};

#endif // VAP_MIX_RENDER_H
