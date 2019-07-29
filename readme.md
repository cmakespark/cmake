This repository contains very generic cmake components which can be used across other cmake projects.

# Including in your code.
The common cmake files need to be present when cmake is run.
There are various ways of achieving this.

## Git submodule
You can fetch the files during your git clone using a submodule.
```
git submodule add -b <tag> https://github.com/cmakespark/cmake.git path/to/cmakespark
```

## Cloning during cmake run
Add this snippet to your CMakeLists.txt
```
# Download build system
if(NOT EXISTS "${CMAKE_BINARY_DIR}/cmakespark/v2.0")
    message(STATUS "Downloading buildsystem...")

    find_package(Git REQUIRED)
    execute_process(COMMAND ${GIT_EXECUTABLE} clone --branch v2.0 https://github.com/cmakespark/cmake.git ${CMAKE_BINARY_DIR}/cmakespark/v2.0)
endif()
list(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/cmakespark/v2.0")
```

# Usage

You can include these files in your CMakeLists.txt
```
# Include common cmake modules
include(CommonConfig)
```

## Create a library

```
createlib(NAME <name> [STATIC|SHARED|<none>]
    NAMESPACE <namespace>
    VERSION <version>
    SOURCES ${SOURCES}
    PUBLIC_HEADERS ${PUBLIC_HEADERS}
    PRIVATE_HEADERS ${PRIVATE_HEADERS}
    PUBLIC_DEPS ${PUBLIC_DEPS}
    PRIVATE_DEPS ${PRIVATE_DEPS}
    GENERATE_PACKAGE)
```
NAME: name of the library  
NAMESPACE: Prefix added to the name of the library. (eg Qt5Core: Qt is the namespace, 5 if the major version and Core is the name of the library)  
LINKING: Can be explicit (static or shared). If omitted, it will depend on the value of the ```BUILD_SHARED_LIBS``` variable.  
VERSION: semver formatted version of the library. (eg. 1.0.0)  
SOURCES: List of source files to be compiled.  
PUBLIC_HEADERS: List of headers which can be included from the library.  
PRIVATE_HEADERS: List of headers which are private to the library and are not exposed.  
PUBLIC_DEPS: Dependencies of this library which are exposed to the users of this library  
PRIVATE_DEPS: Dependencies of this library which are not exposed to the users of this library  
GENERATE_PACKAGE: (optional) If added, a relocatable cmake package is generated to allow the library to be used outside this cmake tree.

## Create an executable

```
createapp(NAME <name>
    VERSION <version>
    [CONSOLE]
    SOURCES ${SOURCES}
    HEADERS ${HEADERS}
    DEPS <dependencies>)
```
NAME: name of the executable  
VERSION: semver formatted version of the executable. (eg. 1.0.0)  
CONSOLE: (optional) If added, the executable is build as a console applicatie. If omitted, it will be a GUI application (windows)  
SOURCES: List of source files to be compiled.  
HEADERS: List of headers to be used  
DEPS: List of dependent libraries of this application.  

## More options

### Unit tests

You can add unit tests (using QtTest) by adding this snippet to your CMakeLists.txt:

```
# CarTest
add_qt_test(CarTest "tst_car.cpp")
target_link_libraries(CarTest PUBLIC CC2::QComplexLib)

```

To execute all tests in the project, run this command:

```
cmake --build . --target test
```

### Code coverage

As an extra, code coverage can be calculated by adding the COVERAGE option to the CMAKE command.
```
cmake -DCOVERAGE=ON path/to/source
```

There are 2 extra targets:
- coverage-report: a textual report which produces an output per file.
- coverage-html: a series of HTML files which produce a report per file showing each covered line.

Example:
```
cmake --build . --target coverage-report
[1/1] Running utility command for coverage-report
Reading tracefile coverage.info
                                |Lines       |Functions  |Branches    
Filename                        |Rate     Num|Rate    Num|Rate     Num
======================================================================
[/home/frederik/cmakespark/examples/complexlib/]
QComplexLib/src/qcar.cpp        | 100%     19|85.7%     7|    -      0
QComplexLib/src/qcar.h          | 100%      1| 100%     2|    -      0
QComplexLib/src/qcar_p.h        | 100%      1| 100%     1|    -      0
complexlib/src/car.cpp          | 100%     16| 100%     6|    -      0
======================================================================
                          Total:| 100%     37|93.8%    16|    -      0
Reading tracefile coverage.info
Summary coverage rate:
  lines......: 100.0% (37 of 37 lines)
  functions..: 93.8% (15 of 16 functions)
  branches...: no data found
```

This buildsys also allows to:
- Run unit tests
- Run valgrind on unit tests
- Create archive of installed files
- Create arbitrary archive
- Run cppcheck
- Run code coverage (lcov)


## Retrieve project version git

This section explains how to read out the semantic version (https://semver.org/spec/v2.0.0.html) from a git commit.

To enable, add the following snippet to your CMakeLists.txt:

```cmake
set(VERSION_UPDATE_FROM_GIT TRUE)
```
This will retrieve the latest git tag and adds the commit hash.
Additionally, this will write a file `VERSION` in the `CMakeLists.txt`s directory.

In case the git executable is not found on the current machine, it will read the version from the `VERSION` file.
Note that the early first build requires a VERSION file if git is not installed.

The label string and its version (e.g. "RC.2" in v2.3.1-RC.2+21.ef12c8) are encoded as the fourth number of the version.
This number is equal to the sum of
- the encoded string (from the example: RC) cypher
    - pre or pre-alpha: 1000 (only for development)
    - alpha: 2000 (first software testing phase)
    - beta: 3000 (feature complete, possible bugs)
    - rc: 9000 (going silver, best beta release, could become final release)
- its version number (from the example: 2).

An unknown string will result in 5000 and is not recommended.
More info over the possible strings can be found here https://en.wikipedia.org/wiki/Software_release_life_cycle#Release_candidate.

For example, the semantic version 2.3.1-RC.2 will be converted to `2.3.1.2002`.
