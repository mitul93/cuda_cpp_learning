set(BUILD_EXAMPLE "" CACHE STRING "Comma-separated examples to build")

if(BUILD_EXAMPLE)
    string(REPLACE "," ";" EXAMPLES "${BUILD_EXAMPLE}")

    foreach(example IN LISTS EXAMPLES)
        message(STATUS "Adding example: ${example}")
        add_subdirectory(${example})
    endforeach()
else()
    add_subdirectory(01_hello_world)
    # Add more examples here
endif()