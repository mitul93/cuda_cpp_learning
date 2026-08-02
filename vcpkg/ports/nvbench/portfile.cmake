vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/nvbench
    REF e57ecad88325d3e4d791ea2cfbc5db31f0b08b7e
    SHA512 cbe8092997f94aff59cdcdbc68586258797a1c4c20de14144a9c449fb1fde38df1ebb541175af0948ce4942b6419c83efbaedfce0ac4f15cd1a76a2183c096f2
    HEAD_REF main
)

# Separately fetch rapids-cmake source (pin to the version nvbench expects)
vcpkg_from_github(
    OUT_SOURCE_PATH RAPIDS_CMAKE_SOURCE_PATH
    REPO rapidsai/rapids-cmake
    REF "v25.12.00"
    SHA512 dcd8a28e860bf76dfb27f8e8c8a43dbb563936783fa2ad1ebf31744731d99da11764c786ee80e7f3961f7f45da79af7ac419d8d3cde3cd31c2ecbcde7fc8858f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE=${RAPIDS_CMAKE_SOURCE_PATH}
        -DCPM_USE_LOCAL_PACKAGES=ON
        # nvbench options
        -DNVBench_ENABLE_NVML=ON
        -DNVBench_ENABLE_TESTING=OFF
        -DNVBench_ENABLE_HEADER_TESTING=OFF
        -DNVBench_ENABLE_DEVICE_TESTING=OFF
        -DNVBench_ENABLE_EXECUTABLES=ON
        -DNVBench_ENABLE_EXAMPLES=OFF
)

vcpkg_cmake_install()

## For Debugging
# CURRENT_PACKAGES_DIR=/home/devconainer/vcpkg/packages/nvbench_x64-linux
# file(GLOB_RECURSE _nvbench_installed_files "${CURRENT_PACKAGES_DIR}/*")
# message(STATUS "=== nvbench installed files ===")
# foreach(f IN LISTS _nvbench_installed_files)
#     message(STATUS "  ${f}")
# endforeach()

vcpkg_copy_tools(
    TOOL_NAMES nvbench-ctl
    AUTO_CLEAN
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/lib/cmake/nvbench/nvbench-config.cmake"
        "set(nvbench_SHARED_LIBS ON)"
        "set(nvbench_SHARED_LIBS OFF)"
    )
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME nvbench
    CONFIG_PATH lib/cmake/nvbench
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)