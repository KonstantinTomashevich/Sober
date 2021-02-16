sober_set_service_implementation_name (TestStub)
sober_set_service_implementation_include_directories (Source)
set (TARGET_NAME ${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME})

file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_library (${TARGET_NAME} STATIC ${HEADERS} ${SOURCES})
target_link_libraries (${TARGET_NAME} DisplayTestStub)
sober_keep_global_constants ()
