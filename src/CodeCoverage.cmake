# Enable Code Coverage
#
# USAGE:
# 1. If there are any special files you want to exclude from
#    code coverage, set CODE_COVERAGE_EXCLUDES accordingly:
#      list(APPEND "*/FileToExclude.cpp" "*/FolderToExclude/*")
#
# 2. If you don't want the standard excluded files:
#      set(CODE_COVERAGE_NO_DEFAULT_EXCLUDES 1)
#
# 3. Add the following line to your CMakeLists.txt:
#      INCLUDE(CodeCoverage)
#
# 4. Build a Debug build:
#    Add the following option: -DCODE_COVERAGE=True
#
# 5. Run the application(s) where you want to analyse the coverage
#
# 6. Generate the report by calling one of these targets:
#    - coverage-report (string table output)
#    - coverage-html (HTML format)
#
# Requirements: gcov and gcovr

if(NOT CODE_COVERAGE_NO_DEFAULT_EXCLUDES)
    list(APPEND CODE_COVERAGE_EXCLUDES
        "*moc_*"
        "*.moc"
        "*tst_*"
        "*test_*"
        "*tests*"
        "*qrc_*"
        "*ui_*.h"
        "*catch.hpp"
        "*fakeit.hpp"
        "*contract.cpp"
    )
endif()

option(CODE_COVERAGE "Code coverage" OFF)
if(CODE_COVERAGE)
    if(NOT CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        message(FATAL "Compiler is not GNU gcc or Clang! Code coverage not possible.")
    elseif( NOT CMAKE_BUILD_TYPE STREQUAL "Debug" )
        message(FATAL "Code coverage results with an optimized (non-Debug) build may be misleading. Code coverage will not run." )
    else()
        find_package(Gcov REQUIRED)
        find_package(Lcov REQUIRED)
    endif()

    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/coverage)

    if(WIN32)
        set(LCOV_REDIRECT ">NUL")
    else()
        set(LCOV_REDIRECT "2>/dev/null")
    endif()

    set(COVERAGE_FILE ${CMAKE_BINARY_DIR}/coverage.info)

    add_custom_target("coverage-report")
    add_custom_command(TARGET "coverage-report"
        COMMAND ${LCOV_EXECUTABLE} --quiet --capture --directory . --base-directory ${CMAKE_SOURCE_DIR} --no-external -o ${COVERAGE_FILE} ${LCOV_REDIRECT}
        COMMAND ${LCOV_EXECUTABLE} --quiet --remove ${COVERAGE_FILE} ${CODE_COVERAGE_EXCLUDES} -o ${COVERAGE_FILE}
        COMMAND ${LCOV_EXECUTABLE} --list ${COVERAGE_FILE}
        COMMAND ${LCOV_EXECUTABLE} --summary ${COVERAGE_FILE}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Create code coverage report")

    add_custom_target("coverage-html" DEPENDS "coverage-report")
    add_custom_command(TARGET "coverage-html"
        COMMAND ${GENHTML_EXECUTABLE} ${COVERAGE_FILE} --show-details -o coverage
        COMMAND ${CMAKE_COMMAND} -E tar cf CodeCoverage.zip --format=zip -- coverage
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Create code coverage html report"
        VERBATIM)

    set(MIN_COVERAGE "0" CACHE STRING "Minimum required coverage")

    add_custom_target(coverage-check DEPENDS coverage-report)
    add_custom_command(TARGET coverage-check
        COMMAND bash ${CMAKE_CURRENT_LIST_DIR}/coverage-check.sh ${MIN_COVERAGE}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Check code coverage"
        VERBATIM)

endif(CODE_COVERAGE)
