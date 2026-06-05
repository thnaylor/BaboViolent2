cmake_minimum_required(VERSION 3.5)
project(vorbis C)

set(LIB ${CMAKE_CURRENT_SOURCE_DIR}/lib)

add_library(vorbis STATIC
    ${LIB}/analysis.c
    ${LIB}/bitrate.c
    ${LIB}/block.c
    ${LIB}/codebook.c
    ${LIB}/envelope.c
    ${LIB}/floor0.c
    ${LIB}/floor1.c
    ${LIB}/info.c
    ${LIB}/lpc.c
    ${LIB}/lsp.c
    ${LIB}/lookup.c
    ${LIB}/mapping0.c
    ${LIB}/mdct.c
    ${LIB}/psy.c
    ${LIB}/registry.c
    ${LIB}/res0.c
    ${LIB}/sharedbook.c
    ${LIB}/smallft.c
    ${LIB}/synthesis.c
    ${LIB}/window.c
)

add_library(vorbisfile STATIC
    ${LIB}/vorbisfile.c
)

target_include_directories(vorbis PUBLIC include)
target_include_directories(vorbis PRIVATE
    ${CMAKE_SOURCE_DIR}/thirdparty/libogg/include
)
target_link_libraries(vorbis PUBLIC ogg)

target_include_directories(vorbisfile PUBLIC include)
target_include_directories(vorbisfile PRIVATE
    ${CMAKE_SOURCE_DIR}/thirdparty/libogg/include
)
target_link_libraries(vorbisfile PUBLIC vorbis ogg)

if(MSVC)
    target_compile_options(vorbis PRIVATE /W0)
    target_compile_options(vorbisfile PRIVATE /W0)
endif()
