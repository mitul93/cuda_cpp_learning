cmake_minimum_required(VERSION 4.0)

if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()

# Must be set before calling project()
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CUDA_HOST_COMPILER clang++)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# project() declares the project name AND which languages CMake needs
# to configure compilers for. This is the CMake equivalent of "enable_language" —
# you almost never need enable_language() separately if you list it here.
project(cuda_cpp_learning LANGUAGES CXX CUDA)

# C++ standard settings (applies to .cpp files)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# CUDA standard settings (applies to .cu files)
set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# Which GPU architectures to compile for.
# Find yours: run `nvidia-smi` then look up compute capability for your card.
# 75 = Turing (RTX 20xx), 86 = Ampere (RTX 30xx), 90 = Hopper (H100)
# https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html
set(CMAKE_CUDA_ARCHITECTURES 86)

# if(ENABLE_CUDA_DEBUG)
#     set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -G")        # enable cuda-gdb (may significantly affect performance on some targets)
# else()
#     set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -lineinfo") # add line information to all builds for debug tools (exclusive to -G option)
# endif()

find_package(CUDAToolkit REQUIRED)

option(BUILD_TESTS "Build unit tests" OFF)

add_subdirectory(src)

if(BUILD_TESTS)
  enable_testing()
  add_subdirectory(test)
endif()