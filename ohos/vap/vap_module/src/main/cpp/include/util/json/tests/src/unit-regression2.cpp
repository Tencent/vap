//     __ _____ _____ _____
//  __|  |   __|     |   | |  JSON for Modern C++ (supporting code)
// |  |  |__   |  |  | | | |  version 3.11.3
// |_____|_____|_____|_|___|  https://github.com/nlohmann/json
//
// SPDX-FileCopyrightText: 2013 - 2024 Niels Lohmann <https://nlohmann.me>
// SPDX-License-Identifier: MIT

// cmake/test.cmake selects the C++ standard versions with which to build a
// unit test based on the presence of JSON_HAS_CPP_<VERSION> macros.
// When using macros that are only defined for particular versions of the standard
// (e.g., JSON_HAS_FILESYSTEM for C++17 and up), please mention the corresponding
// version macro in a comment close by, like this:
// JSON_HAS_CPP_<VERSION> (do not remove; see note at top of file)

#include "doctest_compatibility.h"

// for some reason including this after the json header leads to linker errors with VS 2017...
#include <locale>

#define JSON_TESTS_PRIVATE
#include <nlohmann/json.hpp>
using json = nlohmann::json;
using ordered_json = nlohmann::ordered_json;
#ifdef JSON_TEST_NO_GLOBAL_UDLS
    using namespace nlohmann::literals; // NOLINT(google-build-using-namespace)
#endif

#include <cstdio>
#include <list>
#include <type_traits>
#include <utility>

#ifdef JSON_HAS_CPP_17
    #include <any>
    #include <variant>
#endif

#ifdef JSON_HAS_CPP_20
    #if __has_include(<span>)
        #include <span>
    #endif
#endif

// NLOHMANN_JSON_SERIALIZE_ENUM uses a static std::pair
DOCTEST_CLANG_SUPPRESS_WARNING_PUSH
DOCTEST_CLANG_SUPPRESS_WARNING("-Wexit-time-destructors")

/////////////////////////////////////////////////////////////////////
// for #1021
/////////////////////////////////////////////////////////////////////

using float_json = nlohmann::basic_json<std::map, std::vector, std::string, bool, std::int64_t, std::uint64_t, float>;

/////////////////////////////////////////////////////////////////////
// for #1647
/////////////////////////////////////////////////////////////////////
namespace
{
struct NonDefaultFromJsonStruct
{};

inline bool operator==(NonDefaultFromJsonStruct const& /*unused*/, NonDefaultFromJsonStruct const& /*unused*/)
{
    return true;
}

enum class for_1647
{
    one,
    two
};

// NOLINTNEXTLINE(cppcoreguidelines-avoid-c-arrays,hicpp-avoid-c-arrays,modernize-avoid-c-arrays): this is a false positive
NLOHMANN_JSON_SERIALIZE_ENUM(for_1647,
{
    {for_1647::one, "one"},
    {for_1647::two, "two"},
})
}  // namespace

/////////////////////////////////////////////////////////////////////
// for #1299
/////////////////////////////////////////////////////////////////////

struct Data
{
    Data() = default;
    Data(std::string a_, std::string b_)
        : a(std::move(a_))
        , b(std::move(b_))
    {}
    std::string a{}; // NOLINT(readability-redundant-member-init)
    std::string b{}; // NOLINT(readability-redundant-member-init)
};

void from_json(const json& j, Data& data); // NOLINT(misc-use-internal-linkage)
void from_json(const json& j, Data& data)
{
    j["a"].get_to(data.a);
    j["b"].get_to(data.b);
}

bool operator==(Data const& lhs, Data const& rhs); // NOLINT(misc-use-internal-linkage)
bool operator==(Data const& lhs, Data const& rhs)
{
    return lhs.a == rhs.a && lhs.b == rhs.b;
}

//bool operator!=(Data const& lhs, Data const& rhs)
//{
//    return !(lhs == rhs);
//}

namespace nlohmann
{
template<>
struct adl_serializer<NonDefaultFromJsonStruct>
{
    static NonDefaultFromJsonStruct from_json(json const& /*unused*/) noexcept
    {
        return {};
    }
};
}  // namespace nlohmann

/////////////////////////////////////////////////////////////////////
// for #1805
/////////////////////////////////////////////////////////////////////

struct NotSerializableData
{
    int mydata;
    float myfloat;
};

/////////////////////////////////////////////////////////////////////
// for #2574
/////////////////////////////////////////////////////////////////////

struct NonDefaultConstructible
{
    explicit NonDefaultConstructible(int a)
        : x(a)
    {}
    int x;
};

namespace nlohmann
{
template<>
struct adl_serializer<NonDefaultConstructible>
{
    static NonDefaultConstructible from_json(json const& j)
    {
        return NonDefaultConstructible(j.get<int>());
    }
};
}  // namespace nlohmann

/////////////////////////////////////////////////////////////////////
// for #2824
/////////////////////////////////////////////////////////////////////

class sax_no_exception : public nlohmann::detail::json_sax_dom_parser<json, nlohmann::detail::string_input_adapter_type>
{
  public:
    explicit sax_no_exception(json& j)
        : nlohmann::detail::json_sax_dom_parser<json, nlohmann::detail::string_input_adapter_type>(j, false)
    {}

    static bool parse_error(std::size_t /*position*/, const std::string& /*last_token*/, const json::exception& ex)
    {
        error_string = new std::string(ex.what());  // NOLINT(cppcoreguidelines-owning-memory)
        return false;
    }

    static std::string* error_string;
};

std::string* sax_no_exception::error_string = nullptr;

/////////////////////////////////////////////////////////////////////
// for #2982
/////////////////////////////////////////////////////////////////////

template<class T>
class my_allocator : public std::allocator<T>
{
  public:
    using std::allocator<T>::allocator;

    my_allocator() = default;
    template<class U> my_allocator(const my_allocator<U>& /*unused*/) { }

    template <class U>
    struct rebind
    {
        using other = my_allocator<U>;
    };
};

/////////////////////////////////////////////////////////////////////
// for #3077
/////////////////////////////////////////////////////////////////////

class FooAlloc
{};

class Foo
{
  public:
    explicit Foo(const FooAlloc& /* unused */ = FooAlloc()) {}

    bool value = false;
};

class FooBar
{
  public:
    Foo foo{}; // NOLINT(readability-redundant-member-init)
};

inline void from_json(const nlohmann::json& j, FooBar& fb) // NOLINT(misc-use-internal-linkage)
{
    j.at("value").get_to(fb.foo.value);
}

/////////////////////////////////////////////////////////////////////
// for #3171
/////////////////////////////////////////////////////////////////////

struct for_3171_base // NOLINT(cppcoreguidelines-special-member-functions)
{
    for_3171_base(const std::string& /*unused*/ = {}) {}
    virtual ~for_3171_base();

    for_3171_base(const for_3171_base& other) // NOLINT(hicpp-use-equals-default,modernize-use-equals-default)
        : str(other.str)
    {}

    for_3171_base& operator=(const for_3171_base& other)
    {
        if (this != &other)
        {
            str = other.str;
        }
        return *this;
    }

    for_3171_base(for_3171_base&& other) noexcept
        : str(std::move(other.str))
    {}

    for_3171_base& operator=(for_3171_base&& other) noexcept
    {
        if (this != &other)
        {
            str = std::move(other.str);
        }
        return *this;
    }

    virtual void _from_json(const json& j)
    {
        j.at("str").get_to(str);
    }

    std::string str{}; // NOLINT(readability-redundant-member-init)
};

for_3171_base::~for_3171_base() = default;

struct for_3171_derived : public for_3171_base
{
    for_3171_derived() = default;
    ~for_3171_derived() override;
    explicit for_3171_derived(const std::string& /*unused*/) { }

    for_3171_derived(const for_3171_derived& other) // NOLINT(hicpp-use-equals-default,modernize-use-equals-default)
        : for_3171_base(other)
    {}

    for_3171_derived& operator=(const for_3171_derived& other)
    {
        if (this != &other)
        {
            for_3171_base::operator=(other); // Call base class assignment operator
        }
        return *this;
    }

    for_3171_derived(for_3171_derived&& other) noexcept
        : for_3171_base(std::move(other))
    {}

    for_3171_derived& operator=(for_3171_derived&& other) noexcept
    {
        if (this != &other)
        {
            for_3171_base::operator=(std::move(other)); // Call base class move assignment operator
        }
        return *this;
    }
};

for_3171_derived::~for_3171_derived() = default;

inline void from_json(const json& j, for_3171_base& tb) // NOLINT(misc-use-internal-linkage)
{
    tb._from_json(j);
}

/////////////////////////////////////////////////////////////////////
// for #3312
/////////////////////////////////////////////////////////////////////

#ifdef JSON_HAS_CPP_20
struct for_3312
{
    std::string name;
};

inline void from_json(const json& j, for_3312& obj) // NOLINT(misc-use-internal-linkage)
{
    j.at("name").get_to(obj.name);
}
#endif

/////////////////////////////////////////////////////////////////////
// for #3204
/////////////////////////////////////////////////////////////////////

struct for_3204_foo
{
    for_3204_foo() = default;
    explicit for_3204_foo(std::string /*unused*/) {} // NOLINT(performance-unnecessary-value-param)
};

struct for_3204_bar
{
    enum constructed_from_t
    {
        constructed_from_none = 0,
        constructed_from_foo = 1,
        constructed_from_json = 2
    };

    explicit for_3204_bar(std::function<void(for_3204_foo)> /*unused*/) noexcept // NOLINT(performance-unnecessary-value-param)
        : constructed_from(constructed_from_foo) {}
    explicit for_3204_bar(std::function<void(json)> /*unused*/) noexcept // NOLINT(performance-unnecessary-value-param)
        : constructed_from(constructed_from_json) {}

    constructed_from_t constructed_from = constructed_from_none;
};

/////////////////////////////////////////////////////////////////////
// for #3333
/////////////////////////////////////////////////////////////////////

struct for_3333 final
{
    for_3333(int x_ = 0, int y_ = 0) : x(x_), y(y_) {}

    template <class T>
    for_3333(const T& /*unused*/)
    {
        CHECK(false);
    }

    int x = 0;
    int y = 0;
};

template <>
inline for_3333::for_3333(const json& j)
    : for_3333(j.value("x", 0), j.value("y", 0))
{}

TEST_CASE("regression tests 2")
{
    SECTION("issue #1001 - Fix memory leak during parser callback")
    {
        const auto* geojsonExample = R"(
          { "type": "FeatureCollection",
            "features": [
              { "type": "Feature",
                "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
                "properties": {"prop0": "value0"}
                },
              { "type": "Feature",
                "geometry": {
                  "type": "LineString",
                  "coordinates": [
                    [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
                    ]
                  },
                "properties": {
                  "prop0": "value0",
                  "prop1": 0.0
                  }
                },
              { "type": "Feature",
                 "geometry": {
                   "type": "Polygon",
                   "coordinates": [
                     [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
                       [100.0, 1.0], [100.0, 0.0] ]
                     ]
                 },
                 "properties": {
                   "prop0": "value0",
                   "prop1": {"this": "that"}
                   }
                 }
               ]
             })";

        const json::parser_callback_t cb = [&](int /*level*/, json::parse_event_t event, json & parsed) noexcept
        {
            // skip uninteresting events
            if (event == json::parse_event_t::value && !parsed.is_primitive())
            {
                return false;
            }

            switch (event)
            {
                case json::parse_event_t::key:
                {
                    return true;
                }
                case json::parse_event_t::value:
                {
                    return false;
                }
                case json::parse_event_t::object_start:
                {
                    return true;
                }
                case json::parse_event_t::object_end:
                {
                    return false;
                }
                case json::parse_event_t::array_start:
                {
                    return true;
                }
                case json::parse_event_t::array_end:
                {
                    return false;
                }

                default:
                {
                    return true;
                }
            }
        };

        auto j = json::parse(geojsonExample, cb, true);
        CHECK(j == json());
    }

    SECTION("issue #1021 - to/from_msgpack only works with standard typization")
    {
        float_json j = 1000.0;
        CHECK(float_json::from_cbor(float_json::to_cbor(j)) == j);
        CHECK(float_json::from_msgpack(float_json::to_msgpack(j)) == j);
        CHECK(float_json::from_ubjson(float_json::to_ubjson(j)) == j);

        float_json j2 = {1000.0, 2000.0, 3000.0};
        CHECK(float_json::from_ubjson(float_json::to_ubjson(j2, true, true)) == j2);
    }

    SECTION("issue #1045 - Using STL algorithms with JSON containers with expected results?")
    {
        json diffs = nlohmann::json::array();
        json m1{{"key1", 42}};
        json m2{{"key2", 42}};
        auto p1 = m1.items();
        auto p2 = m2.items();

        using it_type = decltype(p1.begin());

        std::set_difference(
            p1.begin(),
            p1.end(),
            p2.begin(),
            p2.end(),
            std::inserter(diffs, diffs.end()),
            [&](const it_type & e1, const it_type & e2) -> bool
        {
            using comper_pair = std::pair<std::string, decltype(e1.value())>;              // Trying to avoid unneeded copy
            return comper_pair(e1.key(), e1.value()) < comper_pair(e2.key(), e2.value());  // Using pair comper
        });

        CHECK(diffs.size() == 1);  // Note the change here, was 2
    }

#ifdef JSON_HAS_CPP_17
    SECTION("issue #1292 - Serializing std::variant causes stack overflow")
    {
        static_assert(!std::is_constructible<json, std::variant<int, float>>::value, "unexpected value");
    }
#endif

    SECTION("issue #1299 - compile error in from_json converting to container "
            "with std::pair")
    {
        const json j =
        {
            {"1", {{"a", "testa_1"}, {"b", "testb_1"}}},
            {"2", {{"a", "testa_2"}, {"b", "testb_2"}}},
            {"3", {{"a", "testa_3"}, {"b", "testb_3"}}},
        };

        std::map<std::string, Data> expected
        {
            {"1", {"testa_1", "testb_1"}},
            {"2", {"testa_2", "testb_2"}},
            {"3", {"testa_3", "testb_3"}},
        };
        const auto data = j.get<decltype(expected)>();
        CHECK(expected == data);
    }

    SECTION("issue #1445 - buffer overflow in dumping invalid utf-8 strings")
    {
        SECTION("a bunch of -1, ensure_ascii=true")
        {
            const auto length = 300;

            json dump_test;
            dump_test["1"] = std::string(length, -1);

            std::string expected = R"({"1":")";
            for (int i = 0; i < length; ++i)
            {
                expected += "\\ufffd";
            }
            expected += "\"}";

            auto s = dump_test.dump(-1, ' ', true, nlohmann::json::error_handler_t::replace);
            CHECK(s == expected);
        }
        SECTION("a bunch of -2, ensure_ascii=false")
        {
            const auto length = 500;

            json dump_test;
            dump_test["1"] = std::string(length, -2);

            std::string expected = R"({"1":")";
            for (int i = 0; i < length; ++i)
            {
                expected += "\xEF\xBF\xBD";
            }
            expected += "\"}";

            auto s = dump_test.dump(-1, ' ', false, nlohmann::json::error_handler_t::replace);
            CHECK(s == expected);
        }
        SECTION("test case in issue #1445")
        {
            nlohmann::json dump_test;
            const std::array<int, 108> data =
            {
                {109, 108, 103, 125, -122, -53, 115, 18, 3, 0, 102, 19, 1, 15, -110, 13, -3, -1, -81, 32, 2, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -80, 2, 0, 0, 96, -118, 46, -116, 46, 109, -84, -87, 108, 14, 109, -24, -83, 13, -18, -51, -83, -52, -115, 14, 6, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 64, 3, 0, 0, 0, 35, -74, -73, 55, 57, -128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 33, 0, 0, 0, -96, -54, -28, -26}
            };
            std::string s;
            for (const int i : data)
            {
                s += static_cast<char>(i);
            }
            dump_test["1"] = s;
            dump_test.dump(-1, ' ', true, nlohmann::json::error_handler_t::replace);
        }
    }

    SECTION("issue #1447 - Integer Overflow (OSS-Fuzz 12506)")
    {
        const json j = json::parse("[-9223372036854775808]");
        CHECK(j.dump() == "[-9223372036854775808]");
    }

    SECTION("issue #1708 - minimum value of int64_t can be outputted")
    {
        constexpr auto smallest = (std::numeric_limits<int64_t>::min)();
        const json j = smallest;
        CHECK(j.dump() == std::to_string(smallest));
    }

    SECTION("issue #1727 - Contains with non-const lvalue json_pointer picks the wrong overload")
    {
        const json j = {{"root", {{"settings", {{"logging", true}}}}}};

        auto jptr1 = "/root/settings/logging"_json_pointer;
        auto jptr2 = json::json_pointer{"/root/settings/logging"};

        CHECK(j.contains(jptr1));
        CHECK(j.contains(jptr2));
    }

    SECTION("issue #1647 - compile error when deserializing enum if both non-default from_json and non-member operator== exists for other type")
    {
        // does not compile on ICPC when targeting C++20
#if !(defined(__INTEL_COMPILER) && __cplusplus >= 202000)
        {
            const json j;
            NonDefaultFromJsonStruct x(j);
            NonDefaultFromJsonStruct y;
            CHECK(x == y);
        }
#endif

        auto val = nlohmann::json("one").get<for_1647>();
        CHECK(val == for_1647::one);
        const json j = val;
    }

    SECTION("issue #1715 - json::from_cbor does not respect allow_exceptions = false when input is string literal")
    {
        SECTION("string literal")
        {
            const json cbor = json::from_cbor("B", true, false);
            CHECK(cbor.is_discarded());
        }

        SECTION("string array")
        {
            const std::array<char, 2> input = {{'B', 0x00}};
            const json cbor = json::from_cbor(input, true, false);
            CHECK(cbor.is_discarded());
        }

        SECTION("std::string")
        {
            const json cbor = json::from_cbor(std::string("B"), true, false);
            CHECK(cbor.is_discarded());
        }
    }

    SECTION("issue #1805 - A pair<T1, T2> is json constructible only if T1 and T2 are json constructible")
    {
        static_assert(!std::is_constructible<json, std::pair<std::string, NotSerializableData>>::value, "unexpected result");
        static_assert(!std::is_constructible<json, std::pair<NotSerializableData, std::string>>::value, "unexpected result");
        static_assert(std::is_constructible<json, std::pair<int, std::string>>::value, "unexpected result");
    }
    SECTION("issue #1825 - A tuple<Args..> is json constructible only if all T in Args are json constructible")
    {
        static_assert(!std::is_constructible<json, std::tuple<std::string, NotSerializableData>>::value, "unexpected result");
        static_assert(!std::is_constructible<json, std::tuple<NotSerializableData, std::string>>::value, "unexpected result");
        static_assert(std::is_constructible<json, std::tuple<int, std::string>>::value, "unexpected result");
    }

    SECTION("issue #1983 - JSON patch diff for op=add formation is not as per standard (RFC 6902)")
    {
        const auto source = R"({ "foo": [ "1", "2" ] })"_json;
        const auto target = R"({"foo": [ "1", "2", "3" ]})"_json;
        const auto result = json::diff(source, target);
        CHECK(result.dump() == R"([{"op":"add","path":"/foo/-","value":"3"}])");
    }

    SECTION("issue #2067 - cannot serialize binary data to text JSON")
    {
        const std::array<unsigned char, 23> data = {{0x81, 0xA4, 0x64, 0x61, 0x74, 0x61, 0xC4, 0x0F, 0x33, 0x30, 0x30, 0x32, 0x33, 0x34, 0x30, 0x31, 0x30, 0x37, 0x30, 0x35, 0x30, 0x31, 0x30}};
        const json j = json::from_msgpack(data.data(), data.size());
        CHECK_NOTHROW(
            j.dump(4,                             // Indent
                   ' ',                           // Indent char
                   false,                         // Ensure ascii
                   json::error_handler_t::strict  // Error
                  ));
    }

    SECTION("PR #2181 - regression bug with lvalue")
    {
        // see https://github.com/nlohmann/json/pull/2181#issuecomment-653326060
        const json j{{"x", "test"}};
        const std::string defval = "default value";
        auto val = j.value("x", defval); // NOLINT(bugprone-unused-local-non-trivial-variable)
        auto val2 = j.value("y", defval); // NOLINT(bugprone-unused-local-non-trivial-variable)
    }

    SECTION("issue #2293 - eof doesn't cause parsing to stop")
    {
        const std::vector<uint8_t> data =
        {
            0x7B,
            0x6F,
            0x62,
            0x6A,
            0x65,
            0x63,
            0x74,
            0x20,
            0x4F,
            0x42
        };
        const json result = json::from_cbor(data, true, false);
        CHECK(result.is_discarded());
    }

    SECTION("issue #2315 - json.update and vector<pair>does not work with ordered_json")
    {
        nlohmann::ordered_json jsonAnimals = {{"animal", "dog"}};
        const nlohmann::ordered_json jsonCat = {{"animal", "cat"}};
        jsonAnimals.update(jsonCat);
        CHECK(jsonAnimals["animal"] == "cat");

        auto jsonAnimals_parsed = nlohmann::ordered_json::parse(jsonAnimals.dump());
        CHECK(jsonAnimals == jsonAnimals_parsed);

        const std::vector<std::pair<std::string, int64_t>> intData = {std::make_pair("aaaa", 11),
                                                                      std::make_pair("bbb", 222)
                                                                     };
        nlohmann::ordered_json jsonObj;
        for (const auto& data : intData)
        {
            jsonObj[data.first] = data.second;
        }
        CHECK(jsonObj["aaaa"] == 11);
        CHECK(jsonObj["bbb"] == 222);
    }

    SECTION("issue #2330 - ignore_comment=true fails on multiple consecutive lines starting with comments")
    {
        const std::string ss = "//\n//\n{\n}\n";
        const json j = json::parse(ss, nullptr, true, true);
        CHECK(j.dump() == "{}");
    }

#ifdef JSON_HAS_CPP_20
#ifndef _LIBCPP_VERSION // see https://github.com/nlohmann/json/issues/4490
#if __has_include(<span>)
    SECTION("issue #2546 - parsing containers of std::byte")
    {
        const char DATA[] = R"("Hello, world!")"; // NOLINT(cppcoreguidelines-avoid-c-arrays,hicpp-avoid-c-arrays,modernize-avoid-c-arrays)
        const auto s = std::as_bytes(std::span(DATA));
        const json j = json::parse(s);
        CHECK(j.dump() == "\"Hello, world!\"");
    }
#endif
#endif
#endif

    SECTION("issue #2574 - Deserialization to std::array, std::pair, and std::tuple with non-default constructable types fails")
    {
        SECTION("std::array")
        {
            {
                const json j = {7, 4};
                auto arr = j.get<std::array<NonDefaultConstructible, 2>>();
                CHECK(arr[0].x == 7);
                CHECK(arr[1].x == 4);
            }

            {
                const json j = 7;
                CHECK_THROWS_AS((j.get<std::array<NonDefaultConstructible, 1>>()), json::type_error);
            }
        }

        SECTION("std::pair")
        {
            {
                const json j = {3, 8};
                auto p = j.get<std::pair<NonDefaultConstructible, NonDefaultConstructible>>();
                CHECK(p.first.x == 3);
                CHECK(p.second.x == 8);
            }

            {
                const json j = {4, 1};
                auto p = j.get<std::pair<int, NonDefaultConstructible>>();
                CHECK(p.first == 4);
                CHECK(p.second.x == 1);
            }

            {
                const json j = {6, 7};
                auto p = j.get<std::pair<NonDefaultConstructible, int>>();
                CHECK(p.first.x == 6);
                CHECK(p.second == 7);
            }

            {
                const json j = 7;
                CHECK_THROWS_AS((j.get<std::pair<NonDefaultConstructible, int>>()), json::type_error);
            }
        }

        SECTION("std::tuple")
        {
            {
                const json j = {9};
                auto t = j.get<std::tuple<NonDefaultConstructible>>();
                CHECK(std::get<0>(t).x == 9);
            }

            {
                const json j = {9, 8, 7};
                auto t = j.get<std::tuple<NonDefaultConstructible, int, NonDefaultConstructible>>();
                CHECK(std::get<0>(t).x == 9);
                CHECK(std::get<1>(t) == 8);
                CHECK(std::get<2>(t).x == 7);
            }

            {
                const json j = 7;
                CHECK_THROWS_AS((j.get<std::tuple<NonDefaultConstructible>>()), json::type_error);
            }
        }
    }

    SECTION("issue #2865 - ASAN detects memory leaks")
    {
        // the code below is expected to not leak memory
        {
            nlohmann::json o;
            const std::string s = "bar";

            nlohmann::to_json(o["foo"], s);

            nlohmann::json p = o;

            // call to_json with a non-null JSON value
            nlohmann::to_json(p["foo"], s);
        }

        {
            nlohmann::json o;
            const std::string s = "bar";

            nlohmann::to_json(o["foo"], s);

            // call to_json with a non-null JSON value
            nlohmann::to_json(o["foo"], s);
        }
    }

    SECTION("issue #2824 - encoding of json::exception::what()")
    {
        json j;
        sax_no_exception sax(j);

        CHECK(!json::sax_parse("xyz", &sax));
        CHECK(*sax_no_exception::error_string == "[json.exception.parse_error.101] parse error at line 1, column 1: syntax error while parsing value - invalid literal; last read: 'x'");
        delete sax_no_exception::error_string;  // NOLINT(cppcoreguidelines-owning-memory)
    }

    SECTION("issue #2825 - Properly constrain the basic_json conversion operator")
    {
        static_assert(std::is_copy_assignable<nlohmann::ordered_json>::value, "ordered_json must be copy assignable");
    }

    SECTION("issue #2958 - Inserting in unordered json using a pointer retains the leading slash")
    {
        const std::string p = "/root";

        json test1;
        test1[json::json_pointer(p)] = json::object();
        CHECK(test1.dump() == "{\"root\":{}}");

        ordered_json test2;
        test2[ordered_json::json_pointer(p)] = json::object();
        CHECK(test2.dump() == "{\"root\":{}}");

        // json::json_pointer and ordered_json::json_pointer are the same type; behave as above
        ordered_json test3;
        test3[json::json_pointer(p)] = json::object();
        CHECK(std::is_same<json::json_pointer::string_t, ordered_json::json_pointer::string_t>::value);
        CHECK(test3.dump() == "{\"root\":{}}");
    }

    SECTION("issue #2982 - to_{binary format} does not provide a mechanism for specifying a custom allocator for the returned type")
    {
        std::vector<std::uint8_t, my_allocator<std::uint8_t>> my_vector;
        json j = {1, 2, 3, 4};
        json::to_cbor(j, my_vector);
        json k = json::from_cbor(my_vector);
        CHECK(j == k);
    }

#if JSON_HAS_FILESYSTEM || JSON_HAS_EXPERIMENTAL_FILESYSTEM
    // JSON_HAS_CPP_17 (do not remove; see note at top of file)
    SECTION("issue #3070 - Version 3.10.3 breaks backward-compatibility with 3.10.2 ")
    {
        nlohmann::detail::std_fs::path text_path("/tmp/text.txt");
        const json j(text_path);

        const auto j_path = j.get<nlohmann::detail::std_fs::path>();
        CHECK(j_path == text_path);

#if DOCTEST_CLANG || DOCTEST_GCC >= DOCTEST_COMPILER(8, 4, 0)
        // only known to work on Clang and GCC >=8.4
        CHECK_THROWS_WITH_AS(nlohmann::detail::std_fs::path(json(1)), "[json.exception.type_error.302] type must be string, but is number", json::type_error);
#endif
    }
#endif

    SECTION("issue #3077 - explicit constructor with default does not compile")
    {
        json j;
        j[0]["value"] = true;
        std::vector<FooBar> foo;
        j.get_to(foo);
    }

    SECTION("issue #3108 - ordered_json doesn't support range based erase")
    {
        ordered_json j = {1, 2, 2, 4};

        auto last = std::unique(j.begin(), j.end());
        j.erase(last, j.end());

        CHECK(j.dump() == "[1,2,4]");

        j.erase(std::remove_if(j.begin(), j.end(), [](const ordered_json & val)
        {
            return val == 2;
        }), j.end());

        CHECK(j.dump() == "[1,4]");
    }

    SECTION("issue #3343 - json and ordered_json are not interchangeable")
    {
        json::object_t jobj({ { "product", "one" } });
        ordered_json::object_t ojobj({{"product", "one"}});

        auto jit = jobj.begin();
        auto ojit = ojobj.begin();

        CHECK(jit->first == ojit->first);
        CHECK(jit->second.get<std::string>() == ojit->second.get<std::string>());
    }

    SECTION("issue #3171 - if class is_constructible from std::string wrong from_json overload is being selected, compilation failed")
    {
        const json j{{ "str", "value"}};

        // failed with: error: no match for ‘operator=’ (operand types are ‘for_3171_derived’ and ‘const nlohmann::basic_json<>::string_t’
        //                                               {aka ‘const std::__cxx11::basic_string<char>’})
        //                  s = *j.template get_ptr<const typename BasicJsonType::string_t*>();
        auto td = j.get<for_3171_derived>();

        CHECK(td.str == "value");
    }

#ifdef JSON_HAS_CPP_20
    SECTION("issue #3312 - Parse to custom class from unordered_json breaks on G++11.2.0 with C++20")
    {
        // see test for #3171
        const ordered_json j = {{"name", "class"}};
        for_3312 obj{};

        j.get_to(obj);

        CHECK(obj.name == "class");
    }
#endif

#if defined(JSON_HAS_CPP_17) && JSON_USE_IMPLICIT_CONVERSIONS
    SECTION("issue #3428 - Error occurred when converting nlohmann::json to std::any")
    {
        const json j;
        const std::any a1 = j;
        std::any&& a2 = j;

        CHECK(a1.type() == typeid(j));
        CHECK(a2.type() == typeid(j));
    }
#endif

    SECTION("issue #3204 - ambiguous regression")
    {
        for_3204_bar bar_from_foo([](for_3204_foo) noexcept {}); // NOLINT(performance-unnecessary-value-param)
        for_3204_bar bar_from_json([](json) noexcept {}); // NOLINT(performance-unnecessary-value-param)

        CHECK(bar_from_foo.constructed_from == for_3204_bar::constructed_from_foo);
        CHECK(bar_from_json.constructed_from == for_3204_bar::constructed_from_json);
    }

    SECTION("issue #3333 - Ambiguous conversion from nlohmann::basic_json<> to custom class")
    {
        const json j
        {
            {"x", 1},
            {"y", 2}
        };
        for_3333 p = j;

        CHECK(p.x == 1);
        CHECK(p.y == 2);
    }
}

DOCTEST_CLANG_SUPPRESS_WARNING_POP
