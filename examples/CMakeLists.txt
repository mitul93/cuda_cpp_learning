set(BUILD_EXAMPLE "" CACHE STRING "Comma-separated examples to build")

if(BUILD_EXAMPLE)
    string(REPLACE "," ";" EXAMPLES "${BUILD_EXAMPLE}")

    foreach(example IN LISTS EXAMPLES)
        message(STATUS "Adding example: ${example}")
        add_subdirectory(${example})
    endforeach()
else()
    file(GLOB children RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/*")

    foreach(child IN LISTS children)
        if(
            IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${child}"
            AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${child}/CMakeLists.txt"
        )
            message(STATUS "Adding example: ${child}")
            add_subdirectory("${child}")
        endif()
    endforeach()
endif()