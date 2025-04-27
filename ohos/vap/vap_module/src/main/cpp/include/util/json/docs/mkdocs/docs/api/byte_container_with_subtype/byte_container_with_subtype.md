# <small>nlohmann::byte_container_with_subtype::</small>byte_container_with_subtype

```cpp
// (1)
byte_container_with_subtype();

// (2)
byte_container_with_subtype(const container_type& container);
byte_container_with_subtype(container_type&& container);

// (3)
byte_container_with_subtype(const container_type& container, subtype_type subtype);
byte_container_with_subtype(container_type&& container, subtype_type subtype);
```

1. Create empty binary container without subtype.
2. Create binary container without subtype.
3. Create binary container with subtype.

## Parameters

`container` (in)
:   binary container

`subtype` (in)
:   subtype

## Examples

??? example

    The example below demonstrates how byte containers can be created.

    ```cpp
    --8<-- "examples/byte_container_with_subtype__byte_container_with_subtype.cpp"
    ```
    
    Output:
    
    ```json
    --8<-- "examples/byte_container_with_subtype__byte_container_with_subtype.output"
    ```

## Version history

Since version 3.8.0.
