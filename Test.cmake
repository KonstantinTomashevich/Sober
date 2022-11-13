# Test.cmake contains macros, that help to setup service implementation agnostic tests as sober library and
# ctest executables. Macros are used instead of functions, because these module provides wrappers, that add test-related
# functionality, to library and variant setup functions.

include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Library.cmake)

# Every CMake executable must have at least one source translation unit. Sober service test runners
# do not have any, because they are used to represent variant library as executable.
set (SOBER_TEST_RUNNER_STUB_SOURCE "${CMAKE_CURRENT_LIST_DIR}/Stub.cpp")

# Wraps sober_library_begin, SERVICE_NAME must be equal to the name of service, that will be tested using these tests.
# Given service will be automatically used within private scope.
macro (sober_test_begin SERVICE_NAME)
    message (STATUS "Creating tests library for service \"${SERVICE_NAME}\".")
    set (SOBER_TEST_SERVICE_NAME "${SERVICE_NAME}")
    unset (SOBER_TEST_VARIANTS)

    sober_naming_test_collection ("${SERVICE_NAME}" COLLECTION_NAME)
    add_custom_target ("${COLLECTION_NAME}" COMMENT "Build all tests for ${SERVICE_NAME} service.")

    sober_naming_test_library ("${SERVICE_NAME}" LIBRARY_NAME)
    sober_library_begin ("${LIBRARY_NAME}" STATIC)
    sober_library_use_service (PER_VARIANT PRIVATE "${SERVICE_NAME}")
endmacro ()

# Wraps sober_library_end, generates and registers test runners for each registered test variant.
macro (sober_test_end)
    sober_library_end ()
    message (STATUS "Creating tests runners for \"${SOBER_TEST_SERVICE_NAME}\".")

    sober_naming_test_library ("${SOBER_TEST_SERVICE_NAME}" LIBRARY_NAME)
    sober_naming_test_collection ("${SOBER_TEST_SERVICE_NAME}" COLLECTION_NAME)

    foreach (VARIANT_NAME IN LISTS SOBER_TEST_VARIANTS)
        sober_naming_variant_target ("${LIBRARY_NAME}" "${VARIANT_NAME}" VARIANT_TARGET_NAME)
        sober_naming_test_runner ("${VARIANT_TARGET_NAME}" TEST_RUNNER_NAME)
        sober_naming_test_runner_ctest_name ("${VARIANT_TARGET_NAME}" TEST_RUNNER_CTEST_NAME)

        message (STATUS "    Creating tests runner \"${TEST_RUNNER_NAME}\" named as \"${TEST_RUNNER_CTEST_NAME}\".")
        add_executable ("${TEST_RUNNER_NAME}" "${SOBER_TEST_RUNNER_STUB_SOURCE}")
        target_link_libraries ("${TEST_RUNNER_NAME}" PUBLIC "${VARIANT_TARGET_NAME}")

        add_test (NAME "${TEST_RUNNER_CTEST_NAME}" COMMAND "${TEST_RUNNER_NAME}")
        add_dependencies ("${COLLECTION_NAME}" "${TEST_RUNNER_NAME}")
    endforeach ()

    message (STATUS "Testing configuration for service \"${SOBER_TEST_SERVICE_NAME}\" finished.")
    unset (SOBER_TEST_SERVICE_NAME)
endmacro ()

# Wraps sober_variant_begin, registers this variant as test variant, that tests implementation with name
# equal to IMPLEMENTATION_NAME. Given implementation will be automatically frozen for this variant.
macro (sober_test_variant_begin IMPLEMENTATION_NAME)
    sober_naming_test_variant ("${IMPLEMENTATION_NAME}" VARIANT_NAME)
    list (APPEND SOBER_TEST_VARIANTS "${VARIANT_NAME}")
    set (SOBER_TEST_VARIANTS ${SOBER_TEST_VARIANTS})

    sober_variant_begin ("${VARIANT_NAME}")
    sober_variant_freeze_implementation ("${SOBER_TEST_SERVICE_NAME}" "${IMPLEMENTATION_NAME}")
endmacro ()

# Wraps sober_variant_end, added for consistency.
macro (sober_test_variant_end)
    sober_variant_end ()
endmacro ()
