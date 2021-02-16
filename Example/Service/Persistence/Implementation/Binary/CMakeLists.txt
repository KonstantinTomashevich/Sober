sober_set_service_implementation_name (Binary)
sober_set_service_implementation_include_directories (${CMAKE_CURRENT_SOURCE_DIR})
set (TARGET_NAME ${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME})

file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_library (${TARGET_NAME} STATIC ${HEADERS} ${SOURCES})
target_link_libraries (${TARGET_NAME} BinaryPersistenceOriginal)
sober_keep_global_constants ()
