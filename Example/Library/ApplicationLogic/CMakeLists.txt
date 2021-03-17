sober_library_begin (ApplicationLogic STATIC)
    sober_library_use_service (Display PRIVATE)
    sober_library_use_service (Persistence PRIVATE)

    file (GLOB_RECURSE SOURCES *.cpp)
    file (GLOB_RECURSE HEADERS *.hpp)
    list (APPEND SOURCES ${HEADERS})

    sober_library_set_sources ("${SOURCES}")
    sober_library_include_directory (PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

    sober_variant_begin (Production)
    sober_variant_end ()

    sober_variant_begin (Test)
        # sober_variant_set_default_implementation (ServiceName ImplementationName)
        sober_variant_freeze_implementation (Display TestStub)
        sober_variant_freeze_implementation (Persistence TestStub)
    sober_variant_end ()
sober_library_end ()