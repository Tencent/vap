# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(XComponent)

set(CMAKE_CXX_STANDARD 17)
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-DOHOS_PLATFORM)

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/include
    ${NATIVERENDER_ROOT_PATH}/include/util
    ${NATIVERENDER_ROOT_PATH}/include/render
    ${NATIVERENDER_ROOT_PATH}/include/mask
    ${NATIVERENDER_ROOT_PATH}/include/mix
    ${NATIVERENDER_ROOT_PATH}/include/napi
    ${NATIVERENDER_ROOT_PATH}/include/util/json/include
)

#add_subdirectory(${NATIVERENDER_ROOT_PATH}/include/util/json)

add_library(vap SHARED
    manager/plugin_manager.cpp
    mask/mask_config.cpp
    mask/mask_render.cpp
    mask/mask_shader.cpp
    mix/frame.cpp
    mix/mix_render.cpp
    mix/mix_shader.cpp
    mix/src.cpp
    napi/n_val.cpp
    napi/n_func_arg.cpp
    render/egl_core.cpp
    render/plugin_render.cpp
    render/yuv_render.cpp
    render/anim_config.cpp
    util/shader_util.cpp
    util/tex_coords_util.cpp
    util/vertex_util.cpp
    util/texture_load_util.cpp
    napi_init.cpp
    video_decoder.cpp
    demuxer.cpp
    player.cpp
    audio_decoder.cpp
    resource_request.cpp
    vap_callback.cpp
)

target_link_libraries(vap PUBLIC EGL)
target_link_libraries(vap PUBLIC GLESv3)
target_link_libraries(vap PUBLIC hilog_ndk.z)
target_link_libraries(vap PUBLIC ace_ndk.z)
target_link_libraries(vap PUBLIC ace_napi.z)
target_link_libraries(vap PUBLIC libc++.a)
target_link_libraries(vap PUBLIC z)
target_link_libraries(vap PUBLIC uv)
target_link_libraries(vap PUBLIC libace_napi.z.so)
target_link_libraries(vap PUBLIC libnative_media_codecbase.so)
target_link_libraries(vap PUBLIC libnative_media_core.so)
target_link_libraries(vap PUBLIC libnative_media_vdec.so)
target_link_libraries(vap PUBLIC libnative_media_adec.so)
target_link_libraries(vap PUBLIC libnative_media_acodec.so)
target_link_libraries(vap PUBLIC libnative_media_avsource.so)
target_link_libraries(vap PUBLIC libnative_media_avdemuxer.so)
target_link_libraries(vap PUBLIC libavplayer.so)
target_link_libraries(vap PUBLIC libohaudio.so)
target_link_libraries(vap PUBLIC libnative_drawing.so)
target_link_libraries(vap PUBLIC libpixelmap_ndk.z.so)
target_link_libraries(vap PUBLIC libimage_source.so)
target_link_libraries(vap PUBLIC libpixelmap.so)
#target_link_libraries(vap PUBLIC nlohmann_json::nlohmann_json)