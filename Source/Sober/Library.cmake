include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)
set (SOBER_BASE_LIBRARY_SUFFIX "Base")

macro (sober_begin_library LIBRARY_NAME LIBRARY_TYPE)
    message (STATUS "Library \"${LIBRARY_NAME}\" configuration started.")
    message (STATUS "    Type: ${LIBRARY_TYPE}.")

    set (SOBER_LIBRARY_NAME "${LIBRARY_NAME}")
    set (SOBER_LIBRARY_TYPE "${LIBRARY_TYPE}")

    unset (SOBER_USED_SERVICES)
    unset (SOBER_LIBRARY_SOURCES)
    unset (SOBER_UNABLE_TO_USE_LINK_VARIANTS)

    unset (SOBER_LIBRARY_PUBLIC_INCLUDES)
    unset (SOBER_LIBRARY_PRIVATE_INCLUDES)
    unset (SOBER_LIBRARY_INTERFACE_INCLUDES)
    unset (SOBER_LIBRARY_CONFIGURATION_DONE)
endmacro ()

macro (sober_use_service SERVICE_NAME)
    if (SOBER_LIBRARY_CONFIGURATION_DONE)
        message (SEND_ERROR "Sober: caught attempt to add service usage after variants registrations!")
    endif ()

    if (NOT SOBER_${SERVICE_NAME}_FOUND)
        message (FATAL_ERROR "Sober: service \"${SERVICE_NAME}\" is not found!")
    endif ()

    list (FIND SOBER_USED_SERVICES ${SERVICE_NAME} FOUND_INDEX)
    if (FOUND_INDEX EQUAL -1)
        if (SOBER_${SERVICE_NAME}_USES_IMPLEMENTATION_HEADERS)
            set (SOBER_UNABLE_TO_USE_LINK_VARIANTS TRUE)
        endif ()

        list (APPEND SOBER_USED_SERVICES ${SERVICE_NAME})
        message (STATUS "    Uses service \"${SERVICE_NAME}\".")
    else ()
        message (WARNING "Sober: service \"${SERVICE_NAME}\" is already used by library \"${SOBER_LIBRARY_NAME}\"!")
    endif ()
endmacro ()

macro (sober_set_library_sources LIBRARY_SOURCES)
    if (SOBER_LIBRARY_CONFIGURATION_DONE)
        message (SEND_ERROR "Sober: caught attempt to set library sources after variants registrations!")
    endif ()

    set (SOBER_LIBRARY_SOURCES ${LIBRARY_SOURCES})
endmacro ()

macro (sober_add_library_include_directories INCLUDE_SCOPE INCLUDE_DIRECTORIES)
    if (SOBER_LIBRARY_CONFIGURATION_DONE)
        message (SEND_ERROR "Sober: caught attempt to add library include directories after variants registrations!")
    endif ()

    if (${INCLUDE_SCOPE} STREQUAL "PUBLIC" OR
        ${INCLUDE_SCOPE} STREQUAL "PRIVATE" OR
        ${INCLUDE_SCOPE} STREQUAL "INTERFACE")

        list (APPEND SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES ${INCLUDE_DIRECTORIES})
    else ()
        message (SEND_ERROR "Sober: caught unknown include scope \"${INCLUDE_SCOPE}\"!")
    endif ()
endmacro ()

macro (sober_begin_variant VARIANT_NAME)
    if (VARIANT_NAME STREQUAL SOBER_BASE_LIBRARY_SUFFIX)
        message (FATAL_ERROR "Sober: can not use variant name \"${VARIANT_NAME}\", because it's reserved suffix!")
    endif ()

    set (SOBER_LIBRARY_CONFIGURATION_DONE TRUE)
    set (SOBER_VARIANT_NAME ${VARIANT_NAME})
    message (STATUS "    Variant \"${VARIANT_NAME}\" configuration started.")
endmacro ()

macro (sober_set_default_service_implementation SERVICE_NAME DEFAULT_IMPLEMENTATION)
    # TODO: Check is service used?
    set (${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION
         ${DEFAULT_IMPLEMENTATION} CACHE STRING)
endmacro ()

macro (sober_freeze_service_implementation SERVICE_NAME CONSTANT_IMPLEMENTATION)
    # TODO: Check is service used?
    set (${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION ${CONSTANT_IMPLEMENTATION})
endmacro ()

macro (sober_add_base_library_includes TARGET_NAME)
    target_include_directories ("${TARGET_NAME}" PUBLIC ${SOBER_LIBRARY_PUBLIC_INCLUDES})
    target_include_directories ("${TARGET_NAME}" PRIVATE ${SOBER_LIBRARY_PRIVATE_INCLUDES})
    target_include_directories ("${TARGET_NAME}" INTERFACE ${SOBER_LIBRARY_INTERFACE_INCLUDES})
endmacro ()

# TODO: Use functions instead of macros where possible?
macro (sober_end_variant)
    foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
        if (NOT ${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION)
            set (${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION
                 ${SOBER_${SERVICE_NAME}_DEFAULT_IMPLEMENTATION})
        endif ()

        set (SERVICE_IMPLEMENTATION
             "${${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION}")

        # TODO: Target name convention ServiceName..ServiceImplementation is hardcoded everywhere. Refactor?
        if (TARGET "${SERVICE_NAME}${SERVICE_IMPLEMENTATION}")
            message (STATUS "        \"${SERVICE_NAME}\" implementation: \"${SERVICE_IMPLEMENTATION}\".")
        else ()
            message (SEND_ERROR
                     "Sober: service \"${SERVICE_NAME}\" implementation \"${SERVICE_IMPLEMENTATION}\" not found!")
        endif ()
    endforeach ()

    set (TARGET_NAME "${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}")
    if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
        add_library (${TARGET_NAME} ${SOBER_LIBRARY_TYPE} ${SOBER_LIBRARY_SOURCES})
        sober_add_base_library_includes (${TARGET_NAME})
        # TODO: Ability to select api include type (INTERFACE, PUBLIC, PRIVATE)?
        set (SERVICE_LINK_TYPE PUBLIC)
    else ()
        add_library (${TARGET_NAME} INTERFACE)
        set (SERVICE_LINK_TYPE INTERFACE)
        target_link_libraries (${TARGET_NAME} ${SERVICE_LINK_TYPE} "${SOBER_LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}")
    endif ()

    foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
        set (SERVICE_IMPLEMENTATION
                "${${SOBER_LIBRARY_NAME}${SOBER_VARIANT_NAME}_${SERVICE_NAME}_SELECTED_IMPLEMENTATION}")
        target_link_libraries (${TARGET_NAME} ${SERVICE_LINK_TYPE} "${SERVICE_NAME}${SERVICE_IMPLEMENTATION}")
    endforeach ()

    message (STATUS "    Variant \"${SOBER_VARIANT_NAME}\" configuration finished.")
endmacro ()

macro (sober_end_library)
    if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
        message (STATUS
                "    Forced to compile variants separately because several services use implementation headers:")

        foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
            if (SOBER_${SERVICE_NAME}_USES_IMPLEMENTATION_HEADERS)
                message (STATUS "        ${SERVICE_NAME}")
            endif ()
        endforeach ()
    else ()
        add_library ("${SOBER_LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}"
                     ${SOBER_LIBRARY_TYPE} ${SOBER_LIBRARY_SOURCES})
        sober_add_base_library_includes ("${SOBER_LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}")

        foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
            # TODO: Ability to select api include type (INTERFACE, PUBLIC, PRIVATE)?
            target_link_libraries ("${SOBER_LIBRARY_NAME}${SOBER_BASE_LIBRARY_SUFFIX}" PUBLIC ${SERVICE_NAME})
        endforeach ()
    endif ()

    message (STATUS "Library \"${SOBER_LIBRARY_NAME}\" configuration started.")
endmacro ()