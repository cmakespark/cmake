set(SOURCES
    AddQtTest.cmake
    config.cmake.in
    Doxyfile.in
    FindGcov.cmake
    GetGitRevisionDescription.cmake
    Methods.cmake
    SetOutputDir.cmake
    AddResourceInfo.cmake
    CodeCoverage.cmake
    Cppcheck.cmake
    Doxygen.cmake
    FindGcovr.cmake
    GetGitRevisionDescription.cmake.in
    GetVersionFromGitTag.cmake
    Package.cmake
    Translations.cmake
    CommonConfig.cmake
    DefineProject.cmake
    doxygen_custom.css
    FindLcov.cmake
    CompilerFlags.cmake
    DeployDependentLibraries.cmake
    FindCppcheck.cmake
    GeneratePackage.cmake
    manifest/AddManifest.cmake
    manifest/dll.manifest.in
    manifest/exe.manifest.in
    resource.rc.in
    coverage-check.sh)

add_custom_target(cmakespark ALL
    COMMAND ${CMAKE_COMMAND} -E tar cf ${CMAKE_BINARY_DIR}/cmakespark.zip --format=zip -- ${SOURCES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    SOURCES ${SOURCES})
