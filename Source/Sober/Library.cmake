include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)

function (sober_library_begin LIBRARY_NAME LIBRARY_TYPE)
    message (STATUS "Library \"${LIBRARY_NAME}\" configuration started.")
    message (STATUS "    Type: ${LIBRARY_TYPE}.")

    set (SOBER_LIBRARY_NAME "${LIBRARY_NAME}" PARENT_SCOPE)
    set (SOBER_LIBRARY_TYPE "${LIBRARY_TYPE}" PARENT_SCOPE)

    unset (SOBER_USED_SERVICES PARENT_SCOPE)
    unset (SOBER_LIBRARY_SOURCES PARENT_SCOPE)
    unset (SOBER_UNABLE_TO_USE_LINK_VARIANTS PARENT_SCOPE)

    unset (SOBER_LIBRARY_PUBLIC_INCLUDES PARENT_SCOPE)
    unset (SOBER_LIBRARY_PRIVATE_INCLUDES PARENT_SCOPE)
    unset (SOBER_LIBRARY_INTERFACE_INCLUDES PARENT_SCOPE)
    unset (SOBER_VARIANT_CONFIGURATION_STARTED PARENT_SCOPE)
endfunction ()

function (sober_library_use_service SERVICE_NAME)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to add service usage after variants configuration!")
    endif ()

    sober_internal_get_service_target_name ("${SERVICE_NAME}" SERVICE_TARGET)
    if (NOT TARGET ${SERVICE_TARGET})
        message (FATAL_ERROR "Sober: service \"${SERVICE_NAME}\" is not found!")
    endif ()

    list (FIND SOBER_USED_SERVICES ${SERVICE_NAME} FOUND_INDEX)
    if (FOUND_INDEX EQUAL -1)
        get_property (USES_IMPLEMENTATION_HEADERS TARGET ${SERVICE_TARGET}
                      PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

        if (USES_IMPLEMENTATION_HEADERS)
            set (SOBER_UNABLE_TO_USE_LINK_VARIANTS TRUE PARENT_SCOPE)
        endif ()

        list (APPEND SOBER_USED_SERVICES ${SERVICE_NAME})
        set (SOBER_USED_SERVICES ${SOBER_USED_SERVICES} PARENT_SCOPE)
        message (STATUS "    Uses service \"${SERVICE_NAME}\".")
    else ()
        message (WARNING "Sober: service \"${SERVICE_NAME}\" is already used by library \"${SOBER_LIBRARY_NAME}\"!")
    endif ()
endfunction ()

function (sober_library_set_sources LIBRARY_SOURCES)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to set library sources after variants configuration!")
    endif ()

    set (SOBER_LIBRARY_SOURCES ${LIBRARY_SOURCES} PARENT_SCOPE)
endfunction ()

function (sober_library_include_directories INCLUDE_SCOPE INCLUDE_DIRECTORIES)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to add library include directories after variants configuration!")
    endif ()

    if ("${INCLUDE_SCOPE}" STREQUAL "PUBLIC" OR
        "${INCLUDE_SCOPE}" STREQUAL "PRIVATE" OR
        "${INCLUDE_SCOPE}" STREQUAL "INTERFACE")

        list (APPEND SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES ${INCLUDE_DIRECTORIES})
        set (SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES
             ${SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES} PARENT_SCOPE)
    else ()
        message (SEND_ERROR "Sober: caught unknown include scope \"${INCLUDE_SCOPE}\"!")
    endif ()
endfunction ()

function (sober_variant_begin VARIANT_NAME)
    set (SOBER_VARIANT_CONFIGURATION_STARTED TRUE PARENT_SCOPE)
    set (SOBER_VARIANT_NAME ${VARIANT_NAME} PARENT_SCOPE)

    sober_internal_get_variant_target_name ("${SOBER_LIBRARY_NAME}" "${VARIANT_NAME}" SOBER_VARIANT_TARGET)
    set (SOBER_VARIANT_TARGET "${SOBER_VARIANT_TARGET}" PARENT_SCOPE)
    message (STATUS "    Variant \"${VARIANT_NAME}\" configuration started.")
endfunction ()

function (sober_variant_set_default_implementation SERVICE_NAME DEFAULT_IMPLEMENTATION)
    set (SOBER_${SOBER_VARIANT_TARGET}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION
         ${DEFAULT_IMPLEMENTATION} CACHE STRING)
endfunction ()

function (sober_variant_freeze_implementation SERVICE_NAME CONSTANT_IMPLEMENTATION)
    set (SOBER_${SOBER_VARIANT_TARGET}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION ${CONSTANT_IMPLEMENTATION})
endfunction ()

function (sober_library_internal_add_base_includes TARGET)
    target_include_directories ("${TARGET}" PUBLIC ${SOBER_LIBRARY_PUBLIC_INCLUDES})
    target_include_directories ("${TARGET}" PRIVATE ${SOBER_LIBRARY_PRIVATE_INCLUDES})
    target_include_directories ("${TARGET}" INTERFACE ${SOBER_LIBRARY_INTERFACE_INCLUDES})
endfunction ()

function (sober_variant_end)
    foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
        if (NOT DEFINED SOBER_${SOBER_VARIANT_TARGET}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION)
            sober_internal_get_service_target_name ("${SERVICE_NAME}" SERVICE_TARGET)
            get_property (IMPLEMENTATION TARGET ${SERVICE_TARGET} PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION)
            set (SOBER_${SOBER_VARIANT_TARGET}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION ${IMPLEMENTATION})
        endif ()

        set (SERVICE_IMPLEMENTATION "${SOBER_${SOBER_VARIANT_TARGET}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION}")
        sober_internal_get_implementation_target_name (
                "${SERVICE_NAME}" "${SERVICE_IMPLEMENTATION}" IMPLEMENTATION_TARGET)

        # TODO: Target name convention ServiceName..ServiceImplementation is hardcoded everywhere. Refactor?
        if (TARGET "${IMPLEMENTATION_TARGET}")
            message (STATUS "        \"${SERVICE_NAME}\" implementation: \"${SERVICE_IMPLEMENTATION}\".")
        else ()
            message (SEND_ERROR
                     "Sober: service \"${SERVICE_NAME}\" implementation \"${SERVICE_IMPLEMENTATION}\" not found!")
        endif ()
    endforeach ()
    
    if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
        add_library ("${SOBER_VARIANT_TARGET}" "${SOBER_LIBRARY_TYPE}" ${SOBER_LIBRARY_SOURCES})
        sober_library_internal_add_base_includes ("${SOBER_VARIANT_TARGET}")
        # TODO: Ability to select api include type (INTERFACE, PUBLIC, PRIVATE)?
        set (SERVICE_LINK_TYPE "PUBLIC")
    else ()
        add_library ("${SOBER_VARIANT_TARGET}" INTERFACE)
        set (SERVICE_LINK_TYPE "INTERFACE")
        sober_internal_get_library_base_target_name ("${SOBER_LIBRARY_NAME}" BASE_LIBRARY_TARGET)
        target_link_libraries ("${SOBER_VARIANT_TARGET}" ${SERVICE_LINK_TYPE} "${BASE_LIBRARY_TARGET}")
    endif ()

    foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
        sober_internal_get_implementation_target_name (
                "${SERVICE_NAME}" "${SOBER_${SOBER_VARIANT_TARGET}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION}"
                IMPLEMENTATION_TARGET)
        target_link_libraries (${SOBER_VARIANT_TARGET} ${SERVICE_LINK_TYPE} "${IMPLEMENTATION_TARGET}")
    endforeach ()

    message (STATUS "    Variant \"${SOBER_VARIANT_NAME}\" configuration finished.")
    unset (SOBER_VARIANT_NAME PARENT_SCOPE)
    unset (SOBER_VARIANT_TARGET PARENT_SCOPE)
endfunction ()

function (sober_library_end)
    if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
        message (STATUS
                 "    Forced to compile variants separately because several services use implementation headers:")

        foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
            sober_internal_get_service_target_name ("${SERVICE_NAME}" SERVICE_TARGET)
            get_property (USES_IMPLEMENTATION_HEADERS TARGET ${SERVICE_TARGET}
                          PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

            if (USES_IMPLEMENTATION_HEADERS)
                message (STATUS "        ${SERVICE_NAME}")
            endif ()
        endforeach ()
    else ()
        sober_internal_get_library_base_target_name ("${SOBER_LIBRARY_NAME}" BASE_LIBRARY_TARGET)
        add_library ("${BASE_LIBRARY_TARGET}" "${SOBER_LIBRARY_TYPE}" "${SOBER_LIBRARY_SOURCES}")
        sober_library_internal_add_base_includes ("${BASE_LIBRARY_TARGET}")

        foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
            # TODO: Ability to select api include type (INTERFACE, PUBLIC, PRIVATE)?
            sober_internal_get_service_target_name ("${SERVICE_NAME}" SERVICE_TARGET)
            target_link_libraries ("${BASE_LIBRARY_TARGET}" PUBLIC ${SERVICE_TARGET})
        endforeach ()
    endif ()

    message (STATUS "Library \"${SOBER_LIBRARY_NAME}\" configuration started.")
    unset (SOBER_LIBRARY_NAME PARENT_SCOPE)
    unset (SOBER_LIBRARY_TYPE PARENT_SCOPE)
endfunction ()