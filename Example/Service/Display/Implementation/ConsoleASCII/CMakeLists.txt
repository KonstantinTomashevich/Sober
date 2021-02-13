sober_suggest_service_implementation_target_name (TARGET_NAME)
sober_declare_service_implementation_target_name (${TARGET_NAME})

file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_library (${TARGET_NAME} STATIC ${HEADERS} ${SOURCES})
target_link_libraries (${TARGET_NAME} PRIVATE DisplayConsoleASCII)
