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

#ifndef VAP_TEX_COORDS_UTIL_H
#define VAP_TEX_COORDS_UTIL_H

#include <stdint.h>
#include <sys/stat.h>
#include "vertex_util.h"

class TexCoordsUtil {
public:
    static void Create(int32_t width, int32_t height, PointRect rect, float *array);
    static void Rotate90(float *array);
};

#endif // VAP_TEX_COORDS_UTIL_H
