include_guard (GLOBAL)
set (SOBER_BASE_LIBRARY_SUFFIX "Base")

function (sober_internal_get_service_target_name SERVICE_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${SERVICE_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_implementation_target_name SERVICE_NAME IMPLEMENTATION_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${SERVICE_NAME}${IMPLEMENTATION_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_library_base_target_name LIBRARY_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "${LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_variant_target_name LIBRARY_NAME VARIANT_NAME OUTPUT_VARIABLE)
    if (VARIANT_NAME STREQUAL SOBER_BASE_LIBRARY_SUFFIX)
        message (FATAL_ERROR "Sober: can not use variant name \"${VARIANT_NAME}\", because it's reserved suffix!")
    endif ()

    set ("${OUTPUT_VARIABLE}" "${LIBRARY_NAME}${VARIANT_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_library_variable_name LIBRARY_NAME VARIABLE_NAME OUTPUT_VARIABLE)
    set ("${OUTPUT_VARIABLE}" "SOBER_${LIBRARY_NAME}_${VARIABLE_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_service_usage_scope_variable_name LIBRARY_NAME SERVICE_NAME OUTPUT_VARIABLE)
    sober_internal_get_library_variable_name ("${LIBRARY_NAME}" "${SERVICE_NAME}_SCOPE" "${OUTPUT_VARIABLE}")
    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_variant_variable_name LIBRARY_NAME VARIANT_NAME VARIABLE_NAME OUTPUT_VARIABLE)
    sober_internal_get_library_variable_name ("${LIBRARY_NAME}" "${VARIANT_NAME}_${VARIABLE_NAME}" "${OUTPUT_VARIABLE}")
    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_selected_implementation_variable_name
          LIBRARY_NAME VARIANT_NAME SERVICE_NAME OUTPUT_VARIABLE)

    sober_internal_get_variant_variable_name (
            "${LIBRARY_NAME}" "${VARIANT_NAME}" "${SERVICE_NAME}_SELECTED_IMPLEMENTATION" "${OUTPUT_VARIABLE}")

    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()