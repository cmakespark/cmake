
# 2. Find the dependency
find_package(Qt5LinguistTools QUIET)
if(Qt5LinguistTools_FOUND)
    set(TRANSLATIONS_OUTPUT_DIR "${CMAKE_BINARY_DIR}/translations" CACHE STRING "Output directory to place translation files.")
    set(TRANSLATION_LOCALES "de;en;es;fr;it;nl;pl;pt;sv;hu" CACHE STRING "Locales to generate translation files for")
    
    message(STATUS "Qt5Linguist tools found: 'translate' build target will be created. Use this build target to generate the .TS and .QM files.")
    
    file(MAKE_DIRECTORY ${TRANSLATIONS_OUTPUT_DIR})

    set(TRANSLATION_OUTPUT_FILES "")
    foreach(LOCALE ${TRANSLATION_LOCALES})
        list(APPEND TRANSLATION_OUTPUT_FILES "${TRANSLATIONS_OUTPUT_DIR}/${LOCALE}.ts")
    endforeach()

    # Generate TS and QM files
    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TRANSLATION_OUTPUT_FILES})

    # Create build target
    add_custom_target(translate DEPENDS ${QM_FILES})
endif(Qt5LinguistTools_FOUND)
