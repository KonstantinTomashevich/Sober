sober_begin_library (ApplicationLogic STATIC)
    sober_use_service (Display)
    sober_use_service (Persistence)

    file (GLOB_RECURSE SOURCES *.cpp)
    file (GLOB_RECURSE HEADERS *.hpp)
    list (APPEND SOURCES ${HEADERS})

    sober_set_library_sources ("${SOURCES}")
    sober_add_library_include_directories (PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")

    sober_begin_variant (Production)
    sober_end_variant ()

    sober_begin_variant (Test)
        # sober_set_default_service_implementation (ServiceName ImplementationName)
        sober_freeze_service_implementation (Display TestStub)
        sober_freeze_service_implementation (Persistence TestStub)
    sober_end_variant ()
sober_end_library ()
sober_keep_global_constants ()