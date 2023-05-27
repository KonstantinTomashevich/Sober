# Service.cmake contains functions for services and implementations configuration routine.
# Implementation-related configuration functions are stored in one file with service configuration
# functions because implementation configuration routine is part of service configuration routine.

include_guard (GLOBAL)
include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)

# Service configuration top level routine opener.
function (sober_service_begin SERVICE_NAME)
    message (STATUS "Service \"${SERVICE_NAME}\" configuration started.")
    set (SOBER_SERVICE_NAME "${SERVICE_NAME}" PARENT_SCOPE)

    sober_naming_service_target ("${SERVICE_NAME}" SOBER_SERVICE_TARGET)
    set (SOBER_SERVICE_TARGET "${SOBER_SERVICE_TARGET}" PARENT_SCOPE)
    set (SOBER_IMPLEMENTATION_DEPENDENCIES_SCOPE "PRIVATE" PARENT_SCOPE)

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

# Part of service configuration top level routine.
function (sober_service_include_directory INCLUDE_DIRECTORY)
    message (STATUS "    Adding include directory: \"${INCLUDE_DIRECTORY}\".")
    target_include_directories (${SOBER_SERVICE_TARGET} INTERFACE "${INCLUDE_DIRECTORY}")
endfunction ()

# Links any other target to current service target.
# Part of service configuration top level routine.
function (sober_service_add_api_dependency TARGET)
    message (STATUS "    Adding API dependency: \"${TARGET}\".")
    sober_target_link_libraries (${SOBER_SERVICE_TARGET} INTERFACE "${TARGET}")
endfunction ()

# Informs Sober that given service API will include implementation headers (for example, with template
# implementations), therefore variants of libraries, that use this services, must be compiled separately.
# Part of service configuration top level routine. Should be called before implementation additions.
function (sober_service_require_implementation_headers)
    if (SOBER_IMPLEMENTATION_REGISTRATION_STARTED)
        message (SEND_ERROR
                "Sober: caught attempt to add implementation headers requirement after implementation registrations!")
    endif ()

    message (STATUS "    Implementation headers are REQUIRED by API headers!")
    set_property (TARGET ${SOBER_SERVICE_TARGET} PROPERTY INTERFACE_USES_IMPLEMENTATION_HEADERS TRUE)
    set (SOBER_IMPLEMENTATION_DEPENDENCIES_SCOPE "PUBLIC" PARENT_SCOPE)
endfunction ()

# Adds implementation from given directory to current service.
# Part of service configuration top level routine.
function (sober_service_add_implementation IMPLEMENTATION_DIRECTORY)
    message (STATUS "    Adding implementation from \"${IMPLEMENTATION_DIRECTORY}\".")
    set (SOBER_IMPLEMENTATION_REGISTRATION_STARTED TRUE PARENT_SCOPE)
    add_subdirectory (${IMPLEMENTATION_DIRECTORY})
endfunction ()

# Selects service default implementation. Every service must have default implementation.
# Also this method should be called after given implementation addition.
# Part of service configuration top level routine.
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

    sober_naming_implementation_target (
            "${SOBER_SERVICE_NAME}" "${IMPLEMENTATION_NAME}" IMPLEMENTATION_TARGET)

    if (NOT TARGET "${IMPLEMENTATION_TARGET}")
        message (SEND_ERROR "\
Sober: unable to make \"${IMPLEMENTATION_NAME}\" default implementation for service \
\"${SOBER_SERVICE_NAME}\", because there is no target with name \"${IMPLEMENTATION_TARGET}\"!")
        return ()
    endif ()

    set_property (TARGET ${SOBER_SERVICE_TARGET}
            PROPERTY INTERFACE_SERVICE_DEFAULT_IMPLEMENTATION ${IMPLEMENTATION_NAME})

    message (STATUS "        Implementation \"${IMPLEMENTATION_NAME}\" selected as default implementation!")
endfunction ()

# Service configuration top level routine closer.
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

# Implementation configuration secondary level routine opener. Part of service configuration top level routine.
function (sober_implementation_begin IMPLEMENTATION_NAME)
    message (STATUS "        Implementation \"${IMPLEMENTATION_NAME}\" configuration started.")
    if (NOT DEFINED SOBER_SERVICE_NAME)
        message (FATAL_ERROR "Sober: sober_begin_implementation called outside of service definition!")
    endif ()

    set (SOBER_IMPLEMENTATION_NAME ${IMPLEMENTATION_NAME} PARENT_SCOPE)
    sober_naming_implementation_target (
            "${SOBER_SERVICE_NAME}" "${IMPLEMENTATION_NAME}" SOBER_IMPLEMENTATION_TARGET)
    set (SOBER_IMPLEMENTATION_TARGET "${SOBER_IMPLEMENTATION_TARGET}" PARENT_SCOPE)

    # If implementation library type is INTERFACE, we must override implementation dependencies scope to INTERFACE too,
    # otherwise dependency linking will not be done correctly. Implementation dependencies scope will be overridden 
    # only if it was PUBLIC, otherwise error will be reported.
    set (SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE "${SOBER_IMPLEMENTATION_DEPENDENCIES_SCOPE}" PARENT_SCOPE)
endfunction ()

# Part of implementation configuration secondary level routine.
function (sober_implementation_setup_target LIBRARY_TYPE LIBRARY_SOURCES)
    message (STATUS "            Adding implementation library \"${SOBER_IMPLEMENTATION_TARGET}\".")
    message (STATUS "            Library type is \"${LIBRARY_TYPE}\".")
    add_library ("${SOBER_IMPLEMENTATION_TARGET}" ${LIBRARY_TYPE} ${LIBRARY_SOURCES})

    if ("${LIBRARY_TYPE}" STREQUAL "INTERFACE")
        if ("${SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE}" STREQUAL "PRIVATE")
            message (SEND_ERROR
                    "Implementation library type can be INTERFACE only if service requires implementation headers!")
        else ()
            set (SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE "INTERFACE" PARENT_SCOPE)
        endif ()
    endif ()
endfunction ()

# Part of implementation configuration secondary level routine.
function (sober_implementation_include_directory DIRECTORY)
    message (STATUS "\
            Including directory \"${DIRECTORY}\" to \"${SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE}\" scope.")
    target_include_directories ("${SOBER_IMPLEMENTATION_TARGET}"
            "${SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE}" ${DIRECTORY})
endfunction ()

# Part of implementation configuration secondary level routine.
function (sober_implementation_link_library LIBRARY)
    message (STATUS
            "            Linking library \"${LIBRARY}\" to \"${SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE}\" scope.")
    sober_target_link_libraries ("${SOBER_IMPLEMENTATION_TARGET}"
            "${SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE}" ${LIBRARY})
endfunction ()

# Part of implementation configuration secondary level routine.
function (sober_implementation_public_compile_options)
    message (STATUS "            Appending public compile options: ${ARGV}.")
    target_compile_options ("${SOBER_IMPLEMENTATION_TARGET}" PUBLIC ${ARGV})
endfunction ()

# Part of implementation configuration secondary level routine.
function (sober_implementation_private_compile_options)
    message (STATUS "            Appending private compile options: ${ARGV}.")
    target_compile_options ("${SOBER_IMPLEMENTATION_TARGET}" PRIVATE ${ARGV})
endfunction ()

# Part of implementation configuration secondary level routine.
function (sober_implementation_interface_compile_options)
    message (STATUS "            Appending interface compile options: ${ARGV}.")
    target_compile_options ("${SOBER_IMPLEMENTATION_TARGET}" INTERFACE ${ARGV})
endfunction ()

# Implementation configuration secondary level routine closer. Part of service configuration top level routine.
function (sober_implementation_end)
    # API includes must be affected by dependencies scope too, otherwise
    # library link variants will always expose used services APIs.
    sober_target_link_libraries ("${SOBER_IMPLEMENTATION_TARGET}"
            "${SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE}" ${SOBER_SERVICE_TARGET})

    message (STATUS "        Implementation \"${SOBER_IMPLEMENTATION_NAME}\" configuration finished.")
    unset (SOBER_IMPLEMENTATION_NAME PARENT_SCOPE)
    unset (SOBER_IMPLEMENTATION_TARGET PARENT_SCOPE)
    unset (SOBER_THIS_IMPLEMENTATION_DEPENDENCIES_SCOPE PARENT_SCOPE)
endfunction ()
