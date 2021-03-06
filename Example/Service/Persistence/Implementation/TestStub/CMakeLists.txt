sober_set_service_implementation_name (TestStub)
set (TARGET_NAME ${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME})

file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_library (${TARGET_NAME} STATIC ${HEADERS} ${SOURCES})
target_include_directories (${TARGET_NAME} ${SOBER_IMPLEMENTATION_INCLUDES_SCOPE} ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries (${TARGET_NAME} PRIVATE TestStubPersistenceOriginal)
