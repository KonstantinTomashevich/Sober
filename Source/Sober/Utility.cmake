include_guard (GLOBAL)
# TODO: Is constant good term? CMake allows changing any variable.
unset (SOBER_GLOBAL_CONSTANTS)

macro (sober_make_variable_global_constant VARIABLE_NAME)
    # TODO: Checks if it is already registered?
    set (${VARIABLE_NAME} "${${VARIABLE_NAME}}" PARENT_SCOPE)
    list (APPEND SOBER_GLOBAL_CONSTANTS ${VARIABLE_NAME})
endmacro ()

macro (sober_keep_global_constants)
    set (SOBER_GLOBAL_CONSTANTS "${SOBER_GLOBAL_CONSTANTS}" PARENT_SCOPE)
    foreach (CONSTANT_NAME IN LISTS SOBER_GLOBAL_CONSTANTS)
        set (${CONSTANT_NAME} "${${CONSTANT_NAME}}" PARENT_SCOPE)
    endforeach ()
endmacro ()