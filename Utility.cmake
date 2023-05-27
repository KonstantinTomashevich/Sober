define_property (TARGET PROPERTY DIRECTLY_LINKED_LIBRARIES
        BRIEF_DOCS "Contains list of all targets linked to current one using sober_target_link_libraries."
        FULL_DOCS "Currently, CMake is not able to provide full list of linked targets, therefore we maintain this one.")

# Adapter for target_link_libraries, that also maintains DIRECTLY_LINKED_LIBRARIES property.
function (sober_target_link_libraries)
    target_link_libraries (${ARGV})
    get_target_property (LINKED_LIBRARIES "${ARGV0}" DIRECTLY_LINKED_LIBRARIES)

    if (LINKED_LIBRARIES STREQUAL "LINKED_LIBRARIES-NOTFOUND")
        set (LINKED_LIBRARIES)
    endif ()

    foreach (ARG_INDEX RANGE 1 ${ARGC})
        set (ARG "${ARGV${ARG_INDEX}}")
        if (NOT "${ARG}" STREQUAL "" AND
                NOT "${ARG}" STREQUAL "PUBLIC" AND
                NOT "${ARG}" STREQUAL "PRIVATE" AND
                NOT "${ARG}" STREQUAL "INTERFACE")
            list (APPEND LINKED_LIBRARIES "${ARG}")
        endif ()
    endforeach ()

    set_target_properties ("${ARGV0}" PROPERTIES DIRECTLY_LINKED_LIBRARIES "${LINKED_LIBRARIES}")
endfunction ()

# Uses DIRECTLY_LINKED_LIBRARIES property to traverse full linked target tree of given TARGET.
# Stores full list of traversed linked targets in variable with name equal to OUTPUT.
function (sober_find_linked_targets_recursively TARGET OUTPUT)
    set (ALL_LINKED_TARGETS)
    set (SCAN_QUEUE)
    list (APPEND SCAN_QUEUE ${TARGET})
    list (LENGTH SCAN_QUEUE SCAN_QUEUE_LENGTH)

    while (SCAN_QUEUE_LENGTH GREATER 0)
        list (POP_BACK SCAN_QUEUE ITEM)
        if (TARGET ${ITEM})
            get_target_property (LINKED_TARGETS ${ITEM} DIRECTLY_LINKED_LIBRARIES)

            if (NOT "${LINKED_TARGETS}" STREQUAL "LINKED_TARGETS-NOTFOUND")
                foreach (LINKED_TARGET ${LINKED_TARGETS})
                    if (TARGET ${LINKED_TARGET})
                        list (FIND ALL_LINKED_TARGETS "${LINKED_TARGET}" LINKED_TARGET_INDEX)
                        if (LINKED_TARGET_INDEX EQUAL -1)
                            list (APPEND ALL_LINKED_TARGETS ${LINKED_TARGET})
                            list (APPEND SCAN_QUEUE ${LINKED_TARGET})
                        endif ()
                    endif ()
                endforeach ()
            endif ()
        endif ()

        list (LENGTH SCAN_QUEUE SCAN_QUEUE_LENGTH)
    endwhile ()

    set ("${OUTPUT}" "${ALL_LINKED_TARGETS}" PARENT_SCOPE)
endfunction ()

# Scanes current directory and all its subdirectories to find all executables and shared libraries.
# Then uses sober_find_linked_targets_recursively on every found target in order to find all object
# libraries that are indirectly linked to executable or shared library. Then links these object
# library to executable or shared library target.
#
# This function is needed to make object library linkage recursive like static library linkage.
function (sober_post_link_object_libraries)
    set (SCAN_QUEUE)
    list (APPEND SCAN_QUEUE ${CMAKE_CURRENT_SOURCE_DIR})

    list (LENGTH SCAN_QUEUE SCAN_QUEUE_LENGTH)

    while (SCAN_QUEUE_LENGTH GREATER 0)
        list (POP_BACK SCAN_QUEUE ITEM)

        get_property (DIRECTORY_TARGETS DIRECTORY ${ITEM} PROPERTY BUILDSYSTEM_TARGETS)
        if (NOT "${DIRECTORY_TARGETS}" STREQUAL "DIRECTORY_TARGETS-NOTFOUND")
            foreach (TARGET ${DIRECTORY_TARGETS})
                get_target_property (TARGET_TYPE ${TARGET} TYPE)

                if ("${TARGET_TYPE}" STREQUAL "EXECUTABLE" OR "${TARGET_TYPE}" STREQUAL "SHARED_LIBRARY")
                    sober_find_linked_targets_recursively ("${TARGET}" TARGET_LINKED_LIBRARIES)

                    foreach (LINKED_TARGET ${TARGET_LINKED_LIBRARIES})
                        get_target_property (LINKED_TARGET_TYPE ${LINKED_TARGET} TYPE)

                        if ("${LINKED_TARGET_TYPE}" STREQUAL "OBJECT_LIBRARY")
                            target_link_libraries ("${TARGET}" PUBLIC ${LINKED_TARGET})
                        endif ()
                    endforeach ()
                endif ()
            endforeach ()
        endif ()

        get_property (SUBDIRECTORIES DIRECTORY ${ITEM} PROPERTY SUBDIRECTORIES)
        if (NOT "${SUBDIRECTORIES}" STREQUAL "SUBDIRECTORIES-NOTFOUND")
            list (APPEND SCAN_QUEUE ${SUBDIRECTORIES})
        endif ()

        list (LENGTH SCAN_QUEUE SCAN_QUEUE_LENGTH)
    endwhile ()
endfunction ()
