sober_implementation_begin (PlainText)
    file (GLOB_RECURSE SOURCES *.cpp)
    file (GLOB_RECURSE HEADERS *.hpp)
    list (APPEND SOURCES ${HEADERS})

    sober_implementation_setup_target (STATIC "${SOURCES}")
    sober_implementation_include_directory (${CMAKE_CURRENT_SOURCE_DIR})
    sober_implementation_link_library (PlainTextPersistenceOriginal)
sober_implementation_end ()
