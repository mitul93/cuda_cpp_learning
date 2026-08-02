find_package(benchmark CONFIG REQUIRED)
find_package(nvbench REQUIRED)

add_subdirectory(cuda_memcpy)
add_subdirectory(nvbench_example)