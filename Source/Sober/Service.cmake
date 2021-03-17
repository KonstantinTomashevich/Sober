include_guard (GLOBAL)

function (sober_service_begin SERVICE_NAME)
    message (STATUS "Service \"${SERVICE_NAME}\" configuration started.")
    set (SOBER_SERVICE_NAME "${SERVICE_NAME}" PARENT_SCOPE)

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
    unset (SOBER_IMPLEMENTATION_REGISTRATION_STARTED PARENT_SCOPE)
endfunction ()

function (sober_service_include_directory INCLUDE_DIRECTORY)
    message (STATUS "    Adding include directory: \"${INCLUDE_DIRECTORY}\".")
    target_include_directories (${SOBER_SERVICE_NAME} INTERFACE "${INCLUDE_DIRECTORY}")
endfunction ()

function (sober_service_add_api_dependency TARGET_NAME)
    message (STATUS "    Adding API dependency: \"${TARGET_NAME}\".")
    target_link_libraries (${SOBER_SERVICE_NAME} INTERFACE "${TARGET_NAME}")
endfunction ()

function (sober_service_require_implementation_headers)
    if (SOBER_IMPLEMENTATION_REGISTRATION_STARTED)
        message (SEND_ERROR
                 "Sober: caught attempt to add implementation headers requirement after implementation registrations!")
    endif ()

    message (STATUS "    Implementation headers are REQUIRED by API headers!")
    set_property (TARGET ${SOBER_SERVICE_NAME}
                  PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS TRUE)
endfunction ()

function (sober_service_add_implementation IMPLEMENTATION_DIRECTORY)
    message (STATUS "    Adding implementation from \"${IMPLEMENTATION_DIRECTORY}\".")
    set (SOBER_IMPLEMENTATION_REGISTRATION_STARTED TRUE PARENT_SCOPE)
    add_subdirectory (${IMPLEMENTATION_DIRECTORY})
endfunction ()

function (sober_service_set_default_implementation IMPLEMENTATION_NAME)
    get_property (DEFAULT_IMPLEMENTATION_SELECTED TARGET ${SOBER_SERVICE_NAME}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION SET)

    if (DEFAULT_IMPLEMENTATION_SELECTED)
        # TODO: Unable to find better format for such long messages in documentation. Check again.
        message (WARNING "\
Sober: unable to make \"${IMPLEMENTATION_NAME}\" default implementation for service \
\"${SOBER_SERVICE_NAME}\", because other implementation is already selected as default!")
        return ()
    endif ()

    if (NOT TARGET "${SOBER_SERVICE_NAME}${IMPLEMENTATION_NAME}")
        message (SEND_ERROR "\
Sober: unable to make \"${IMPLEMENTATION_NAME}\" default implementation for service \
\"${SOBER_SERVICE_NAME}\", because there is no target with name \"${SOBER_SERVICE_NAME}${IMPLEMENTATION_NAME}\"!")
        return ()
    endif ()

    set_property (TARGET ${SOBER_SERVICE_NAME}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION ${IMPLEMENTATION_NAME})

    message (STATUS "        Selected as default implementation!")
endfunction ()

function (sober_service_end)
    get_property (DEFAULT_IMPLEMENTATION_SELECTED TARGET ${SOBER_SERVICE_NAME}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION SET)

    if (NOT DEFAULT_IMPLEMENTATION_SELECTED)
        message (FATAL_ERROR "Sober: default implementation for \"${SOBER_SERVICE_NAME}\" is not specified!")
    endif ()

    message (STATUS "Service \"${SOBER_SERVICE_NAME}\" configuration finished.")
    unset (SOBER_SERVICE_NAME PARENT_SCOPE)
endfunction ()

function (sober_implementation_begin IMPLEMENTATION_NAME)
    message (STATUS "        Implementation \"${IMPLEMENTATION_NAME}\" configuration started.")
    if (NOT SOBER_SERVICE_NAME)
        message (FATAL_ERROR "Sober: sober_begin_implementation called outside of service definition!")
    endif ()

    set (SOBER_IMPLEMENTATION_NAME ${IMPLEMENTATION_NAME} PARENT_SCOPE)
endfunction ()

function (sober_implementation_setup_target LIBRARY_TYPE LIBRARY_SOURCES)
    message (STATUS "           Adding implementation library \"${SOBER_SERVICE_NAME}${SOBER_IMPLEMENTATION_NAME}\".")
    message (STATUS "           Library type is \"${LIBRARY_TYPE}\".")
    add_library ("${SOBER_SERVICE_NAME}${SOBER_IMPLEMENTATION_NAME}" ${LIBRARY_TYPE} ${LIBRARY_SOURCES})
endfunction ()

function (sober_implementation_include_directory DIRECTORY)
    get_property (INTERFACE_USES_IMPLEMENTATION_HEADERS
                  TARGET ${SOBER_SERVICE_NAME} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

    if (INTERFACE_USES_IMPLEMENTATION_HEADERS)
        set (INCLUDES_SCOPE "PUBLIC")
    else ()
        set (INCLUDES_SCOPE "PRIVATE")
    endif ()

    message (STATUS "           Including directory \"${DIRECTORY}\" to \"${INCLUDES_SCOPE}\" scope.")
    target_include_directories ("${SOBER_SERVICE_NAME}${SOBER_IMPLEMENTATION_NAME}" ${INCLUDES_SCOPE} ${DIRECTORY})
endfunction ()

function (sober_implementation_link_library LIBRARY)
    get_property (INTERFACE_USES_IMPLEMENTATION_HEADERS
                  TARGET ${SOBER_SERVICE_NAME} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

    if (INTERFACE_USES_IMPLEMENTATION_HEADERS)
        set (INCLUDES_SCOPE "PUBLIC")
    else ()
        set (INCLUDES_SCOPE "PRIVATE")
    endif ()

    message (STATUS "           Linking library \"${LIBRARY}\" to \"${INCLUDES_SCOPE}\" scope.")
    target_link_libraries ("${SOBER_SERVICE_NAME}${SOBER_IMPLEMENTATION_NAME}" ${INCLUDES_SCOPE} ${LIBRARY})
endfunction ()

function (sober_implementation_end)
    target_link_libraries ("${SOBER_SERVICE_NAME}${SOBER_IMPLEMENTATION_NAME}" PUBLIC ${SOBER_SERVICE_NAME})
    message (STATUS "        Implementation \"${SOBER_IMPLEMENTATION_NAME}\" configuration started.")
    unset (SOBER_IMPLEMENTATION_NAME PARENT_SCOPE)
endfunction ()
