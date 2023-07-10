cmake_minimum_required(VERSION 3.5.2 FATAL_ERROR)

set(ISSHAREDLIBRARY FALSE)
if (DEFINED BUILD_SHARED_LIBS)
    set(ISSHAREDLIBRARY ${BUILD_SHARED_LIBS})
endif()
if (${ISSHAREDLIBRARY})
    add_definitions(-D${PROJECT_NAME}_BUILD_SHARED_LIBS)
endif()


# Usage of Qt libraries (optional)
# --------------------------------
find_package(Qt6Core QUIET)
if (Qt6Core_FOUND)
    # Instruct CMake to run moc automatically when needed.
    set(CMAKE_AUTOMOC ON)
    # let CMake decide which classes need to be rcc'ed by qmake (Qt)
    set(CMAKE_AUTORCC ON)
    # let CMake decide which classes need to be uic'ed by qmake (Qt)
    set(CMAKE_AUTOUIC ON)
endif (Qt6Core_FOUND)

# Check if minimal compiler versions requirements are met with corresponding with Qt compiler versions
# --------------------------------
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 11.0)
        message(FATAL_ERROR "GCC version must be at least 11.0")
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 11.0)
        message(FATAL_ERROR "Clang version must be at least 11.0")
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.0)
        message(FATAL_ERROR "Projects in this repo requires the VisualStudio 2019 or higher compiler for Windows builds")
    endif()
endif()

# Usage of CMake Packages
# -----------------------
include(CMakePackageConfigHelpers)

# Point cmake to the packages of libraries in this tree.
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR}/local-exports)


# Prepare environment #
# ---------------------

if (DEFINED ENV{CMAKE_MODULE_PATH})
    set(_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
    set(CMAKE_MODULE_PATH $ENV{CMAKE_MODULE_PATH} CACHE PATH "Set module path to $ENV{CMAKE_MODULE_PATH}" FORCE)
    list(APPEND CMAKE_MODULE_PATH ${_CMAKE_MODULE_PATH})
endif (DEFINED ENV{CMAKE_MODULE_PATH})

if (DEFINED ENV{CMAKE_INSTALL_PREFIX})
    set(CMAKE_INSTALL_PREFIX $ENV{CMAKE_INSTALL_PREFIX} CACHE PATH "Set install prefix to $ENV{CMAKE_INSTALL_PREFIX}" FORCE)
    list(APPEND CMAKE_PREFIX_PATH $ENV{CMAKE_INSTALL_PREFIX})
endif (DEFINED ENV{CMAKE_INSTALL_PREFIX})


# Compiler flags
# --------------
if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    # not using Visual Studio C++
    add_definitions(-Wall -fvisibility=hidden)
endif()
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Compile with @rpath option on Apple
cmake_policy(SET CMP0068 NEW)
if (APPLE)
  set(CMAKE_MACOSX_RPATH 1)
endif (APPLE)

if(WIN32)
    add_definitions(-DUNICODE)
    add_definitions(-DNOMINMAX)
    link_libraries(Userenv)
endif(WIN32)

# Switch testing on
# -----------------
enable_testing()
list(APPEND CMAKE_CTEST_ARGUMENTS "--output-on-failure")

find_package(Qt6Core QUIET)
if (Qt6Core_FOUND)
    include(AddQtTest)
endif (Qt6Core_FOUND)
if (MANUAL_TESTS_ENABLED)
  message(STATUS "Manual tests are enabled")
  add_definitions(-DMANUAL_TESTS_ENABLED)
endif()

# Code analysis with cppcheck
include(Cppcheck)

# Code coverage with gcov
include(CodeCoverage)

# Common compiler flags
include(CompilerFlags)

# Create package
include(Package)

# Put all binaries in single directory (so libraries and executables work together in Windows)
include(SetOutputDir)
set_global_output_dir("${CMAKE_BINARY_DIR}/bin")

# Version and build hash
add_definitions(-DVERSION="${FULL_VERSION}")
execute_process(COMMAND git rev-parse --short HEAD
    OUTPUT_VARIABLE BUILD_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
add_definitions(-DBUILD_HASH="${BUILD_HASH}")
# Create documentation with doxygen
include(Doxygen)

# Generate information (name, description, version, etc.) for applications and libraries
include(GetGitRevisionDescription)
include(GetVersionFromGitTag)
include(AddResourceInfo)
include(Methods)

