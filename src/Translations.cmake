
# 2. Find the dependency
find_package(Qt5Core QUIET)
find_package(Qt5LinguistTools QUIET)
if(Qt5Core_FOUND AND Qt5LinguistTools_FOUND)
    set(TRANSLATIONS_OUTPUT_DIR "${CMAKE_BINARY_DIR}/translations" CACHE STRING "Output directory to place translation files.")
    set(TRANSLATION_LOCALES "de;en;es;fr;it;nl;pl;pt;sv;hu" CACHE STRING "Locales to generate translation files for")
    
    message(STATUS "Qt5Linguist tools found: 'translate' build target will be created. Use this build target to generate the .TS and .QM files.")
    
    file(MAKE_DIRECTORY ${TRANSLATIONS_OUTPUT_DIR})

    set(TRANSLATION_OUTPUT_FILES "")
    foreach(LOCALE ${TRANSLATION_LOCALES})
        list(APPEND TRANSLATION_OUTPUT_FILES "${TRANSLATIONS_OUTPUT_DIR}/${LOCALE}.ts")
    endforeach()

    set_source_files_properties(${TRANSLATION_OUTPUT_FILES} PROPERTIES OUTPUT_LOCATION ${TRANSLATIONS_OUTPUT_DIR})

    # Generate TS and QM files
    # message(STATUS "TRANSLATION_OUTPUT_FILES: ${TRANSLATION_OUTPUT_FILES}")
    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TRANSLATION_OUTPUT_FILES} OPTIONS -no-obsolete)
    message(STATUS "QM_FILES: ${QM_FILES}")

    # Create build target
    add_custom_target(translate
#        COMMAND ${Qt5_LUPDATE_EXECUTABLE} . -ts ${TRANSLATION_OUTPUT_FILES} -no-obsolete
        DEPENDS ${QM_FILES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

    add_custom_target(translate-clean
        COMMAND ${CMAKE_COMMAND} -E remove ${QM_FILES})

endif(Qt5Core_FOUND AND Qt5LinguistTools_FOUND)
