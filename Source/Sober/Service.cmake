include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)

function (sober_service_begin SERVICE_NAME)
    message (STATUS "Service \"${SERVICE_NAME}\" configuration started.")
    set (SOBER_SERVICE_NAME "${SERVICE_NAME}" PARENT_SCOPE)
    sober_internal_get_service_target_name ("${SERVICE_NAME}" SOBER_SERVICE_TARGET)
    set (SOBER_SERVICE_TARGET "${SOBER_SERVICE_TARGET}" PARENT_SCOPE)

    add_library (${SOBER_SERVICE_TARGET} INTERFACE)
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

    set_property (TARGET ${SOBER_SERVICE_TARGET} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS FALSE)
    unset (SOBER_IMPLEMENTATION_REGISTRATION_STARTED PARENT_SCOPE)
endfunction ()

function (sober_service_include_directory INCLUDE_DIRECTORY)
    message (STATUS "    Adding include directory: \"${INCLUDE_DIRECTORY}\".")
    target_include_directories (${SOBER_SERVICE_TARGET} INTERFACE "${INCLUDE_DIRECTORY}")
endfunction ()

function (sober_service_add_api_dependency TARGET)
    message (STATUS "    Adding API dependency: \"${TARGET}\".")
    target_link_libraries (${SOBER_SERVICE_TARGET} INTERFACE "${TARGET}")
endfunction ()

function (sober_service_require_implementation_headers)
    if (SOBER_IMPLEMENTATION_REGISTRATION_STARTED)
        message (SEND_ERROR
                 "Sober: caught attempt to add implementation headers requirement after implementation registrations!")
    endif ()

    message (STATUS "    Implementation headers are REQUIRED by API headers!")
    set_property (TARGET ${SOBER_SERVICE_TARGET}
                  PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS TRUE)
endfunction ()

function (sober_service_add_implementation IMPLEMENTATION_DIRECTORY)
    message (STATUS "    Adding implementation from \"${IMPLEMENTATION_DIRECTORY}\".")
    set (SOBER_IMPLEMENTATION_REGISTRATION_STARTED TRUE PARENT_SCOPE)
    add_subdirectory (${IMPLEMENTATION_DIRECTORY})
endfunction ()

function (sober_service_set_default_implementation IMPLEMENTATION_NAME)
    get_property (DEFAULT_IMPLEMENTATION_SELECTED TARGET ${SOBER_SERVICE_TARGET}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION SET)

    if (DEFAULT_IMPLEMENTATION_SELECTED)
        # TODO: Unable to find better format for such long messages in documentation. Check again.
        message (WARNING "\
Sober: unable to make \"${IMPLEMENTATION_NAME}\" default implementation for service \
\"${SOBER_SERVICE_NAME}\", because other implementation is already selected as default!")
        return ()
    endif ()

    sober_internal_get_implementation_target_name (
            "${SOBER_SERVICE_NAME}" "${IMPLEMENTATION_NAME}" IMPLEMENTATION_TARGET)

    if (NOT TARGET "${IMPLEMENTATION_TARGET}")
        message (SEND_ERROR "\
Sober: unable to make \"${IMPLEMENTATION_NAME}\" default implementation for service \
\"${SOBER_SERVICE_NAME}\", because there is no target with name \"${IMPLEMENTATION_TARGET}\"!")
        return ()
    endif ()

    set_property (TARGET ${SOBER_SERVICE_TARGET}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION ${IMPLEMENTATION_NAME})

    message (STATUS "        Selected as default implementation!")
endfunction ()

function (sober_service_end)
    get_property (DEFAULT_IMPLEMENTATION_SELECTED TARGET ${SOBER_SERVICE_TARGET}
                  PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION SET)

    if (NOT DEFAULT_IMPLEMENTATION_SELECTED)
        message (FATAL_ERROR "Sober: default implementation for \"${SOBER_SERVICE_NAME}\" is not specified!")
    endif ()

    message (STATUS "Service \"${SOBER_SERVICE_NAME}\" configuration finished.")
    unset (SOBER_SERVICE_NAME PARENT_SCOPE)
    unset (SOBER_SERVICE_TARGET PARENT_SCOPE)
endfunction ()

function (sober_implementation_begin IMPLEMENTATION_NAME)
    message (STATUS "        Implementation \"${IMPLEMENTATION_NAME}\" configuration started.")
    if (NOT DEFINED SOBER_SERVICE_NAME)
        message (FATAL_ERROR "Sober: sober_begin_implementation called outside of service definition!")
    endif ()

    set (SOBER_IMPLEMENTATION_NAME ${IMPLEMENTATION_NAME} PARENT_SCOPE)
    sober_internal_get_implementation_target_name (
            "${SOBER_SERVICE_NAME}" "${IMPLEMENTATION_NAME}" SOBER_IMPLEMENTATION_TARGET)
    set (SOBER_IMPLEMENTATION_TARGET "${SOBER_IMPLEMENTATION_TARGET}" PARENT_SCOPE)
endfunction ()

function (sober_implementation_setup_target LIBRARY_TYPE LIBRARY_SOURCES)
    message (STATUS "           Adding implementation library \"${SOBER_IMPLEMENTATION_TARGET}\".")
    message (STATUS "           Library type is \"${LIBRARY_TYPE}\".")
    add_library ("${SOBER_IMPLEMENTATION_TARGET}" ${LIBRARY_TYPE} ${LIBRARY_SOURCES})
endfunction ()

function (sober_internal_implementation_get_dependencies_scope)
    get_property (INTERFACE_USES_IMPLEMENTATION_HEADERS
                  TARGET ${SOBER_SERVICE_TARGET} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS)

    if (INTERFACE_USES_IMPLEMENTATION_HEADERS)
        set (DEPENDENCIES_SCOPE "PUBLIC" PARENT_SCOPE)
    else ()
        set (DEPENDENCIES_SCOPE "PRIVATE" PARENT_SCOPE)
    endif ()
endfunction ()

function (sober_implementation_include_directory DIRECTORY)
    sober_internal_implementation_get_dependencies_scope ()
    message (STATUS "           Including directory \"${DIRECTORY}\" to \"${DEPENDENCIES_SCOPE}\" scope.")
    target_include_directories ("${SOBER_IMPLEMENTATION_TARGET}" "${DEPENDENCIES_SCOPE}" ${DIRECTORY})
endfunction ()

function (sober_implementation_link_library LIBRARY)
    sober_internal_implementation_get_dependencies_scope ()
    message (STATUS "           Linking library \"${LIBRARY}\" to \"${DEPENDENCIES_SCOPE}\" scope.")
    target_link_libraries ("${SOBER_IMPLEMENTATION_TARGET}" "${DEPENDENCIES_SCOPE}" ${LIBRARY})
endfunction ()

function (sober_implementation_end)
    sober_internal_implementation_get_dependencies_scope ()
    # API include must be affected by includes scope too, otherwise
    # library link variants will always expose dependant services APIs.
    target_link_libraries ("${SOBER_IMPLEMENTATION_TARGET}" "${DEPENDENCIES_SCOPE}" ${SOBER_SERVICE_TARGET})

    message (STATUS "        Implementation \"${SOBER_IMPLEMENTATION_NAME}\" configuration started.")
    unset (SOBER_IMPLEMENTATION_NAME PARENT_SCOPE)
    unset (SOBER_IMPLEMENTATION_TARGET PARENT_SCOPE)
endfunction ()
