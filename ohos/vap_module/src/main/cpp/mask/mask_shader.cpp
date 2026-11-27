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

#include "mask_shader.h"

MaskShader::MaskShader(bool edgeBlurBoolean)
{
    if (edgeBlurBoolean) {
        m_program = ShaderUtil::CreateProgram(MASK_VERTEX, FRAGMENT_BLUR_EDGE);
    } else {
        m_program = ShaderUtil::CreateProgram(MASK_VERTEX, FRAGMENT_NO_BLUR_EDGE);
    }
    m_uTextureMaskUnitLocation = glGetUniformLocation(m_program, U_TEXTURE_ALPHA_MASK_UNIT);
    m_aPositionLocation = glGetAttribLocation(m_program, A_POSITION);
    m_aTextureMaskCoordinatesLocation = glGetAttribLocation(m_program, A_TEXTURE_MASK_COORDINATES);
}

void MaskShader::UseProgram()
{
    glUseProgram(m_program);
}
