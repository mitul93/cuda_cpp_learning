cmake_minimum_required(VERSION 4.0)

if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
    message(STATUS "CMAKE_TOOLCHAIN_FILE = ${CMAKE_TOOLCHAIN_FILE}")
endif()

# Location of custom triplets
# https://learn.microsoft.com/en-us/vcpkg/concepts/triplets#triplet-selection
set(VCPKG_OVERLAY_TRIPLETS "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/triplets/" CACHE STRING "")

# configure detection of host and target triplets
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/vcpkg-auto-triplet.cmake)

# Set compiler for host and CUDA
# Must be set before calling project()
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/clang-toolchain.cmake)


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

# use lambda on device
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --extended-lambda")

# if(ENABLE_CUDA_DEBUG)
#     set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -G")        # enable cuda-gdb (may significantly affect performance on some targets)
# else()
#     set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -lineinfo") # add line information to all builds for debug tools (exclusive to -G option)
# endif()

find_package(CUDAToolkit REQUIRED)

option(BUILD_TESTS "Build unit tests" OFF)

add_subdirectory(src)
add_subdirectory(examples)

if(BUILD_TESTS)
  enable_testing()
  add_subdirectory(test)
endif()

if(BUILD_BENCHMARKS)
    add_subdirectory(benchmark)
endif()