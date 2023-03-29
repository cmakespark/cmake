cmake_minimum_required(VERSION 3.4.3 FATAL_ERROR)
project(cmakespark)

#Set & cache variable version number, Change global QT version number here
set(QT_MAJOR_VERSION_REQUIRED 6 CACHE STRING "QT Major version variable")

add_subdirectory(src)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/src")
include(CommonConfig)

add_subdirectory(tests)

# Examples
include(ExternalProject)

ExternalProject_Add(simplelib
                    PREFIX examples
                    GIT_REPOSITORY "https://github.com/cmakespark/simplelib.git"
                    GIT_TAG master
                    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKESPARK=${CMAKE_CURRENT_LIST_DIR}/src
                    INSTALL_DIR ${CMAKE_INSTALL_PREFIX})

ExternalProject_Add(simpleapp
                    PREFIX examples
                    GIT_REPOSITORY "https://github.com/cmakespark/simpleapp.git"
                    GIT_TAG master
                    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKESPARK=${CMAKE_CURRENT_LIST_DIR}/src -DCC2SimpleLib_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/CC2SimpleLib
                    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
                    DEPENDS simplelib)

ExternalProject_Add(QSimpleApp
                    PREFIX examples
                    GIT_REPOSITORY "https://github.com/cmakespark/QSimpleApp.git"
                    GIT_TAG master
                    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKESPARK=${CMAKE_CURRENT_LIST_DIR}/src -DCC2SimpleLib_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/CC2SimpleLib -DQt${QT_MAJOR_VERSION_REQUIRED}Core_DIR=${Qt${QT_MAJOR_VERSION_REQUIRED}Core_DIR}
                    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
                    DEPENDS simplelib)

ExternalProject_Add(complexlib
                    PREFIX examples
                    GIT_REPOSITORY "https://github.com/cmakespark/complexlib.git"
                    GIT_TAG master
                    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKESPARK=${CMAKE_CURRENT_LIST_DIR}/src -DQt${QT_MAJOR_VERSION_REQUIRED}Core_DIR=${Qt${QT_MAJOR_VERSION_REQUIRED}Core_DIR} -DQt${QT_MAJOR_VERSION_REQUIRED}Test_DIR=${Qt${QT_MAJOR_VERSION_REQUIRED}Test_DIR}
                    INSTALL_DIR ${CMAKE_INSTALL_PREFIX})
