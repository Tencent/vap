# JSON_NO_IO

```cpp
#define JSON_NO_IO
```

When defined, headers `<cstdio>`, `<ios>`, `<iosfwd>`, `<istream>`, and `<ostream>` are not included and parse functions
relying on these headers are excluded. This is relevant for environments where these I/O functions are disallowed for
security reasons (e.g., Intel Software Guard Extensions (SGX)).

## Default definition

By default, `#!cpp JSON_NO_IO` is not defined.

```cpp
#undef JSON_NO_IO
```

## Examples

??? example

    The code below forces the library not to use the headers `<cstdio>`, `<ios>`, `<iosfwd>`, `<istream>`, and
    `<ostream>`.

    ```cpp
    #define JSON_NO_IO 1
    #include <nlohmann/json.hpp>

    ...
    ```

## Version history

- Added in version 3.10.0.
