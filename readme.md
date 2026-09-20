# CMakeSpark

CMakeSpark is a small collection of reusable CMake modules for common project tasks such as:

- default compiler and platform configuration
- creating libraries and executables with consistent install rules
- generating relocatable CMake package files
- Qt-aware unit-test helpers
- code coverage and static analysis helpers
- version handling from Git tags

The project is intended to be used as a local CMake dependency in other repositories.

## Repository structure

The build logic is split into helper modules under `src/`:

- `CommonConfig.cmake` – central include for default project setup
- `Methods.cmake` – defines `createlib()` and `createapp()`
- `AddQtTest.cmake` – Qt test helpers
- `CodeCoverage.cmake` – coverage targets
- `Cppcheck.cmake` – Cppcheck integration
- `Doxygen.cmake` – documentation generation
- `GetVersionFromGitTag.cmake` – semantic version extraction from Git
- `Package.cmake` and related config templates – packaging/install support

## Adding the project to another repo

There are two common ways to include the build system.

### Option 1: Git submodule

```bash
git submodule add -b <tag> https://github.com/cmakespark/cmake.git path/to/cmakespark
```

Then add the module directory to CMake's search path:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/path/to/cmakespark/src")
include(CommonConfig)
```

### Option 2: Download during configure

```cmake
set(CMAKESPARK_VERSION "2.0.0" CACHE STRING "CMakeSpark version")
if(NOT EXISTS "${CMAKE_BINARY_DIR}/buildsys/v${CMAKESPARK_VERSION}")
    message(STATUS "Downloading buildsystem...")

    set(CMAKESPARK_ARCHIVE "${CMAKE_BINARY_DIR}/buildsys/cmakespark-${CMAKESPARK_VERSION}.zip")
    file(DOWNLOAD "https://github.com/cmakespark/cmake/releases/download/v${CMAKESPARK_VERSION}/cmakespark.zip" "${CMAKESPARK_ARCHIVE}" SHOW_PROGRESS)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/buildsys/v${CMAKESPARK_VERSION}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar vxzf "${CMAKESPARK_ARCHIVE}"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/buildsys/v${CMAKESPARK_VERSION}"
    )
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/buildsys/v${CMAKESPARK_VERSION}")
include(CommonConfig)
```

## Typical project setup

A minimal CMake project looks like this:

```cmake
cmake_minimum_required(VERSION 3.16)
project(MyProject VERSION 1.2.3 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmakespark/src")
include(CommonConfig)
```

This applies the repository defaults, including:

- C++17 standard
- common warning flags
- Qt autodetection with `AUTOMOC`/`AUTOUIC`/`AUTORCC`
- CTest setup
- coverage and static-analysis support
- install/output directory configuration

## Creating a library

Use the `createlib()` macro to create a library target with standard install and package metadata.

```cmake
createlib(
    NAME MyLib
    NAMESPACE MyCompany
    VERSION 1.2.3
    SOURCES
        src/mylib.cpp
    PUBLIC_HEADERS
        include/mylib.h
    PRIVATE_HEADERS
        src/mylib_p.h
    PUBLIC_DEPS
        Qt6::Core
    PRIVATE_DEPS
        some_internal_library
    GENERATE_PACKAGE
)
```

### Arguments

- `NAME`: target name
- `NAMESPACE`: prefix used in the installed package target namespace; for example, `Qt5::Core` uses namespace `Qt5` and target `Core`
- `VERSION`: semver version such as `1.2.3`
- `SOURCES`: source files
- `PUBLIC_HEADERS`: headers exposed to consumers
- `PRIVATE_HEADERS`: private headers
- `PUBLIC_DEPS`: dependencies propagated to consumers
- `PRIVATE_DEPS`: dependencies used only internally
- `STATIC` / `SHARED`: optional explicit linker type
- `GENERATE_PACKAGE`: creates a relocatable CMake package for `find_package(...)`

If `GENERATE_PACKAGE` is enabled, the package is installed under a convention like:

```cmake
find_package(MyCompany1MyLib REQUIRED)
```

and the imported target name follows the pattern:

```cmake
MyCompany1::MyLib
```

## Creating an executable

Use `createapp()` for applications:

```cmake
createapp(
    NAME MyApp
    VERSION 1.2.3
    SOURCES
        src/main.cpp
    HEADERS
        include/app.h
    DEPS
        MyCompany1::MyLib
)
```

### Arguments

- `NAME`: executable target name
- `VERSION`: semver version
- `CONSOLE`: optional, forces a console subsystem on Windows when used
- `SOURCES`: source files
- `HEADERS`: headers for the project
- `DEPS`: linked targets
- `GENERATE_PACKAGE`: optional package generation for downstream consumption
- `REQUIRE_ADMINISTRATOR` / `UI_ACCESS`: optional Windows UAC settings

## Unit tests with Qt

The project provides a small test helper for Qt-based tests.

```cmake
include(AddQtTest)

add_qt_test(CarTest "tst_car.cpp")
target_link_libraries(CarTest PUBLIC MyCompany1::MyLib)
```

This creates an executable and registers it with CTest. When valgrind is available in a Debug build, the test is run under valgrind instead of directly.

To run the suite:

```bash
cmake --build . --target test
```

## Code coverage

Coverage is enabled through `CommonConfig` and the `CodeCoverage` helper.

```bash
cmake -DCODE_COVERAGE=ON .
```

Useful targets include:

- `coverage-report` – text summary per file
- `coverage-html` – HTML coverage report
- `coverage-check` – enforces a minimum coverage threshold via `MIN_COVERAGE`

Example:

```bash
cmake --build . --target coverage-report
```

The generated report is written to a coverage file and summarized in the build output.

## Static analysis and quality checks

The default setup also enables:

- `cppcheck`
- `valgrind` support for debug tests
- Doxygen documentation generation
- package export/install generation

## Versioning from Git tags

This project can derive a semantic version from the current Git state.

```cmake
set(VERSION_UPDATE_FROM_GIT TRUE)
```

Behavior:

- reads the latest Git tag
- appends the commit hash when appropriate
- writes a `VERSION` file in the project directory when needed
- falls back to the `VERSION` file if Git is unavailable

The helper supports labels such as `alpha`, `beta`, `rc`, and others using the semver encoding scheme described by the repository.

## Example workflow

```bash
git clone https://github.com/cmakespark/cmake.git
cd cmake
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

## Credits

This project builds on the ideas and patterns described by:

- https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/
