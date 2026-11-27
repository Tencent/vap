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

#include "texture_load_util.h"

#include <GLES2/gl2ext.h>
#include "log.h"

void TextureLoadUtil::loadTexture(BitMap bitmap, GLuint *textureId)
{
    if (!textureId) {
        LOGE("textureId nullptr");
        return;
    }
    GLuint textures[1];
    glGenTextures(1, textures);
    if (textures[0] == 0) {
        LOGE("glGenTextures error");
        return;
    }

    if (bitmap.pixelsData.empty()) {
        glDeleteTextures(1, textures);
        LOGE("pixelsData empty");
        return;
    }

    glBindTexture(GL_TEXTURE_2D, textures[0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bitmap.imgWidth, bitmap.imgHeight, 0, GL_RGBA,
        GL_UNSIGNED_BYTE, bitmap.pixelsData.data());
    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        // 处理错误
        LOGE("glGetError error: %{public}x", error);
    }

    *textureId = textures[0];
}
