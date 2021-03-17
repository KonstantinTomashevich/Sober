sober_service_begin (Persistence)
    sober_service_include_directory ("${CMAKE_CURRENT_SOURCE_DIR}/API")
    # sober_service_require_implementation_headers ()

    sober_service_add_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/Binary")
    sober_service_add_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/PlainText")
    sober_service_add_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/TestStub")
    sober_service_set_default_implementation (Binary)
sober_service_end ()