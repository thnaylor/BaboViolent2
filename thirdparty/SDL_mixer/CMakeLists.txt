cmake_minimum_required(VERSION 3.5)
project(SDL2_mixer C)

add_library(SDL2_mixer STATIC
    mixer.c
    music.c
    music_wav.c
    music_ogg.c
    music_cmd.c
    effects_internal.c
    effect_position.c
    effect_stereoreverse.c
    load_aiff.c
    load_voc.c
)

target_compile_definitions(SDL2_mixer PRIVATE MUSIC_WAV MUSIC_OGG)

target_include_directories(SDL2_mixer PUBLIC .)

target_include_directories(SDL2_mixer PRIVATE
    ${CMAKE_SOURCE_DIR}/thirdparty/SDL/include
    ${CMAKE_SOURCE_DIR}/thirdparty/libvorbis/include
    ${CMAKE_SOURCE_DIR}/thirdparty/libogg/include
)

target_link_libraries(SDL2_mixer PRIVATE SDL2-static vorbisfile vorbis ogg)

if(MSVC)
    target_compile_options(SDL2_mixer PRIVATE /W0)
endif()
