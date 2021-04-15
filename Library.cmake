# Library.cmake contains functions for libraries and variants configuration routine.
# Variant-related configuration functions are stored in one file with library configuration
# functions because variant configuration routine is part of library configuration routine.

include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)

# Generates name for library internal variable, that holds service usage scope. These variables should
# not be used by other modules or scipts, therefore this function can not be defined in Naming.cmake.
function (sober_internal_naming_service_usage_scope_variable LIBRARY_NAME SERVICE_NAME OUTPUT_VARIABLE)
    sober_naming_library_variable ("${LIBRARY_NAME}" "${SERVICE_NAME}_SCOPE" "${OUTPUT_VARIABLE}")
    set ("${OUTPUT_VARIABLE}" "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction ()

# Library configuration top level routine opener.
function (sober_library_begin LIBRARY_NAME LIBRARY_TYPE)
    message (STATUS "Library \"${LIBRARY_NAME}\" configuration started.")
    message (STATUS "    Type: ${LIBRARY_TYPE}.")

    if (NOT "${LIBRARY_TYPE}" STREQUAL "STATIC" AND
        NOT "${LIBRARY_TYPE}" STREQUAL "SHARED" AND
        NOT "${LIBRARY_TYPE}" STREQUAL "INTERFACE")

        message (FATAL_ERROR "Sober: library type must be \"STATIC\", \"SHARED\" or \"INTERFACE\"!")
    endif ()

    set (SOBER_LIBRARY_NAME "${LIBRARY_NAME}" PARENT_SCOPE)
    set (SOBER_LIBRARY_TYPE "${LIBRARY_TYPE}" PARENT_SCOPE)

    unset (SOBER_USED_SERVICES PARENT_SCOPE)
    unset (SOBER_LIBRARY_SOURCES PARENT_SCOPE)
    unset (SOBER_UNABLE_TO_USE_LINK_VARIANTS PARENT_SCOPE)

    unset (SOBER_LIBRARY_PUBLIC_INCLUDES PARENT_SCOPE)
    unset (SOBER_LIBRARY_PRIVATE_INCLUDES PARENT_SCOPE)
    unset (SOBER_LIBRARY_INTERFACE_INCLUDES PARENT_SCOPE)

    unset (SOBER_LIBRARY_PUBLIC_LINK_LIBRARIES PARENT_SCOPE)
    unset (SOBER_LIBRARY_PRIVATE_LINK_LIBRARIES PARENT_SCOPE)
    unset (SOBER_LIBRARY_INTERFACE_LINK_LIBRARIES PARENT_SCOPE)

    unset (SOBER_LIBRARY_PUBLIC_COMPILE_OPTIONS PARENT_SCOPE)
    unset (SOBER_LIBRARY_PRIVATE_COMPILE_OPTIONS PARENT_SCOPE)
    unset (SOBER_LIBRARY_INTERFACE_COMPILE_OPTIONS PARENT_SCOPE)
    unset (SOBER_VARIANT_CONFIGURATION_STARTED PARENT_SCOPE)
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_use_service SERVICE_NAME USAGE_SCOPE)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to add service usage after variants configuration!")
        return ()
    endif ()

    if (NOT "${USAGE_SCOPE}" STREQUAL "PUBLIC" AND
        NOT "${USAGE_SCOPE}" STREQUAL "PRIVATE" AND
        NOT "${USAGE_SCOPE}" STREQUAL "INTERFACE")

        message (SEND_ERROR "Sober: service usage scope must be \"PUBLIC\", \"PRIVATE\" or \"INTERFACE\"!")
        return ()
    endif ()

    sober_naming_service_target ("${SERVICE_NAME}" SERVICE_TARGET)
    if (NOT TARGET ${SERVICE_TARGET})
        message (SEND_ERROR "Sober: service \"${SERVICE_NAME}\" is not found!")
        return ()
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

        sober_internal_naming_service_usage_scope_variable (
                "${SOBER_LIBRARY_NAME}" "${SERVICE_NAME}" SCOPE_VARIABLE_NAME)

        set ("${SCOPE_VARIABLE_NAME}" "${USAGE_SCOPE}" PARENT_SCOPE)
        message (STATUS "    Using service \"${SERVICE_NAME}\" within \"${USAGE_SCOPE}\" scope.")
    else ()
        message (WARNING "Sober: service \"${SERVICE_NAME}\" is already used by library \"${SOBER_LIBRARY_NAME}\"!")
    endif ()
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_set_sources LIBRARY_SOURCES)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to set library sources after variants configuration!")
        return ()
    endif ()

    set (SOBER_LIBRARY_SOURCES ${LIBRARY_SOURCES} PARENT_SCOPE)
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_include_directory INCLUDE_SCOPE INCLUDE_DIRECTORY)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to add library include directories after variants configuration!")
        return ()
    endif ()

    if ("${INCLUDE_SCOPE}" STREQUAL "PUBLIC" OR
        "${INCLUDE_SCOPE}" STREQUAL "PRIVATE" OR
        "${INCLUDE_SCOPE}" STREQUAL "INTERFACE")

        message (STATUS "    Including directory \"${INCLUDE_DIRECTORY}\" to \"${INCLUDE_SCOPE}\" scope.")
        list (APPEND "SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES" "${INCLUDE_DIRECTORY}")
        set ("SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES" ${SOBER_LIBRARY_${INCLUDE_SCOPE}_INCLUDES} PARENT_SCOPE)
    else ()
        message (SEND_ERROR "Sober: caught unknown include scope \"${INCLUDE_SCOPE}\"!")
    endif ()
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_link_library LINK_SCOPE LIBRARY_NAME)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to add library link dependency after variants configuration!")
        return ()
    endif ()

    if ("${LINK_SCOPE}" STREQUAL "PUBLIC" OR
        "${LINK_SCOPE}" STREQUAL "PRIVATE" OR
        "${LINK_SCOPE}" STREQUAL "INTERFACE")

        message (STATUS "    Linking library \"${LIBRARY_NAME}\" to \"${LINK_SCOPE}\" scope.")
        list (APPEND "SOBER_LIBRARY_${LINK_SCOPE}_LINK_LIBRARIES" "${LIBRARY_NAME}")
        set ("SOBER_LIBRARY_${LINK_SCOPE}_LINK_LIBRARIES" ${SOBER_LIBRARY_${LINK_SCOPE}_LINK_LIBRARIES} PARENT_SCOPE)
    else ()
        message (SEND_ERROR "Sober: caught unknown link scope \"${INCLUDE_SCOPE}\"!")
    endif ()
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_public_compile_options)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to append public compile options after variants configuration!")
        return ()
    endif ()

    message (STATUS "    Appending public compile options: ${ARGV}.")
    list (APPEND SOBER_LIBRARY_PUBLIC_COMPILE_OPTIONS ${ARGV})
    set (SOBER_LIBRARY_PUBLIC_COMPILE_OPTIONS ${SOBER_LIBRARY_PUBLIC_COMPILE_OPTIONS} PARENT_SCOPE)
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_private_compile_options)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to append private compile options after variants configuration!")
        return ()
    endif ()

    message (STATUS "    Appending private compile options: ${ARGV}.")
    list (APPEND SOBER_LIBRARY_PRIVATE_COMPILE_OPTIONS ${ARGV})
    set (SOBER_LIBRARY_PRIVATE_COMPILE_OPTIONS ${SOBER_LIBRARY_PRIVATE_COMPILE_OPTIONS} PARENT_SCOPE)
endfunction ()

# Part of library configuration top level routine. Should be called before variant additions.
function (sober_library_interface_compile_options)
    if (SOBER_VARIANT_CONFIGURATION_STARTED)
        message (SEND_ERROR "Sober: caught attempt to append interface compile options after variants configuration!")
        return ()
    endif ()

    message (STATUS "    Appending interface compile options: ${ARGV}.")
    list (APPEND SOBER_LIBRARY_INTERFACE_COMPILE_OPTIONS ${ARGV})
    set (SOBER_LIBRARY_INTERFACE_COMPILE_OPTIONS ${SOBER_LIBRARY_INTERFACE_COMPILE_OPTIONS} PARENT_SCOPE)
endfunction ()

# Adds library include directories, link library dependencies and compile options to given target.
# Can be called inside library configuration top level routine or variant configuration secondary level routine.
function (sober_internal_library_configure_as_base_target TARGET)
    target_include_directories ("${TARGET}" PUBLIC ${SOBER_LIBRARY_PUBLIC_INCLUDES})
    target_include_directories ("${TARGET}" PRIVATE ${SOBER_LIBRARY_PRIVATE_INCLUDES})
    target_include_directories ("${TARGET}" INTERFACE ${SOBER_LIBRARY_INTERFACE_INCLUDES})

    target_link_libraries ("${TARGET}" PUBLIC ${SOBER_LIBRARY_PUBLIC_LINK_LIBRARIES})
    target_link_libraries ("${TARGET}" PRIVATE ${SOBER_LIBRARY_PRIVATE_LINK_LIBRARIES})
    target_link_libraries ("${TARGET}" INTERFACE ${SOBER_LIBRARY_INTERFACE_LINK_LIBRARIES})

    target_compile_options ("${TARGET}" PUBLIC ${SOBER_LIBRARY_PUBLIC_COMPILE_OPTIONS})
    target_compile_options ("${TARGET}" PRIVATE ${SOBER_LIBRARY_PRIVATE_COMPILE_OPTIONS})
    target_compile_options ("${TARGET}" INTERFACE ${SOBER_LIBRARY_INTERFACE_COMPILE_OPTIONS})
endfunction ()

# Library configuration top level routine closer.
# If link variants usage is possible, library base target is generated there.
function (sober_library_end)
    if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
        message (STATUS
                 "    Forced to compile variants separately because several services use implementation headers:")

        foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
            sober_naming_service_target ("${SERVICE_NAME}" SERVICE_TARGET)
            get_property (USES_IMPLEMENTATION_HEADERS TARGET ${SERVICE_TARGET}
                          PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

            if (USES_IMPLEMENTATION_HEADERS)
                message (STATUS "        - ${SERVICE_NAME}")
            endif ()
        endforeach ()
    else ()
        sober_naming_library_base_target ("${SOBER_LIBRARY_NAME}" BASE_LIBRARY_TARGET)
        add_library ("${BASE_LIBRARY_TARGET}" "${SOBER_LIBRARY_TYPE}" "${SOBER_LIBRARY_SOURCES}")
        sober_internal_library_configure_as_base_target ("${BASE_LIBRARY_TARGET}")

        foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
            sober_internal_naming_service_usage_scope_variable (
                    "${SOBER_LIBRARY_NAME}" "${SERVICE_NAME}" SCOPE_VARIABLE_NAME)

            sober_naming_service_target ("${SERVICE_NAME}" SERVICE_TARGET)
            target_link_libraries ("${BASE_LIBRARY_TARGET}" "${${SCOPE_VARIABLE_NAME}}" ${SERVICE_TARGET})
        endforeach ()
    endif ()

    message (STATUS "Library \"${SOBER_LIBRARY_NAME}\" configuration finished.")
    unset (SOBER_LIBRARY_NAME PARENT_SCOPE)
    unset (SOBER_LIBRARY_TYPE PARENT_SCOPE)
endfunction ()

# Variant configuration secondary level routine opener. Part of library configuration top level routine.
# Creates library variant target is created there, but leaves implementation selection step to sober_variant_end.
function (sober_variant_begin VARIANT_NAME)
    set (SOBER_VARIANT_CONFIGURATION_STARTED TRUE PARENT_SCOPE)
    set (SOBER_VARIANT_NAME ${VARIANT_NAME} PARENT_SCOPE)

    sober_naming_variant_target ("${SOBER_LIBRARY_NAME}" "${VARIANT_NAME}" SOBER_VARIANT_TARGET)
    set (SOBER_VARIANT_TARGET "${SOBER_VARIANT_TARGET}" PARENT_SCOPE)
    message (STATUS "    Variant \"${VARIANT_NAME}\" configuration started.")

    if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
        add_library ("${SOBER_VARIANT_TARGET}" "${SOBER_LIBRARY_TYPE}" ${SOBER_LIBRARY_SOURCES})
        sober_internal_library_configure_as_base_target ("${SOBER_VARIANT_TARGET}")
    else ()
        add_library ("${SOBER_VARIANT_TARGET}" INTERFACE)
        sober_naming_library_base_target ("${SOBER_LIBRARY_NAME}" BASE_LIBRARY_TARGET)
        target_link_libraries ("${SOBER_VARIANT_TARGET}" INTERFACE "${BASE_LIBRARY_TARGET}")
    endif ()
endfunction ()

# Selects service default implementation for this variant and saves this value to
# cached variable. User can change this value using build option with the same name
# (sober_naming_selected_implementation_variable contains option name pattern).
# Part of variant configuration secondary level routine.
function (sober_variant_set_default_implementation SERVICE_NAME DEFAULT_IMPLEMENTATION)
    # TODO: Think about context validation. Will it really slow down configuration stage?
    sober_naming_selected_implementation_variable (
            "${SOBER_LIBRARY_NAME}" "${SOBER_VARIANT_NAME}" "${SERVICE_NAME}" VARIABLE)
    set ("${VARIABLE}" "${DEFAULT_IMPLEMENTATION}" CACHE STRING)
endfunction ()

# Selects service default implementation and sets this value directly to according variable
# without caching. Therefore user can not override this value using build options.
# Part of variant configuration secondary level routine.
function (sober_variant_freeze_implementation SERVICE_NAME CONSTANT_IMPLEMENTATION)
    sober_naming_selected_implementation_variable (
            "${SOBER_LIBRARY_NAME}" "${SOBER_VARIANT_NAME}" "${SERVICE_NAME}" VARIABLE)
    set ("${VARIABLE}" "${CONSTANT_IMPLEMENTATION}" PARENT_SCOPE)
endfunction ()

# Variant configuration secondary level routine closer. Part of library configuration top level routine.
# Links selected service implementations to library variant target.
function (sober_variant_end)
    foreach (SERVICE_NAME IN LISTS SOBER_USED_SERVICES)
        sober_naming_selected_implementation_variable (
                "${SOBER_LIBRARY_NAME}" "${SOBER_VARIANT_NAME}" "${SERVICE_NAME}" IMPLEMENTATION_VARIABLE_NAME)

        if (DEFINED "${IMPLEMENTATION_VARIABLE_NAME}")
            set (SERVICE_IMPLEMENTATION "${${IMPLEMENTATION_VARIABLE_NAME}}")
        else ()
            sober_naming_service_target ("${SERVICE_NAME}" SERVICE_TARGET)
            get_property (SERVICE_IMPLEMENTATION TARGET ${SERVICE_TARGET}
                          PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION)
        endif ()

        sober_naming_implementation_target (
                "${SERVICE_NAME}" "${SERVICE_IMPLEMENTATION}" IMPLEMENTATION_TARGET)

        if (TARGET "${IMPLEMENTATION_TARGET}")
            message (STATUS "        Using \"${SERVICE_NAME}\" implementation \"${SERVICE_IMPLEMENTATION}\".")
        else ()
            message (SEND_ERROR
                     "Sober: service \"${SERVICE_NAME}\" implementation \"${SERVICE_IMPLEMENTATION}\" not found!")
        endif ()

        sober_internal_naming_service_usage_scope_variable (
                "${SOBER_LIBRARY_NAME}" "${SERVICE_NAME}" SCOPE_VARIABLE_NAME)

        if (SOBER_UNABLE_TO_USE_LINK_VARIANTS)
            # If variants are configured in link mode, API targets will always be linked as dependencies.
            # In separate target mode, services, that do not require implementation headers, will not provide
            # API headers (otherwise API headers would always be exposed in link mode), therefore we must
            # manually link API headers target.
            sober_naming_service_target ("${SERVICE_NAME}" SERVICE_TARGET)
            target_link_libraries ("${SOBER_VARIANT_TARGET}" "${${SCOPE_VARIABLE_NAME}}" ${SERVICE_TARGET})

            set (LINK_TYPE "${${SCOPE_VARIABLE_NAME}}")
        else ()
            set (LINK_TYPE INTERFACE)
        endif ()

        target_link_libraries (${SOBER_VARIANT_TARGET} "${LINK_TYPE}" "${IMPLEMENTATION_TARGET}")
    endforeach ()

    message (STATUS "    Variant \"${SOBER_VARIANT_NAME}\" configuration finished.")
    unset (SOBER_VARIANT_NAME PARENT_SCOPE)
    unset (SOBER_VARIANT_TARGET PARENT_SCOPE)
endfunction ()