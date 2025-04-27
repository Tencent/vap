//     __ _____ _____ _____
//  __|  |   __|     |   | |  JSON for Modern C++ (supporting code)
// |  |  |__   |  |  | | | |  version 3.11.3
// |_____|_____|_____|_|___|  https://github.com/nlohmann/json
//
// SPDX-FileCopyrightText: 2013 - 2024 Niels Lohmann <https://nlohmann.me>
// SPDX-License-Identifier: MIT

#include "doctest_compatibility.h"

#include <nlohmann/json.hpp>
using nlohmann::json;

TEST_CASE("concepts")
{
    SECTION("container requirements for json")
    {
        // X: container class: json
        // T: type of objects: json
        // a, b: values of type X: json

        // TABLE 96 - Container Requirements
        // X::value_type must return T
        CHECK((std::is_same<json::value_type, json>::value));

        // X::reference must return lvalue of T
        CHECK((std::is_same<json::reference, json&>::value));

        // X::const_reference must return const lvalue of T
        CHECK((std::is_same<json::const_reference, const json&>::value));

        // X::iterator must return iterator whose value_type is T
        CHECK((std::is_same<json::iterator::value_type, json>::value));
        // X::iterator must meet the forward iterator requirements
        CHECK((std::is_base_of<std::forward_iterator_tag, typename std::iterator_traits<json::iterator>::iterator_category>::value));
        // X::iterator must be convertible to X::const_iterator
        CHECK((std::is_convertible<json::iterator, json::const_iterator>::value));

        // X::const_iterator must return iterator whose value_type is T
        CHECK((std::is_same<json::const_iterator::value_type, json>::value));
        // X::const_iterator must meet the forward iterator requirements
        CHECK((std::is_base_of<std::forward_iterator_tag, typename std::iterator_traits<json::const_iterator>::iterator_category>::value));

        // X::difference_type must return a signed integer
        CHECK((std::is_signed<json::difference_type>::value));
        // X::difference_type must be identical to X::iterator::difference_type
        CHECK((std::is_same<json::difference_type, json::iterator::difference_type>::value));
        // X::difference_type must be identical to X::const_iterator::difference_type
        CHECK((std::is_same<json::difference_type, json::const_iterator::difference_type>::value));

        // X::size_type must return an unsigned integer
        CHECK((std::is_unsigned<json::size_type>::value));
        // X::size_type can represent any non-negative value of X::difference_type
        CHECK(static_cast<json::size_type>((std::numeric_limits<json::difference_type>::max)()) <=
              (std::numeric_limits<json::size_type>::max)());

        // the expression "X u" has the post-condition "u.empty()"
        {
            const json u;
            CHECK(u.empty());
        }

        // the expression "X()" has the post-condition "X().empty()"
        CHECK(json().empty());
    }

    SECTION("class json")
    {
        SECTION("DefaultConstructible")
        {
            CHECK(std::is_nothrow_default_constructible<json>::value);
        }

        SECTION("MoveConstructible")
        {
            CHECK(std::is_move_constructible<json>::value);
            CHECK(std::is_nothrow_move_constructible<json>::value);
        }

        SECTION("CopyConstructible")
        {
            CHECK(std::is_copy_constructible<json>::value);
        }

        SECTION("MoveAssignable")
        {
            CHECK(std::is_nothrow_move_assignable<json>::value);
        }

        SECTION("CopyAssignable")
        {
            CHECK(std::is_copy_assignable<json>::value);
        }

        SECTION("Destructible")
        {
            CHECK(std::is_nothrow_destructible<json>::value);
        }

        SECTION("StandardLayoutType")
        {
            CHECK(std::is_standard_layout<json>::value);
        }
    }

    SECTION("class iterator")
    {
        SECTION("CopyConstructible")
        {
            CHECK(std::is_nothrow_copy_constructible<json::iterator>::value);
            CHECK(std::is_nothrow_copy_constructible<json::const_iterator>::value);
        }

        SECTION("CopyAssignable")
        {
            // STL iterators used by json::iterator don't pass this test in Debug mode
#if !defined(_MSC_VER) || (_ITERATOR_DEBUG_LEVEL == 0)
            CHECK(std::is_nothrow_copy_assignable<json::iterator>::value);
            CHECK(std::is_nothrow_copy_assignable<json::const_iterator>::value);
#endif
        }

        SECTION("Destructible")
        {
            CHECK(std::is_nothrow_destructible<json::iterator>::value);
            CHECK(std::is_nothrow_destructible<json::const_iterator>::value);
        }

        SECTION("Swappable")
        {
            {
                json j {1, 2, 3};
                json::iterator it1 = j.begin();
                json::iterator it2 = j.end();
                swap(it1, it2);
                CHECK(it1 == j.end());
                CHECK(it2 == j.begin());
            }
            {
                json j {1, 2, 3};
                json::const_iterator it1 = j.cbegin();
                json::const_iterator it2 = j.cend();
                swap(it1, it2);
                CHECK(it1 == j.end());
                CHECK(it2 == j.begin());
            }
        }
    }
}
