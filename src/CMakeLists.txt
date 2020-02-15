cmake_minimum_required(VERSION 3.0)
project(mcfile)

include(CheckCCompilerFlag)

include_directories(./libminecraft-file/include ./hwm.task)
add_definitions(-std=c++17)

add_executable(split-regions-to-chunks split-regions-to-chunks/main.cpp ./libminecraft-file/include/minecraft-file.hpp)
add_executable(merge-chunks-to-regions merge-chunks-to-regions/main.cpp ./libminecraft-file/include/minecraft-file.hpp)

list(APPEND link_libraries "z")

set(CMAKE_REQUIRED_FLAGS "-lstdc++fs")
check_c_compiler_flag("" TEST_RESULT_STDCXXFS)
if (TEST_RESULT_STDCXXFS AND "${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
  list(APPEND link_libraries stdc++fs)
endif()

set(CMAKE_REQUIRED_FLAGS "-pthread")
check_c_compiler_flag("" TEST_RESULT_PTHREAD)
if (TEST_RESULT_PTHREAD)
  list(APPEND link_libraries pthread)
endif()

target_link_libraries(split-regions-to-chunks ${link_libraries})
target_link_libraries(merge-chunks-to-regions ${link_libraries})
