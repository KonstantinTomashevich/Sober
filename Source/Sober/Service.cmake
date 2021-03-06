include_guard (GLOBAL)

macro (sober_begin_service SERVICE_NAME)
    message (STATUS "Service \"${SERVICE_NAME}\" configuration started.")
    set (SOBER_SERVICE_NAME "${SERVICE_NAME}")

    add_library (${SERVICE_NAME} INTERFACE)
    define_property (TARGET PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION
                     BRIEF_DOCS "Name of service default implementation."
                     FULL_DOCS "\
Service default implementation is used implicitly if there is no explicit \
request for other implementation in library definition code.")

    define_property (TARGET PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS
                     BRIEF_DOCS "Do service API headers include special headers, provided by implementation?"
                     FULL_DOCS "\
If service API headers include implementation-specific headers, library variants \
can not be defined as link-only variants and must be compiled separately.")

    set_property (TARGET ${SERVICE_NAME} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS FALSE)
    unset (SOBER_SERVICE_CONFIGURATION_DONE)
    unset (SOBER_INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED)
endmacro ()

macro (sober_add_service_include_directory INCLUDE_DIRECTORY)
    if (SOBER_SERVICE_CONFIGURATION_DONE)
        message (SEND_ERROR "Sober: caught attempt to add service include \
                             directory after implementation registrations!")
    endif ()

    message (STATUS "    Adding include directory: \"${INCLUDE_DIRECTORY}\".")
    target_include_directories (${SOBER_SERVICE_NAME} INTERFACE "${INCLUDE_DIRECTORY}")
endmacro ()

macro (sober_add_implementation_headers_requirement)
    if (SOBER_SERVICE_CONFIGURATION_DONE)
        message (SEND_ERROR
                "Sober: caught attempt to add implementation headers requirement after implementation registrations!")
    endif ()

    message (STATUS "    Implementation headers are REQUIRED by API headers!")
    set_property (TARGET ${SOBER_SERVICE_NAME}
                  PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS TRUE)
endmacro ()

macro (sober_add_service_implementation IMPLEMENTATION_DIRECTORY)
    message (STATUS "    Adding implementation from \"${IMPLEMENTATION_DIRECTORY}\".")
    set (SOBER_SERVICE_CONFIGURATION_DONE TRUE)
    add_subdirectory (${IMPLEMENTATION_DIRECTORY})
    target_link_libraries ("${SOBER_SERVICE_NAME}${SOBER_SERVICE_IMPLEMENTATION_NAME}" PUBLIC ${SOBER_SERVICE_NAME})
endmacro ()

macro (sober_add_default_service_implementation IMPLEMENTATION_DIRECTORY)
    sober_add_service_implementation ("${IMPLEMENTATION_DIRECTORY}")
    if (SOBER_INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED)
        # TODO: Unable to find better format for such long messages in documentation. Check again.
        message (WARNING "\
Sober: unable to make \"${SOBER_SERVICE_IMPLEMENTATION_NAME}\" default implementation \
for service \"${SOBER_SERVICE_NAME}\", because other implementation is already \
\"${${SOBER_SERVICE_NAME}_DEFAULT_IMPLEMENTATION}}\"!")

    endif ()

    set_property (TARGET ${SOBER_SERVICE_NAME}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION ${SOBER_SERVICE_IMPLEMENTATION_NAME})

    set (SOBER_INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED TRUE)
    message (STATUS "        Selected as default implementation!")
endmacro ()

macro (sober_end_service)
    if (NOT SOBER_INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION_SELECTED)
        message (FATAL_ERROR "Sober: default implementation for \"${SOBER_SERVICE_NAME}\" is not specified!")
    endif ()

    message (STATUS "Service \"${SOBER_SERVICE_NAME}\" configuration finished.")
endmacro ()

macro (sober_set_service_implementation_name SERVICE_IMPLEMENTATION_NAME)
    message (STATUS "        Implementation name is \"${SERVICE_IMPLEMENTATION_NAME}\".")
    get_property (SOBER_INTERFACE_USES_IMPLEMENTATION_HEADERS
                  TARGET ${SOBER_SERVICE_NAME} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

    if (SOBER_INTERFACE_USES_IMPLEMENTATION_HEADERS)
        set (SOBER_IMPLEMENTATION_INCLUDES_SCOPE "PUBLIC")
    else ()
        set (SOBER_IMPLEMENTATION_INCLUDES_SCOPE "PRIVATE")
    endif ()

    set (SOBER_SERVICE_IMPLEMENTATION_NAME ${SERVICE_IMPLEMENTATION_NAME})
    set (SOBER_SERVICE_IMPLEMENTATION_NAME ${SOBER_SERVICE_IMPLEMENTATION_NAME} PARENT_SCOPE)

    set (SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME ${SOBER_SERVICE_NAME}${SOBER_SERVICE_IMPLEMENTATION_NAME})
    message (STATUS "        Implementation target name is \"${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME}\".")
endmacro ()
