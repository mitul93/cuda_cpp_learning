set(BUILD_EXAMPLE "" CACHE STRING "Comma-separated examples to build")

if(BUILD_EXAMPLE)
    string(REPLACE "," ";" EXAMPLES "${BUILD_EXAMPLE}")

    foreach(example IN LISTS EXAMPLES)
        message(STATUS "Adding example: ${example}")
        add_subdirectory(${example})
    endforeach()
else()
    file(GLOB_RECURSE example_cmakelists
        RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt"
    )

    foreach(cmake_file IN LISTS example_cmakelists)
        get_filename_component(example_dir "${cmake_file}" DIRECTORY)

        message(STATUS "Adding example: ${example_dir}")
        add_subdirectory("${example_dir}")
    endforeach()
endif()