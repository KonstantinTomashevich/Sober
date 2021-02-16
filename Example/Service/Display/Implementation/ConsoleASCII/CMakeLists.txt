sober_set_service_implementation_name (ConsoleASCII)
sober_set_service_implementation_include_directories (${CMAKE_CURRENT_SOURCE_DIR})
set (TARGET_NAME ${SOBER_SERVICE_IMPLEMENTATION_TARGET_NAME})

file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_library (${TARGET_NAME} STATIC ${HEADERS} ${SOURCES})
# TODO: We want to have both separate DisplayConsoleASCII library and ConsoleASCII Display implementation.
#       Think about naming conventions for libraries and service implementations.
target_link_libraries (${TARGET_NAME} PRIVATE ConsoleASCIIDisplayOriginal)
sober_keep_global_constants ()