cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_EXTENSIONS OFF)

set(DEFAULT_BUILD_TYPE "Debug")

option(WARNINGS_AS_ERRORS "Globally fail all builds on any warnings" OFF)
if(WARNINGS_AS_ERRORS)
    if(MSVC)
        add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:/WX>")
        add_link_options("$<$<COMPILE_LANGUAGE:C,CXX>:/WX>")
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "IAR")
        add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:--warnings_are_errors>")
        add_link_options("$<$<COMPILE_LANGUAGE:C,CXX>:--warnings_are_errors>")
    else()
        add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:-Werror>")
    endif()
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "${DEFAULT_BUILD_TYPE}")
endif()

project(BARE_METAL_WORKSHOP_20240626
        LANGUAGES C CXX ASM
)

include("${CMAKE_CURRENT_LIST_DIR}/gcc-arm-none-eabi.cmake")

add_executable(BareMetalWorkshop main.cpp)
# Not sure how to add these files nor where?
# target_sources(BareMetalWorkshop INTERFACE
#     ./sysmem.c
#     ./syscalls.c
#     ./startup_stm32f446xx.s
#     ./system_stm32f4xx.c
# )