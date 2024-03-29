# Naming.cmake contains common naming patterns for any generated entity, which can be created or used by more than
# one script module (including Sober modules), for example target names and build option names. This allows to
# change common naming patterns for all Sober shared entities without correcting these names in all Sober modules.

include_guard (GLOBAL)
set (SOBER_BASE_LIBRARY_SUFFIX "Base")

function (sober_naming_service_target SERVICE_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${SERVICE_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_implementation_target SERVICE_NAME IMPLEMENTATION_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${SERVICE_NAME}${IMPLEMENTATION_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_library_base_target LIBRARY_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}" PARENT_SCOPE)
endfunction ()

function (sober_naming_variant_target LIBRARY_NAME VARIANT_NAME OUTPUT_VARIABLE)
    if (VARIANT_NAME STREQUAL SOBER_BASE_LIBRARY_SUFFIX)
        message (FATAL_ERROR "Sober: can not use variant name \"${VARIANT_NAME}\", because it's reserved suffix!")
    endif ()

    set ("${OUTPUT_VARIABLE}" "${LIBRARY_NAME}${VARIANT_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_test_library SERVICE_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "Test${SERVICE_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_test_variant IMPLEMENTATION_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${IMPLEMENTATION_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_test_runner VARIANT_TARGET_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${VARIANT_TARGET_NAME}TestRunner" PARENT_SCOPE)
endfunction ()

function (sober_naming_test_collection SERVICE_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${SERVICE_NAME}Tests" PARENT_SCOPE)
endfunction ()

function (sober_naming_test_runner_ctest_name VARIANT_TARGET_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${VARIANT_TARGET_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_library_variable LIBRARY_NAME VARIABLE_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "SOBER_${LIBRARY_NAME}_${VARIABLE_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_naming_variant_variable LIBRARY_NAME VARIANT_NAME VARIABLE_NAME OUTPUT_VARIABLE)
    sober_naming_library_variable ("${LIBRARY_NAME}" "${VARIANT_NAME}_${VARIABLE_NAME}" "${OUTPUT_VARIABLE}")
    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()

# Generates name for variable, that stores service selected implementation for given library variant.
# Checked only if service usage mode is PER_VARIANT (see sober_library_use_service command).
# This naming pattern is added as global, because this variable could be passed as build option.
function (sober_naming_selected_implementation_variable LIBRARY_NAME VARIANT_NAME SERVICE_NAME OUTPUT_VARIABLE)
    sober_naming_variant_variable (
            "${LIBRARY_NAME}" "${VARIANT_NAME}" "${SERVICE_NAME}_SELECTED_IMPLEMENTATION" "${OUTPUT_VARIABLE}")

    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()

# Generates name for variable, that stores service selected implementation for all variants of given library.
# Checked only if service usage mode is SHARED (see sober_library_use_service command).
# This naming pattern is added as global, because this variable could be passed as build option.
function (sober_naming_selected_shared_implementation_variable LIBRARY_NAME SERVICE_NAME OUTPUT_VARIABLE)
    sober_naming_library_variable (
            "${LIBRARY_NAME}" "${SERVICE_NAME}_SELECTED_SHARED_IMPLEMENTATION" "${OUTPUT_VARIABLE}")

    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()
