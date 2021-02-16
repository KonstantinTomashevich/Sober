sober_begin_service (Persistence)
    sober_set_service_include_directories ("${CMAKE_CURRENT_SOURCE_DIR}/API")
    # sober_add_implementation_headers_requirement ()

    sober_add_default_service_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/Binary")
    sober_add_service_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/PlainText")
    sober_add_service_implementation ("${CMAKE_CURRENT_SOURCE_DIR}/Implementation/TestStub")
sober_end_service ()

sober_keep_global_constants ()