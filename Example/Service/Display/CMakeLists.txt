sober_service_begin (Display)
    sober_service_include_directory ("${CMAKE_CURRENT_SOURCE_DIR}/API")
    # sober_service_require_implementation_headers ()

    sober_service_add_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/ConsoleASCII")
    sober_service_add_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/TestStub")
    sober_service_set_default_implementation (ConsoleASCII)
sober_service_end ()