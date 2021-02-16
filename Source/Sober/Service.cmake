include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

macro (sober_begin_service SERVICE_NAME)
    message (STATUS "Service \"${SERVICE_NAME}\" configuration started.")
    set (SOBER_SERVICE_NAME "${SERVICE_NAME}")

    unset (SOBER_SERVICE_INCLUDE_DIRECTORIES)
    unset (SOBER_SERVICES_USES_IMPLEMENTATION_HEADERS)
    unset (SOBER_SERVICE_CONFIGURATION_DONE)
    unset (SOBER_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED)
endmacro ()

macro (sober_set_service_include_directories INCLUDE_DIRECTORIES)
    if (SOBER_SERVICE_CONFIGURATION_DONE)
        message (SEND_ERROR "Sober: caught attempt to add service include \
                             directory after implementation registrations!")
    endif ()

    message (STATUS "    Include directories: \"${INCLUDE_DIRECTORIES}\".")
    set (SOBER_SERVICE_INCLUDE_DIRECTORIES "${INCLUDE_DIRECTORIES}")
endmacro ()

macro (sober_add_implementation_headers_requirement)
    if (SOBER_SERVICE_CONFIGURATION_DONE)
        message (SEND_ERROR
                "Sober: caught attempt to add implementation headers requirement after implementation registrations!")
    endif ()

    message (STATUS "    Implementation headers are REQUIRED by API headers!")
    set (SOBER_SERVICES_USES_IMPLEMENTATION_HEADERS TRUE)
endmacro ()

macro (sober_add_service_implementation IMPLEMENTATION_DIRECTORY)
    message (STATUS "    Adding implementation from \"${IMPLEMENTATION_DIRECTORY}\".")
    set (SOBER_SERVICE_CONFIGURATION_DONE TRUE)
    add_subdirectory (${IMPLEMENTATION_DIRECTORY})

    target_include_directories (${SOBER_SERVICE_NAME}${SOBER_SERVICE_IMPLEMENTATION_NAME}
                                PUBLIC ${SOBER_SERVICE_INCLUDE_DIRECTORIES})
endmacro ()

macro (sober_add_default_service_implementation IMPLEMENTATION_DIRECTORY)
    sober_add_service_implementation ("${IMPLEMENTATION_DIRECTORY}")
    if (SOBER_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED)
        # TODO: Unable to find better format for such long messages in documentation. Check again.
        message (WARNING "\
Sober: unable to make \"${SOBER_SERVICE_IMPLEMENTATION_NAME}\" default implementation \
for service \"${SOBER_SERVICE_NAME}\", because other implementation is already \
\"${${SOBER_SERVICE_NAME}_DEFAULT_IMPLEMENTATION}}\"!")

    endif ()

    set (SOBER_${SOBER_SERVICE_NAME}_DEFAULT_IMPLEMENTATION ${SOBER_SERVICE_IMPLEMENTATION_NAME})
    sober_make_variable_global_constant (SOBER_${SOBER_SERVICE_NAME}_DEFAULT_IMPLEMENTATION)

    set (SOBER_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED TRUE)
    message (STATUS "        Selected as default implementation!")
endmacro ()

macro (sober_end_service)
    if (NOT SOBER_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED)
        message (FATAL_ERROR "Sober: default implementation for \"${SOBER_SERVICE_NAME}\" is not specified!")
    endif ()

    if (SOBER_SERVICES_USES_IMPLEMENTATION_HEADERS)
        set (SOBER_${SOBER_SERVICE_NAME}_USES_IMPLEMENTATION_HEADERS TRUE)
        sober_make_variable_global_constant (SOBER_${SOBER_SERVICE_NAME}_USES_IMPLEMENTATION_HEADERS)
    endif ()

    set (SOBER_${SOBER_SERVICE_NAME}_INCLUDE_DIRECTORIES ${SOBER_SERVICE_INCLUDE_DIRECTORIES})
    sober_make_variable_global_constant (SOBER_${SOBER_SERVICE_NAME}_INCLUDE_DIRECTORIES)

    set (SOBER_${SOBER_SERVICE_NAME}_FOUND TRUE)
    sober_make_variable_global_constant (SOBER_${SOBER_SERVICE_NAME}_FOUND)
    message (STATUS "Service \"${SOBER_SERVICE_NAME}\" configuration finished.")
endmacro ()

macro (sober_set_service_implementation_name SERVICE_IMPLEMENTATION_NAME)
    message (STATUS "        Implementation name is \"${SERVICE_IMPLEMENTATION_NAME}\".")
    set (SOBER_SERVICE_IMPLEMENTATION_NAME ${SERVICE_IMPLEMENTATION_NAME})
    set (SOBER_SERVICE_IMPLEMENTATION_NAME ${SOBER_SERVICE_IMPLEMENTATION_NAME} PARENT_SCOPE)

    set (SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME ${SOBER_SERVICE_NAME}${SOBER_SERVICE_IMPLEMENTATION_NAME})
    message (STATUS "        Implementation target name is \"${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME}\".")
endmacro ()

macro (sober_set_service_implementation_include_directories INCLUDE_DIRECTORIES)
    if (SOBER_SERVICES_USES_IMPLEMENTATION_HEADERS)
        message (STATUS "        Public include directories: \"${INCLUDE_DIRECTORIES}\".")
        set (SOBER_${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME}_INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES})
        sober_make_variable_global_constant (SOBER_${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME}_INCLUDE_DIRECTORIES)
    endif ()
endmacro ()
