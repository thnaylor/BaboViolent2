cmake_minimum_required(VERSION 3.10)

# Define LINUX
if (UNIX AND NOT APPLE)
    set(LINUX 1)
endif()

# Setup modules path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")

# Project name
project(BaboViolent)

if(POLICY CMP0072)
    cmake_policy(SET CMP0072 NEW)
endif()

# Some compiler flags
set(CMAKE_CXX_STANDARD 11) # C++11
if (MSVC)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" "/MP /FS") # Multi core + serialised PDB writes
endif()

# Define _DEBUG
if (CMAKE_BUILD_TYPE MATCHES Debug)
    add_definitions(-D_DEBUG)
endif()

#justwindowsthings
if (WIN32)
    add_definitions(-DNOMINMAX)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()

# PRO version
add_definitions(-D_PRO_)
add_definitions(-D_MINIBOT_)

# Project files
file(GLOB src_Engine_Babonet ./src/Engine/Babonet/*.*)
source_group("Engine\\Babonet" FILES ${src_Engine_Babonet})
file(GLOB src_Engine_dko ./src/Engine/dko/*.*)
source_group("Engine\\dko" FILES ${src_Engine_dko})
file(GLOB src_Engine_Zeven_dkc ./src/Engine/Zeven/dkc/*.*)
source_group("Engine\\Zeven\\dkc" FILES ${src_Engine_Zeven_dkc})
file(GLOB src_Engine_Zeven_dkf ./src/Engine/Zeven/dkf/*.*)
source_group("Engine\\Zeven\\dkf" FILES ${src_Engine_Zeven_dkf})
file(GLOB src_Engine_Zeven_dkgl ./src/Engine/Zeven/dkgl/*.*)
source_group("Engine\\Zeven\\dkgl" FILES ${src_Engine_Zeven_dkgl})
file(GLOB src_Engine_Zeven_dki ./src/Engine/Zeven/dki/*.*)
source_group("Engine\\Zeven\\dki" FILES ${src_Engine_Zeven_dki})
file(GLOB src_Engine_Zeven_dkp ./src/Engine/Zeven/dkp/*.*)
source_group("Engine\\Zeven\\dkp" FILES ${src_Engine_Zeven_dkp})
file(GLOB src_Engine_Zeven_dks ./src/Engine/Zeven/dks/*.*)
source_group("Engine\\Zeven\\dks" FILES ${src_Engine_Zeven_dks})
file(GLOB src_Engine_Zeven_dksvar ./src/Engine/Zeven/dksvar/*.*)
source_group("Engine\\Zeven\\dksvar" FILES ${src_Engine_Zeven_dksvar})
file(GLOB src_Engine_Zeven_dkt ./src/Engine/Zeven/dkt/*.*)
source_group("Engine\\Zeven\\dkt" FILES ${src_Engine_Zeven_dkt})
file(GLOB src_Engine_Zeven_dkw ./src/Engine/Zeven/dkw/*.*)
source_group("Engine\\Zeven\\dkw" FILES ${src_Engine_Zeven_dkw})
file(GLOB src_External ./src/External/*.*)
source_group("External" FILES ${src_External})
file(GLOB src_Game ./src/Game/*.*)
source_group("Game" FILES ${src_Game})
file(GLOB src_Game_AStar ./src/Game/AStar/*.*)
source_group("Game\\AStar" FILES ${src_Game_AStar})
file(GLOB src_Game_Master ./src/Game/Master/*.*)
source_group("Game\\Master" FILES ${src_Game_Master})
file(GLOB src_Menu ./src/Menu/*.*)
source_group("Menu" FILES ${src_Menu})
file(GLOB src_Menu2 ./src/Menu2/*.*)
source_group("Menu2" FILES ${src_Menu2})
file(GLOB src_Menu2_Dialogs ./src/Menu2/Dialogs/*.*)
source_group("Menu2\\Dialogs" FILES ${src_Menu2_Dialogs})
file(GLOB src_Source ./src/Source/*.*)
source_group("Source" FILES ${src_Source})
file(GLOB src_Weather ./src/Weather/*.*)
source_group("Weather" FILES ${src_Weather})
file(GLOB src_Zeven ./src/Zeven/*.*)
source_group("Zeven" FILES ${src_Zeven})
file(GLOB src_Zeven_API ./src/Zeven/API/*.*)
source_group("Zeven\\API" FILES ${src_Zeven_API})

list(APPEND includes PUBLIC
    ./src/Engine/Babonet/
    ./src/Engine/dko/
    ./src/Engine/Zeven/dkc/
    ./src/Engine/Zeven/dkf/
    ./src/Engine/Zeven/dkgl/
    ./src/Engine/Zeven/dki/
    ./src/Engine/Zeven/dkp/
    ./src/Engine/Zeven/dks/
    ./src/Engine/Zeven/dksvar/
    ./src/Engine/Zeven/dkt/
    ./src/Engine/Zeven/dkw/
    ./src/External/
    ./src/Game/
    ./src/Game/AStar/
    ./src/Game/Master/
    ./src/Menu/
    ./src/Menu2/
    ./src/Menu2/Dialogs/
    ./src/Source/
    ./src/Weather/
    ./src/Zeven/
    ./src/Zeven/API/
)

if (UNIX)
    list(APPEND includes PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src/compat/linux
    )
endif()

# sqlite3 (omit shell.c — it defines its own main())
set(src_thirdparty_sqlite
    ./thirdparty/sqlite/sqlite3.c
    ./thirdparty/sqlite/sqlite3.h
    ./thirdparty/sqlite/sqlite3ext.h
)
source_group("thirdparty\\sqlite" FILES ${src_thirdparty_sqlite})
list(APPEND includes ./thirdparty/sqlite/)

# SDL — bundled static, except Linux+SDL2_mixer: distro libSDL2_mixer.so needs the same (system) libSDL2 as in its .pc file.
set(BV2_LINUX_SYS_SDL2 OFF)
if(UNIX AND NOT APPLE)
	find_package(PkgConfig QUIET)
	if(PKG_CONFIG_FOUND)
		pkg_check_modules(SDL2MIXER QUIET SDL2_mixer)
		if(SDL2MIXER_FOUND)
			set(BV2_LINUX_SYS_SDL2 ON)
		endif()
	endif()
endif()

if(WIN32 OR APPLE OR NOT BV2_LINUX_SYS_SDL2)
	set(HAVE_LIBC ON)
	add_subdirectory(./thirdparty/SDL/)
	list(APPEND libs SDL2-static)
	list(APPEND includes PUBLIC ./thirdparty/SDL/include/)
endif()

if(BV2_LINUX_SYS_SDL2)
	message(STATUS "SDL2_mixer found — USE_SDL_MIXER; linking system libSDL2 (matches libSDL2_mixer.so ABI)")
	add_definitions(-DUSE_SDL_MIXER)
	list(APPEND libs ${SDL2MIXER_LIBRARIES})
	list(APPEND includes ${SDL2MIXER_INCLUDE_DIRS})
elseif(WIN32)
	# Build SDL_mixer 2.0.4 + libogg + libvorbis statically from source
	message(STATUS "SDL2_mixer — building bundled static library for Windows (WAV + OGG)")
	set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
	add_subdirectory(./thirdparty/libogg/)
	add_subdirectory(./thirdparty/libvorbis/)
	add_subdirectory(./thirdparty/SDL_mixer/)
	add_definitions(-DUSE_SDL_MIXER)
	list(APPEND libs SDL2_mixer)
	list(APPEND includes PUBLIC ./thirdparty/SDL_mixer/)
else()
	if(UNIX AND NOT APPLE)
		message(STATUS "SDL2_mixer not found — client will have no audio (install SDL2_mixer-devel or use FMOD)")
	endif()
endif()

# OpenGL — headers only on Windows (BrebisGL loads opengl32.dll at runtime;
# linking opengl32.lib would duplicate the symbols BrebisGL defines as function pointers)
find_package(OpenGL REQUIRED)
list(APPEND includes PUBLIC ${OPENGL_INCLUDE_DIR})
if (NOT WIN32)
    list(APPEND libs ${OPENGL_LIBRARIES})
endif()

# Dear imgui
list(APPEND src_thirdparty_imgui
    ./thirdparty/imgui/imgui_demo.cpp
    ./thirdparty/imgui/imgui_draw.cpp
    ./thirdparty/imgui/imgui_internal.h
    ./thirdparty/imgui/imgui.cpp
    ./thirdparty/imgui/imgui.h
    ./thirdparty/imgui/stb_rect_pack.h
    ./thirdparty/imgui/stb_textedit.h
    ./thirdparty/imgui/stb_truetype.h
    ./thirdparty/imgui/examples/imgui_impl_opengl3.cpp
    ./thirdparty/imgui/examples/imgui_impl_opengl3.h
    ./thirdparty/imgui/examples/imgui_impl_sdl.cpp
    ./thirdparty/imgui/examples/imgui_impl_sdl.h
)
source_group("thirdparty\\imgui" FILES ${src_thirdparty_imgui})
list(APPEND includes PUBLIC ./thirdparty/imgui/ ./thirdparty/imgui/examples/)

# BrebisGL
list(APPEND includes PUBLIC ./thirdparty/BrebisGL/)
file(GLOB src_thirdparty_brebisgl ./thirdparty/BrebisGL/*.*)

set(BV2_COMMON_SOURCES
    ${src_Engine_Babonet}
    ${src_Engine_dko}
    ${src_Engine_Zeven_dkc}
    ${src_Engine_Zeven_dkf}
    ${src_Engine_Zeven_dkgl}
    ${src_Engine_Zeven_dki}
    ${src_Engine_Zeven_dkp}
    ${src_Engine_Zeven_dks}
    ${src_Engine_Zeven_dksvar}
    ${src_Engine_Zeven_dkt}
    ${src_Engine_Zeven_dkw}
    ${src_External}
    ${src_Game}
    ${src_Game_AStar}
    ${src_Game_Master}
    ${src_Menu}
    ${src_Menu2}
    ${src_Menu2_Dialogs}
    ${src_Source}
    ${src_Weather}
    ${src_Zeven}
    ${src_Zeven_API}
    ${src_thirdparty_sqlite}
    ${src_thirdparty_imgui}
    ${src_thirdparty_brebisgl}
)

if(WIN32)
    set(BV2_WIN32_LIBS ws2_32 iphlpapi winmm opengl32 glu32 gdi32 imm32 version ole32 oleaut32 setupapi)
    list(APPEND libs ${BV2_WIN32_LIBS})
endif()

if(UNIX AND NOT APPLE)
    find_package(Threads REQUIRED)
    list(APPEND libs Threads::Threads ${CMAKE_DL_LIBS})
endif()

if(APPLE)
    add_definitions(-D__MACOSX__)
endif()

# Client (graphical)
if(WIN32)
    add_executable(BaboViolent WIN32 ${BV2_COMMON_SOURCES})
    # BrebisGL defines GL functions as function pointers; opengl32.lib also exports them.
    # /FORCE:MULTIPLE lets BrebisGL's definitions win. opengl32.lib is still needed for
    # wglGetProcAddress and functions accessed via the legacy <GL/gl.h> include path.
    target_link_options(BaboViolent PRIVATE /FORCE:MULTIPLE /ignore:4006)
else()
    add_executable(BaboViolent ${BV2_COMMON_SOURCES})
endif()
target_include_directories(BaboViolent ${includes})
target_link_libraries(BaboViolent ${libs})

# Dedicated game server (same sources, DEDICATED_SERVER)
add_executable(BaboViolentDedicated ${BV2_COMMON_SOURCES})
target_compile_definitions(BaboViolentDedicated PRIVATE DEDICATED_SERVER)
target_include_directories(BaboViolentDedicated ${includes})
target_link_libraries(BaboViolentDedicated ${libs})

# Master listing server (TCP BaboMasterServer)
set(MASTERSERVER_SRC_DIR ${CMAKE_SOURCE_DIR}/src/MasterListingServer)
set(MASTERSERVER_SOURCES
    ${MASTERSERVER_SRC_DIR}/baboNet.cpp
    ${MASTERSERVER_SRC_DIR}/cBV2game.cpp
    ${MASTERSERVER_SRC_DIR}/CClient.cpp
    ${MASTERSERVER_SRC_DIR}/cConnection.cpp
    ${MASTERSERVER_SRC_DIR}/cDNSquery.cpp
    ${MASTERSERVER_SRC_DIR}/cIncConnection.cpp
    ${MASTERSERVER_SRC_DIR}/cMasterServer.cpp
    ${MASTERSERVER_SRC_DIR}/MasterClient.cpp
    ${MASTERSERVER_SRC_DIR}/cNetManager.cpp
    ${MASTERSERVER_SRC_DIR}/cPacket.cpp
    ${MASTERSERVER_SRC_DIR}/cPeer.cpp
    ${MASTERSERVER_SRC_DIR}/cPeer2Peer.cpp
    ${MASTERSERVER_SRC_DIR}/CServer.cpp
    ${MASTERSERVER_SRC_DIR}/cUDPpacket.cpp
    ${MASTERSERVER_SRC_DIR}/CThread.cpp
    ${MASTERSERVER_SRC_DIR}/dkc.cpp
    ${MASTERSERVER_SRC_DIR}/main.cpp
    ${CMAKE_SOURCE_DIR}/src/Engine/Babonet/md5c.c
    ${CMAKE_SOURCE_DIR}/src/Engine/Babonet/md5class.cpp
    ./thirdparty/sqlite/sqlite3.c
)
add_executable(BaboMasterServer ${MASTERSERVER_SOURCES})
target_include_directories(BaboMasterServer PRIVATE
    ${CMAKE_SOURCE_DIR}/src/Engine/Babonet
    ${MASTERSERVER_SRC_DIR}
    ${CMAKE_SOURCE_DIR}/thirdparty/sqlite
)
set_target_properties(BaboMasterServer PROPERTIES CXX_STANDARD 11)
find_package(Threads REQUIRED)
target_link_libraries(BaboMasterServer PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
if(WIN32)
    target_link_libraries(BaboMasterServer PRIVATE ws2_32 iphlpapi)
else()
    target_compile_options(BaboMasterServer PRIVATE -Wno-deprecated-declarations)
endif()