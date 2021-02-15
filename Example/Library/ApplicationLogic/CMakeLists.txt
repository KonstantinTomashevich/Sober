sober_begin_library (ApplicationLogic STATIC)
    sober_use_service (Display)
    sober_use_service (Persistence)
    sober_library_sources (${HEADERS} ${SOURCES})

    sober_begin_variant (Production STATIC)
    sober_end_variant ()

    sober_begin_variant (Test STATIC)
        # sober_set_default_service_implementation (ServiceName ImplementationName)
        sober_freeze_service_implementation (Display TestStub)
        sober_freeze_service_implementation (Persistence TestStub)
    sober_end_variant ()
sober_end_library ()