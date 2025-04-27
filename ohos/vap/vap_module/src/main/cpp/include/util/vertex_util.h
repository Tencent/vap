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

#ifndef VAP_VERTEX_UTIL_H
#define VAP_VERTEX_UTIL_H

#include <GLES3/gl3.h>
#include <EGL/egl.h>
#include <memory>
#include <stdint.h>

#define TRIANGLES_POINT 3
#define TETRAHEDRON_POINT 12
#define FLOATARRAY_SIZE 8

class PointRect {
public:
    int32_t x;
    int32_t y;
    int32_t w;
    int32_t h;

    PointRect() {}
    PointRect(int x, int y, int w, int h) : x(x), y(y), w(w), h(h) {}
};

class RefVec2 {
public:
    int32_t w;
    int32_t h;
    
    RefVec2() {}
    RefVec2(int32_t w, int32_t h) : w(w), h(h) {}
};

class VertexUtil {
public:
    void Create(int32_t width, int32_t height, const PointRect &rect, float *array);
    void EnableVertexAttrib(GLuint index);
    void SetArray(float *array);
    std::unique_ptr<float[]> array = std::make_unique<float[]>(FLOATARRAY_SIZE);

private:
    float SwitchX(float x);
    float SwitchY(float y);
    
private:
    float *floatBuffer;
};

#endif // VAP_VERTEX_UTIL_H
