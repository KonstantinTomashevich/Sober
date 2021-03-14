sober_begin_service (Persistence)
    sober_add_service_include_directory ("${CMAKE_CURRENT_SOURCE_DIR}/API")
    # sober_add_implementation_headers_requirement ()

    sober_add_service_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/Binary")
    sober_add_service_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/PlainText")
    sober_add_service_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/TestStub")
    set_default_service_implementation (Binary)
sober_end_service ()