get_filename_component(CURRENT_DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

add_executable(${CURRENT_DIR_NAME}
    main.cu
)

target_include_directories(${CURRENT_DIR_NAME}
    PRIVATE
        ${PROJECT_SOURCE_DIR}/src
)

target_link_libraries(${CURRENT_DIR_NAME}
    PRIVATE
        nvbench::main
)