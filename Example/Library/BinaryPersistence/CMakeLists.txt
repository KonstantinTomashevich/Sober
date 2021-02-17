sober_begin_library (BinaryPersistence STATIC)
    file (GLOB_RECURSE SOURCES *.cpp)
    file (GLOB_RECURSE HEADERS *.hpp)
    list (APPEND SOURCES ${HEADERS})

    sober_set_library_sources ("${SOURCES}")
    sober_add_library_include_directories (PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

    sober_begin_variant (Original)
    sober_end_variant ()
sober_end_library ()
sober_keep_global_constants ()