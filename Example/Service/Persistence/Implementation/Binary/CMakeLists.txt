sober_begin_implementation (Binary)
    file (GLOB_RECURSE SOURCES *.cpp)
    file (GLOB_RECURSE HEADERS *.hpp)
    list (APPEND SOURCES ${HEADERS})

    sober_setup_service_implementation_target (STATIC "${SOURCES}")
    sober_implementation_include_directory (${CMAKE_CURRENT_SOURCE_DIR})
    sober_implementation_link_library (BinaryPersistenceOriginal)
sober_end_implementation ()
