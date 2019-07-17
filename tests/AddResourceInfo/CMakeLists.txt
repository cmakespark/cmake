# Test for macro encode_semantic_version_label() from AddResourceInfo.cmake
# Check all expected values respectively to the input strings
# 'GOOD' values will succeed without returning any message in the console
# 'BAD' values will also succeed but will send a warning in the console (they can be ignored here)

message(STATUS "---- START ENCODE_SEMANTIC_VERSION_LABEL TEST")
set(INPUT_TWEAK_VERSION_STRINGS
    # GOOD
    pre.100
    pre-alpha.001
    alpha.123
    beta.456
    rc.789

    # BAD
    500
    1000
    alpha
    foo
    bar.1
    dummy.1001
)

set(EXPECTED_TWEAK_VERSION_VALUES
    # GOOD
    1100
    1001
    2123
    3456
    9789

    # BAD
    500
    0
    2000
    5000
    5001
    5000
)

list(LENGTH INPUT_TWEAK_VERSION_STRINGS NBR_OF_INPUTS)
list(LENGTH EXPECTED_TWEAK_VERSION_VALUES NBR_OF_EXPECTED_VALUES)
if (NOT (NBR_OF_INPUTS EQUAL NBR_OF_EXPECTED_VALUES))
    message(FATAL_ERROR "Their should be an equal number of input strings and expected values")
endif()

math(EXPR SIZE "${NBR_OF_INPUTS} - 1")
foreach(TEST_NBR RANGE ${SIZE})
    # INPUTS
    list(GET INPUT_TWEAK_VERSION_STRINGS ${TEST_NBR} INPUT)
    list(GET EXPECTED_TWEAK_VERSION_VALUES ${TEST_NBR} EXPECTED)

    # UUT
    encode_semantic_version_label(${INPUT} ACTUAL)

    # CHECK
    if(EXPECTED EQUAL ACTUAL)
        message(STATUS "PASS: input tweak version: ${INPUT}")
    else()
        message(SEND_ERROR "FAILED: input tweak version: ${INPUT}, EXPECTED ${EXPECTED} but got ${ACTUAL}")
    endif()
endforeach()

message(STATUS "---- END ENCODE_SEMANTIC_VERSION_LABEL TEST")
