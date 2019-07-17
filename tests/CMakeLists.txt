add_subdirectory(valgrind)
add_subdirectory(AddResourceInfo)

add_custom_target(runtests
    COMMAND ${CMAKE_COMMAND} -DBASEDIR=${CMAKE_BINARY_DIR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -P ${CMAKE_CURRENT_LIST_DIR}/runtests.cmake
    SOURCES runtests.cmake)
