cmake_minimum_required(VERSION 3.22)
project(mtluau LANGUAGES C CXX)

include(FetchContent)
set(LUAU_BUILD_CLI OFF CACHE BOOL "" FORCE)
set(LUAU_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LUAU_BUILD_WEB OFF CACHE BOOL "" FORCE)
FetchContent_Declare(luau
  GIT_REPOSITORY https://github.com/luau-lang/luau.git
  GIT_TAG 0.727
  GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(luau)

add_library(mtluau SHARED mtluau.cpp)
target_compile_features(mtluau PRIVATE cxx_std_17)
target_include_directories(mtluau PRIVATE
  ${luau_SOURCE_DIR}/VM/include
  ${luau_SOURCE_DIR}/Compiler/include
)
target_link_libraries(mtluau PRIVATE Luau.VM Luau.Compiler android log)
