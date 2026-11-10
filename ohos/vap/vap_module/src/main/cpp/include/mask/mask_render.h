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

#ifndef VAP_MASK_RENDER_H
#define VAP_MASK_RENDER_H

#include "mask_config.h"
#include "mask_shader.h"
#include "vertex_util.h"

class MaskRender {
public:
    MaskRender(bool edgeBlur);
    void RenderFrame(MaskConfig maskConfig);
    
public:
    std::unique_ptr<MaskShader> m_maskShader;
    VertexUtil m_vertexArray;
    
private:
    VertexUtil m_maskArray;
};

#endif // VAP_MASK_RENDER_H
