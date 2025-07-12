//     __ _____ _____ _____
//  __|  |   __|     |   | |  JSON for Modern C++ (supporting code)
// |  |  |__   |  |  | | | |  version 3.11.3
// |_____|_____|_____|_|___|  https://github.com/nlohmann/json
//
// SPDX-FileCopyrightText: 2013 - 2024 Niels Lohmann <https://nlohmann.me>
// SPDX-License-Identifier: MIT

#include "doctest_compatibility.h"
#undef WIN32_LEAN_AND_MEAN
#undef NOMINMAX

#ifdef _WIN32
    #include <windows.h>
#endif

#include <nlohmann/json.hpp>
using nlohmann::json;

TEST_CASE("include windows.h")
{
    CHECK(true);
}
