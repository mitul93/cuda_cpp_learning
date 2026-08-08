# CMAKE_CURRENT_SOURCE_DIR = full path to this folder, e.g. .../src/01_hello_world
# NAME mode strips it down to just "01_hello_world"
get_filename_component(CURRENT_DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

add_executable(${CURRENT_DIR_NAME}
    main.cu
)

target_include_directories(${CURRENT_DIR_NAME}
    PRIVATE
        ${PROJECT_SOURCE_DIR}/src
)
