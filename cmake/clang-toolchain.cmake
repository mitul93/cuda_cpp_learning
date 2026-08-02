# clang-toolchain
# 
# This script set c/c++ compiler to clang/clang++
# It will also set CUDA host compiler to clang++
#

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CUDA_HOST_COMPILER clang++)