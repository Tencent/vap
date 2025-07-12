//     __ _____ _____ _____
//  __|  |   __|     |   | |  JSON for Modern C++ (supporting code)
// |  |  |__   |  |  | | | |  version 3.11.3
// |_____|_____|_____|_|___|  https://github.com/nlohmann/json
//
// SPDX-FileCopyrightText: 2013 - 2024 Niels Lohmann <https://nlohmann.me>
// SPDX-License-Identifier: MIT

#include <string>
#include <vector>
#include "doctest_compatibility.h"

#include <nlohmann/json.hpp>
using nlohmann::json;

namespace persons
{
class person_with_private_data
{
  private:
    std::string name{}; // NOLINT(readability-redundant-member-init)
    int age = 0;
    json metadata = nullptr;

  public:
    bool operator==(const person_with_private_data& rhs) const
    {
        return name == rhs.name && age == rhs.age && metadata == rhs.metadata;
    }

    person_with_private_data() = default;
    person_with_private_data(std::string name_, int age_, json metadata_)
        : name(std::move(name_))
        , age(age_)
        , metadata(std::move(metadata_))
    {}

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(person_with_private_data, age, name, metadata)
};

class derived_person_with_private_data : public person_with_private_data
{
  private:
    std::string hair_color{"blue"};

  public:
    bool operator==(const derived_person_with_private_data& rhs) const
    {
        return person_with_private_data::operator==(rhs) && hair_color == rhs.hair_color;
    }

    derived_person_with_private_data() = default;
    derived_person_with_private_data(std::string name_, int age_, json metadata_, std::string hair_color_)
        : person_with_private_data(std::move(name_), age_, std::move(metadata_))
        , hair_color(std::move(hair_color_))
    {}

    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(derived_person_with_private_data, person_with_private_data, hair_color)
};

class person_with_private_data_2
{
  private:
    std::string name{}; // NOLINT(readability-redundant-member-init)
    int age = 0;
    json metadata = nullptr;

  public:
    bool operator==(const person_with_private_data_2& rhs) const
    {
        return name == rhs.name && age == rhs.age && metadata == rhs.metadata;
    }

    person_with_private_data_2() = default;
    person_with_private_data_2(std::string name_, int age_, json metadata_)
        : name(std::move(name_))
        , age(age_)
        , metadata(std::move(metadata_))
    {}

    std::string getName() const
    {
        return name;
    }
    int getAge() const
    {
        return age;
    }
    json getMetadata() const
    {
        return metadata;
    }

    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(person_with_private_data_2, age, name, metadata)
};

class derived_person_with_private_data_2 : public person_with_private_data_2
{
  private:
    std::string hair_color{"blue"};

  public:
    bool operator==(const derived_person_with_private_data_2& rhs) const
    {
        return person_with_private_data_2::operator==(rhs) && hair_color == rhs.hair_color;
    }

    derived_person_with_private_data_2() = default;
    derived_person_with_private_data_2(std::string name_, int age_, json metadata_, std::string hair_color_)
        : person_with_private_data_2(std::move(name_), age_, std::move(metadata_))
        , hair_color(std::move(hair_color_))
    {}

    std::string getHairColor() const
    {
        return hair_color;
    }

    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE_WITH_DEFAULT(derived_person_with_private_data_2, person_with_private_data_2, hair_color)
};

class person_without_private_data_1
{
  public:
    std::string name{}; // NOLINT(readability-redundant-member-init)
    int age = 0;
    json metadata = nullptr;

    bool operator==(const person_without_private_data_1& rhs) const
    {
        return name == rhs.name && age == rhs.age && metadata == rhs.metadata;
    }

    person_without_private_data_1() = default;
    person_without_private_data_1(std::string name_, int age_, json metadata_)
        : name(std::move(name_))
        , age(age_)
        , metadata(std::move(metadata_))
    {}

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(person_without_private_data_1, age, name, metadata)
};

class derived_person_without_private_data_1 : public person_without_private_data_1
{
  public:
    std::string hair_color{"blue"};

  public:
    bool operator==(const derived_person_without_private_data_1& rhs) const
    {
        return person_without_private_data_1::operator==(rhs) && hair_color == rhs.hair_color;
    }

    derived_person_without_private_data_1() = default;
    derived_person_without_private_data_1(std::string name_, int age_, json metadata_, std::string hair_color_)
        : person_without_private_data_1(std::move(name_), age_, std::move(metadata_))
        , hair_color(std::move(hair_color_))
    {}

    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(derived_person_without_private_data_1, person_without_private_data_1, hair_color)
};

class person_without_private_data_2
{
  public:
    std::string name{}; // NOLINT(readability-redundant-member-init)
    int age = 0;
    json metadata = nullptr;

    bool operator==(const person_without_private_data_2& rhs) const
    {
        return name == rhs.name && age == rhs.age && metadata == rhs.metadata;
    }

    person_without_private_data_2() = default;
    person_without_private_data_2(std::string name_, int age_, json metadata_)
        : name(std::move(name_))
        , age(age_)
        , metadata(std::move(metadata_))
    {}
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(person_without_private_data_2, age, name, metadata)

class derived_person_without_private_data_2 : public person_without_private_data_2
{
  public:
    std::string hair_color{"blue"};

  public:
    bool operator==(const derived_person_without_private_data_2& rhs) const
    {
        return person_without_private_data_2::operator==(rhs) && hair_color == rhs.hair_color;
    }

    derived_person_without_private_data_2() = default;
    derived_person_without_private_data_2(std::string name_, int age_, json metadata_, std::string hair_color_)
        : person_without_private_data_2(std::move(name_), age_, std::move(metadata_))
        , hair_color(std::move(hair_color_))
    {}
};

NLOHMANN_DEFINE_DERIVED_TYPE_NON_INTRUSIVE(derived_person_without_private_data_2, person_without_private_data_2, hair_color)

class person_without_private_data_3
{
  public:
    std::string name{}; // NOLINT(readability-redundant-member-init)
    int age = 0;
    json metadata = nullptr;

    bool operator==(const person_without_private_data_3& rhs) const
    {
        return name == rhs.name && age == rhs.age && metadata == rhs.metadata;
    }

    person_without_private_data_3() = default;
    person_without_private_data_3(std::string name_, int age_, json metadata_)
        : name(std::move(name_))
        , age(age_)
        , metadata(std::move(metadata_))
    {}

    std::string getName() const
    {
        return name;
    }
    int getAge() const
    {
        return age;
    }
    json getMetadata() const
    {
        return metadata;
    }
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE_WITH_DEFAULT(person_without_private_data_3, age, name, metadata)

class derived_person_without_private_data_3 : public person_without_private_data_3
{
  public:
    std::string hair_color{"blue"};

  public:
    bool operator==(const derived_person_without_private_data_3& rhs) const
    {
        return person_without_private_data_3::operator==(rhs) && hair_color == rhs.hair_color;
    }

    derived_person_without_private_data_3() = default;
    derived_person_without_private_data_3(std::string name_, int age_, json metadata_, std::string hair_color_)
        : person_without_private_data_3(std::move(name_), age_, std::move(metadata_))
        , hair_color(std::move(hair_color_))
    {}

    std::string getHairColor() const
    {
        return hair_color;
    }
};

NLOHMANN_DEFINE_DERIVED_TYPE_NON_INTRUSIVE_WITH_DEFAULT(derived_person_without_private_data_3, person_without_private_data_3, hair_color)

class person_with_private_alphabet
{
  public:
    bool operator==(const person_with_private_alphabet& other) const
    {
        return  a == other.a &&
                b == other.b &&
                c == other.c &&
                d == other.d &&
                e == other.e &&
                f == other.f &&
                g == other.g &&
                h == other.h &&
                i == other.i &&
                j == other.j &&
                k == other.k &&
                l == other.l &&
                m == other.m &&
                n == other.n &&
                o == other.o &&
                p == other.p &&
                q == other.q &&
                r == other.r &&
                s == other.s &&
                t == other.t &&
                u == other.u &&
                v == other.v &&
                w == other.w &&
                x == other.x &&
                y == other.y &&
                z == other.z;
    }

  private:
    int a = 0;
    int b = 0;
    int c = 0;
    int d = 0;
    int e = 0;
    int f = 0;
    int g = 0;
    int h = 0;
    int i = 0;
    int j = 0;
    int k = 0;
    int l = 0;
    int m = 0;
    int n = 0;
    int o = 0;
    int p = 0;
    int q = 0;
    int r = 0;
    int s = 0;
    int t = 0;
    int u = 0;
    int v = 0;
    int w = 0;
    int x = 0;
    int y = 0;
    int z = 0;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(person_with_private_alphabet, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
};

class derived_person_with_private_alphabet : public person_with_private_alphabet
{
  public:
    bool operator==(const derived_person_with_private_alphabet& other) const
    {
        return person_with_private_alphabet::operator==(other) && schwa == other.schwa;
    }

  private:
    int schwa = 0;
    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(derived_person_with_private_alphabet, person_with_private_alphabet, schwa)
};

class person_with_public_alphabet
{
  public:
    bool operator==(const person_with_public_alphabet& other) const
    {
        return  a == other.a &&
                b == other.b &&
                c == other.c &&
                d == other.d &&
                e == other.e &&
                f == other.f &&
                g == other.g &&
                h == other.h &&
                i == other.i &&
                j == other.j &&
                k == other.k &&
                l == other.l &&
                m == other.m &&
                n == other.n &&
                o == other.o &&
                p == other.p &&
                q == other.q &&
                r == other.r &&
                s == other.s &&
                t == other.t &&
                u == other.u &&
                v == other.v &&
                w == other.w &&
                x == other.x &&
                y == other.y &&
                z == other.z;
    }

    int a = 0;
    int b = 0;
    int c = 0;
    int d = 0;
    int e = 0;
    int f = 0;
    int g = 0;
    int h = 0;
    int i = 0;
    int j = 0;
    int k = 0;
    int l = 0;
    int m = 0;
    int n = 0;
    int o = 0;
    int p = 0;
    int q = 0;
    int r = 0;
    int s = 0;
    int t = 0;
    int u = 0;
    int v = 0;
    int w = 0;
    int x = 0;
    int y = 0;
    int z = 0;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(person_with_public_alphabet, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)

class person_without_default_constructor_1
{
  public:
    std::string name;
    int age;

    bool operator==(const person_without_default_constructor_1& other) const
    {
        return name == other.name && age == other.age;
    }

    person_without_default_constructor_1(std::string name_, int age_)
        : name{std::move(name_)}
        , age{age_}
    {}

    NLOHMANN_DEFINE_TYPE_INTRUSIVE_ONLY_SERIALIZE(person_without_default_constructor_1, name, age)
};

class person_without_default_constructor_2
{
  public:
    std::string name;
    int age;

    bool operator==(const person_without_default_constructor_2& other) const
    {
        return name == other.name && age == other.age;
    }

    person_without_default_constructor_2(std::string name_, int age_)
        : name{std::move(name_)}
        , age{age_}
    {}
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE_ONLY_SERIALIZE(person_without_default_constructor_2, name, age)

class derived_person_only_serialize_public : public person_without_default_constructor_1
{
  public:
    std::string hair_color;

    derived_person_only_serialize_public(std::string name_, int age_, std::string hair_color_)
        : person_without_default_constructor_1(std::move(name_), age_)
        , hair_color(std::move(hair_color_))
    {}
};

NLOHMANN_DEFINE_DERIVED_TYPE_NON_INTRUSIVE_ONLY_SERIALIZE(derived_person_only_serialize_public, person_without_default_constructor_1, hair_color)

class derived_person_only_serialize_private : person_without_default_constructor_1
{
  private:
    std::string hair_color;
  public:
    derived_person_only_serialize_private(std::string name_, int age_, std::string hair_color_)
        : person_without_default_constructor_1(std::move(name_), age_)
        , hair_color(std::move(hair_color_))
    {}

    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE_ONLY_SERIALIZE(derived_person_only_serialize_private, person_without_default_constructor_1, hair_color)
};

} // namespace persons

TEST_CASE_TEMPLATE("Serialization/deserialization via NLOHMANN_DEFINE_TYPE_INTRUSIVE and NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE", T, // NOLINT(readability-math-missing-parentheses)
                   persons::person_with_private_data,
                   persons::person_without_private_data_1,
                   persons::person_without_private_data_2)
{
    SECTION("person")
    {
        // serialization
        T p1("Erik", 1, {{"haircuts", 2}});
        CHECK(json(p1).dump() == "{\"age\":1,\"metadata\":{\"haircuts\":2},\"name\":\"Erik\"}");

        // deserialization
        auto p2 = json(p1).get<T>();
        CHECK(p2 == p1);

        // roundtrip
        CHECK(T(json(p1)) == p1);
        CHECK(json(T(json(p1))) == json(p1));

        // check exception in case of missing field
        json j = json(p1);
        j.erase("age");
        CHECK_THROWS_WITH_AS(j.get<T>(), "[json.exception.out_of_range.403] key 'age' not found", json::out_of_range);
    }
}

TEST_CASE_TEMPLATE("Serialization/deserialization via NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE and NLOHMANN_DEFINE_DERIVED_TYPE_NON_INTRUSIVE", T, // NOLINT(readability-math-missing-parentheses)
                   persons::derived_person_with_private_data,
                   persons::derived_person_without_private_data_1,
                   persons::derived_person_without_private_data_2)
{
    SECTION("person")
    {
        // serialization
        T p1("Erik", 1, {{"haircuts", 2}}, "red");
        CHECK(json(p1).dump() == "{\"age\":1,\"hair_color\":\"red\",\"metadata\":{\"haircuts\":2},\"name\":\"Erik\"}");

        // deserialization
        auto p2 = json(p1).get<T>();
        CHECK(p2 == p1);

        // roundtrip
        CHECK(T(json(p1)) == p1);
        CHECK(json(T(json(p1))) == json(p1));

        // check exception in case of missing field
        json j = json(p1);
        j.erase("age");
        CHECK_THROWS_WITH_AS(j.get<T>(), "[json.exception.out_of_range.403] key 'age' not found", json::out_of_range);
    }
}

TEST_CASE_TEMPLATE("Serialization/deserialization via NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT and NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE_WITH_DEFAULT", T, // NOLINT(readability-math-missing-parentheses)
                   persons::person_with_private_data_2,
                   persons::person_without_private_data_3)
{
    SECTION("person with default values")
    {
        // serialization of default constructed object
        T p0;
        CHECK(json(p0).dump() == "{\"age\":0,\"metadata\":null,\"name\":\"\"}");

        // serialization
        T p1("Erik", 1, {{"haircuts", 2}});
        CHECK(json(p1).dump() == "{\"age\":1,\"metadata\":{\"haircuts\":2},\"name\":\"Erik\"}");

        // deserialization
        auto p2 = json(p1).get<T>();
        CHECK(p2 == p1);

        // roundtrip
        CHECK(T(json(p1)) == p1);
        CHECK(json(T(json(p1))) == json(p1));

        // check default value in case of missing field
        json j = json(p1);
        j.erase("name");
        j.erase("age");
        j.erase("metadata");
        T p3 = j.get<T>();
        CHECK(p3.getName() == "");
        CHECK(p3.getAge() == 0);
        CHECK(p3.getMetadata() == nullptr);
    }
}

TEST_CASE_TEMPLATE("Serialization/deserialization via NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE_WITH_DEFAULT and NLOHMANN_DEFINE_DERIVED_TYPE_NON_INTRUSIVE_WITH_DEFAULT", T, // NOLINT(readability-math-missing-parentheses)
                   persons::derived_person_with_private_data_2,
                   persons::derived_person_without_private_data_3)
{
    SECTION("derived person with default values")
    {
        // serialization of default constructed object
        T p0;
        CHECK(json(p0).dump() == "{\"age\":0,\"hair_color\":\"blue\",\"metadata\":null,\"name\":\"\"}");

        // serialization
        T p1("Erik", 1, {{"haircuts", 2}}, "red");
        CHECK(json(p1).dump() == "{\"age\":1,\"hair_color\":\"red\",\"metadata\":{\"haircuts\":2},\"name\":\"Erik\"}");

        // deserialization
        auto p2 = json(p1).get<T>();
        CHECK(p2 == p1);

        // roundtrip
        CHECK(T(json(p1)) == p1);
        CHECK(json(T(json(p1))) == json(p1));

        // check default value in case of missing field
        json j = json(p1);
        j.erase("name");
        j.erase("age");
        j.erase("metadata");
        j.erase("hair_color");
        T p3 = j.get<T>();
        CHECK(p3.getName() == "");
        CHECK(p3.getAge() == 0);
        CHECK(p3.getMetadata() == nullptr);
        CHECK(p3.getHairColor() == "blue");
    }
}

TEST_CASE_TEMPLATE("Serialization/deserialization of classes with 26 public/private member variables via NLOHMANN_DEFINE_TYPE_INTRUSIVE and NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE", T, // NOLINT(readability-math-missing-parentheses)
                   persons::person_with_private_alphabet,
                   persons::person_with_public_alphabet)
{
    SECTION("alphabet")
    {
        {
            T obj1;
            nlohmann::json const j = obj1; //via json object
            T obj2;
            j.get_to(obj2);
            bool ok = (obj1 == obj2);
            CHECK(ok);
        }

        {
            T obj1;
            nlohmann::json const j1 = obj1; //via json string
            std::string const s = j1.dump();
            nlohmann::json const j2 = nlohmann::json::parse(s);
            T obj2;
            j2.get_to(obj2);
            bool ok = (obj1 == obj2);
            CHECK(ok);
        }

        {
            T obj1;
            nlohmann::json const j1 = obj1; //via msgpack
            std::vector<uint8_t> const buf = nlohmann::json::to_msgpack(j1);
            nlohmann::json const j2 = nlohmann::json::from_msgpack(buf);
            T obj2;
            j2.get_to(obj2);
            bool ok = (obj1 == obj2);
            CHECK(ok);
        }

        {
            T obj1;
            nlohmann::json const j1 = obj1; //via bson
            std::vector<uint8_t> const buf = nlohmann::json::to_bson(j1);
            nlohmann::json const j2 = nlohmann::json::from_bson(buf);
            T obj2;
            j2.get_to(obj2);
            bool ok = (obj1 == obj2);
            CHECK(ok);
        }

        {
            T obj1;
            nlohmann::json const j1 = obj1; //via cbor
            std::vector<uint8_t> const buf = nlohmann::json::to_cbor(j1);
            nlohmann::json const j2 = nlohmann::json::from_cbor(buf);
            T obj2;
            j2.get_to(obj2);
            bool ok = (obj1 == obj2);
            CHECK(ok);
        }

        {
            T obj1;
            nlohmann::json const j1 = obj1; //via ubjson
            std::vector<uint8_t> const buf = nlohmann::json::to_ubjson(j1);
            nlohmann::json const j2 = nlohmann::json::from_ubjson(buf);
            T obj2;
            j2.get_to(obj2);
            bool ok = (obj1 == obj2);
            CHECK(ok);
        }
    }
}

TEST_CASE_TEMPLATE("Serialization of non-default-constructible classes via NLOHMANN_DEFINE_TYPE_INTRUSIVE_ONLY_SERIALIZE and NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE_ONLY_SERIALIZE", T, // NOLINT(readability-math-missing-parentheses)
                   persons::person_without_default_constructor_1,
                   persons::person_without_default_constructor_2)
{
    SECTION("person")
    {
        {
            // serialization of a single object
            T person{"Erik", 1};
            CHECK(json(person).dump() == "{\"age\":1,\"name\":\"Erik\"}");

            // serialization of a container with objects
            std::vector<T> const two_persons
            {
                {"Erik", 1},
                {"Kyle", 2}
            };
            CHECK(json(two_persons).dump() == "[{\"age\":1,\"name\":\"Erik\"},{\"age\":2,\"name\":\"Kyle\"}]");
        }
    }
}

TEST_CASE_TEMPLATE("Serialization of non-default-constructible classes via NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE_ONLY_SERIALIZE and NLOHMANN_DEFINE_DERIVED_TYPE_NON_INTRUSIVE_ONLY_SERIALIZE", T, // NOLINT(readability-math-missing-parentheses)
                   persons::derived_person_only_serialize_public,
                   persons::derived_person_only_serialize_private)
{
    SECTION("derived person only serialize")
    {
        {
            // serialization of a single object
            T person{"Erik", 1, "brown"};
            CHECK(json(person).dump() == "{\"age\":1,\"hair_color\":\"brown\",\"name\":\"Erik\"}");

            // serialization of a container with objects
            std::vector<T> const two_persons
            {
                {"Erik", 1, "brown"},
                {"Kyle", 2, "black"}
            };
            CHECK(json(two_persons).dump() == "[{\"age\":1,\"hair_color\":\"brown\",\"name\":\"Erik\"},{\"age\":2,\"hair_color\":\"black\",\"name\":\"Kyle\"}]");
        }
    }
}
