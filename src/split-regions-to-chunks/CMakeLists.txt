cmake_minimum_required(VERSION 3.0)
project(mcfile)

include_directories(../libminecraft-file/include ../hwm.task)
add_definitions(-std=c++17)
add_executable(split-regions-to-chunks main.cpp ../libminecraft-file/include/minecraft-file.hpp)
target_link_libraries(split-regions-to-chunks z)
