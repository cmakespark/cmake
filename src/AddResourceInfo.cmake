#CMAKE_CURRENT_LIST_DIR is the directory containing this file when
#referenced here, at top-level scope, when this file is included.
#From within a macro, CMAKE_CURRENT_LIST_DIR is the directory that
#contains the file being processed and invoking the function.  So,
#to use this files directory within a macro, we need to save it at
#top level scope at include time.
set(THIS_FILE_DIR ${CMAKE_CURRENT_LIST_DIR})

#This macro calculates the encoded number for the 'tweak' verson string from a semantic version label
#The tweak version string is defined by a label string and its version (e.g. "RC.2" in v2.3.1-RC.2+21.ef12c8)
#The strings are encoded as 1 cypher:
#  - pre or pre-alpha: 1
#  - alpha: 2
#  - beta: 3
#  - rc: 9
#Otherwise the cypher is 5, and a warning is sent
#
#The encoded number is equal to the `encoded string cypher * 1000 + label version number`
#
#Note: the label version number cannot be bigger than 3 digits, otherwise it will be set to zero
#
#Parameters:
#TWEAK_VERSION_STRING[in] - case insensitive tweak version string (e.g. RC.2, alpha.193, beta.23, alpha, 456)
#ENCODED_NUMBER[out] - the calculated encoded number with maximum of 4 digits (e.g. respectively: 9002, 1193, 3023, 1000, 456
macro(encode_semantic_version_label TWEAK_VERSION_STRING ENCODED_NUMBER)
    set(TWEAK_VERSION_STRING "${TWEAK_VERSION_STRING}")  # make empty string if not defined
    if(TWEAK_VERSION_STRING STREQUAL "")
        set(SUM 0)
    else()
        # Parse the string part at the beginning, if any
        string(REGEX MATCH "^[-a-zA-Z]+" LABEL_STR ${TWEAK_VERSION_STRING})

        if(NOT CMAKE_MATCH_0)
            set(STRING_VALUE 0)
        else()
            string(TOLOWER ${LABEL_STR} ${LABEL_STR})

            string(COMPARE EQUAL "pre" ${LABEL_STR} LABEL_STR_PRE)
            string(COMPARE EQUAL "pre-alpha" ${LABEL_STR} LABEL_STR_PRE_ALPHA)
            string(COMPARE EQUAL "alpha" ${LABEL_STR} LABEL_STR_ALPHA)
            string(COMPARE EQUAL "beta" ${LABEL_STR} LABEL_STR_BETA)
            string(COMPARE EQUAL "rc" ${LABEL_STR} LABEL_STR_RC)

            if(LABEL_STR_PRE OR LABEL_STR_PRE_ALPHA)
                set(STRING_VALUE 1)
            elseif(LABEL_STR_ALPHA)
                set(STRING_VALUE 2)
            elseif(LABEL_STR_BETA)
                set(STRING_VALUE 3)
            elseif(LABEL_STR_RC)
                set(STRING_VALUE 9)
            else()
                message(WARNING "Unknown tweak version label '${LABEL_STR}', either update the git tag or process this new label.")
                set(STRING_VALUE 5)  # set to mid value, to avoid burning
            endif()
        endif()

        # Parse the version part at the end, if any
        string(REGEX MATCH "[0-9]+$" LABEL_VERSION ${TWEAK_VERSION_STRING})

        if(NOT CMAKE_MATCH_0)
            set(LABEL_VERSION 0)
        endif()
        if(LABEL_VERSION GREATER 999)
            set(LABEL_VERSION 0)
        endif()

        MATH(EXPR SUM "${STRING_VALUE}*1000+${LABEL_VERSION}")

    endif()

    # Set output parameter
    set(${ENCODED_NUMBER} ${SUM})
endmacro()

#This macro (currently Windows-only) creates a .RC file that holds all of the application/library's file details. This RC
#file is then appended to the source list for the target.
#
#Parameters:
#PROJECT - The filename of the project (without extension)
#ISLIBRARY - Boolean. If true, this target is a library. If false, it is an application.
#FILE_VER_MAJOR FILE_VER_MINOR FILE_VER_PATCH - Version
#FILE_DESC - Description of the application/library
#FILE_NAME - The full name of the application/library
#RC_APPEND_LIST_NAME - The name of the list to append the RC file to
macro(add_resource_info PROJECT ISLIBRARY FILE_VER_MAJOR FILE_VER_MINOR FILE_VER_PATCH FILE_DESC FILE_NAME RC_APPEND_LIST_NAME)
#If we are creating an RC file for a library, make sure it is a DLL and not a static one. If it's an application, no need to do this check.
set(ISSHAREDLIBRARY FALSE)
if (DEFINED BUILD_SHARED_LIBS)
    set(ISSHAREDLIBRARY ${BUILD_SHARED_LIBS})
endif()

set(IS_APPLICABLE_RESOURCE (NOT ${ISLIBRARY} OR (${ISSHAREDLIBRARY} AND ${ISLIBRARY})))


if(WIN32 AND NOT UNIX AND ${IS_APPLICABLE_RESOURCE})
    message(STATUS "Resource info will be added for ${PROJECT}")
    if(NOT CMAKE_BUILD_TYPE MATCHES Debug)
        # Finish creating the relevant data for the RC file.
        get_git_head_revision(GIT_REFSPEC GIT_COMMIT_HASH)
    endif()

    string(TIMESTAMP CURRENT_YEAR "%Y")
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(ARCHITECTURE_DESC "32-bit")
    else()
        set(ARCHITECTURE_DESC "64-bit")
    endif()
    set(FILEATTR_YEAR_RELEASE ${CURRENT_YEAR})
    set(FILE_DESC "${FILE_DESC} (${ARCHITECTURE_DESC})")
    if(ISLIBRARY)
        set(FILEATTR_ORIGINAL_NAME "${PROJECT}.dll ${GIT_COMMIT_HASH}")
    else()
        set(FILEATTR_ORIGINAL_NAME "${PROJECT}.exe ${GIT_COMMIT_HASH}")
    endif()
    
    # The RC file needs explicit variables (as defined in set() statements), because we can't reference macro parameters.
    # Set these as independent variables so that replacement will happen upon calling configure_file()
    if(${CMAKE_PROJECT_NAME}_VERSION_STRING)
        set(PRODUCT_VER_MAJOR ${${CMAKE_PROJECT_NAME}_VERSION_MAJOR})
        set(PRODUCT_VER_MINOR ${${CMAKE_PROJECT_NAME}_VERSION_MINOR})
        set(PRODUCT_VER_PATCH ${${CMAKE_PROJECT_NAME}_VERSION_PATCH})

        encode_semantic_version_label("${${CMAKE_PROJECT_NAME}_VERSION_TWEAK}" PRODUCT_VER_EXTRA)
    else()
        set(PRODUCT_VER_MAJOR ${FILE_VER_MAJOR})
        set(PRODUCT_VER_MINOR ${FILE_VER_MINOR})
        set(PRODUCT_VER_PATCH ${FILE_VER_PATCH})
        set(PRODUCT_VER_EXTRA 0)
    endif()
    set(FILEATTR_VER_MAJOR ${FILE_VER_MAJOR})
    set(FILEATTR_VER_MINOR ${FILE_VER_MINOR})
    set(FILEATTR_VER_PATCH ${FILE_VER_PATCH})
    set(FILEATTR_DESC ${FILE_DESC})
    set(FILEATTR_NAME ${FILE_NAME})
    
    if(CMAKE_COMPILER_IS_MINGW)
        # First we will try to filter out the mingw bin directory using some list operations
        # Make a list
        STRING(REPLACE "/" ";" QT_LIB_DIR_LIST ${QT_LIBRARY_DIR})
        # Remove the last item
        LIST(REMOVE_ITEM QT_LIB_DIR_LIST "lib")
        # Get the length of the list and the last element
        LIST(LENGTH QT_LIB_DIR_LIST len)
        MATH(EXPR previous "${len}-1")
        LIST(GET QT_LIB_DIR_LIST ${previous} MINGW)

        # add resource.o to the source list of the dll or exe
        list(APPEND ${RC_APPEND_LIST_NAME} ${CMAKE_CURRENT_BINARY_DIR}/resource.o)

        # fill in the appropriate information into resource.rc
        configure_file(${THIS_FILE_DIR}/resource.rc.in ${CMAKE_CURRENT_BINARY_DIR}/resource.rc)

        # specify how to convert resource.rc into resource.o, using windres.exe
        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/resource.o
            COMMAND ${QT_LIBRARY_DIR}/../../../Tools/${MINGW}/bin/windres.exe -i resource.rc -o resource.o
            WORKING_DIRECTORY  ${CMAKE_CURRENT_BINARY_DIR}
            DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/resource.rc
        )
        # More info:
        # * http://www.transmissionzero.co.uk/computing/building-dlls-with-mingw/
        #   section "Adding Version Information and Comments to your DLL"
        # * http://msdn.microsoft.com/en-us/library/aa381058.aspx
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")

        # add resource.rc to the source list of the dll or exe
        list(APPEND ${RC_APPEND_LIST_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}_resource.rc)

        # fill in the appropriate information into resource.rc
        configure_file(${THIS_FILE_DIR}/resource.rc.in ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}_resource.rc)
    endif()
endif(WIN32 AND NOT UNIX AND ${IS_APPLICABLE_RESOURCE})
endmacro()

