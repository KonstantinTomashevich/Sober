include_guard (GLOBAL)
set (SOBER_BASE_LIBRARY_SUFFIX "Base")

function (sober_internal_get_service_target_name SERVICE_NAME OUTPUT_VARIABLE)
    set (${OUTPUT_VARIABLE} "${SERVICE_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_implementation_target_name SERVICE_NAME IMPLEMENTATION_NAME OUTPUT_VARIABLE)
    set (${OUTPUT_VARIABLE} "${SERVICE_NAME}${IMPLEMENTATION_NAME}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_library_base_target_name LIBRARY_NAME OUTPUT_VARIABLE)
    set (${OUTPUT_VARIABLE} "${LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}" PARENT_SCOPE)
endfunction ()

function (sober_internal_get_variant_target_name LIBRARY_NAME VARIANT_NAME OUTPUT_VARIABLE)
    if (VARIANT_NAME STREQUAL SOBER_BASE_LIBRARY_SUFFIX)
        message (FATAL_ERROR "Sober: can not use variant name \"${VARIANT_NAME}\", because it's reserved suffix!")
    endif ()

    set (${OUTPUT_VARIABLE} "${LIBRARY_NAME}${VARIANT_NAME}" PARENT_SCOPE)
endfunction ()