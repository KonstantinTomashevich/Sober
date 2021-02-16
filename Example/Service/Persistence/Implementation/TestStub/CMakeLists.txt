sober_set_service_implementation_name (TestStub)
# TODO: Think again about include directories. Maybe this setter is unnecessary and implementation include
#       directories could be implicitly passed to users through of target_include_directories usage?
sober_set_service_implementation_include_directories (${CMAKE_CURRENT_SOURCE_DIR})
set (TARGET_NAME ${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME})

file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_library (${TARGET_NAME} STATIC ${HEADERS} ${SOURCES})
target_link_libraries (${TARGET_NAME} TestStubPersistenceOriginal)
sober_keep_global_constants ()
