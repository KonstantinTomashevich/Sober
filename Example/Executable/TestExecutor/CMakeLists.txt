file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_executable (TestExecutor ${HEADERS} ${SOURCES})
sober_internal_get_variant_target_name (ApplicationLogic Test TEST_LOGIC_TARGET)
target_link_libraries (TestExecutor PRIVATE "${TEST_LOGIC_TARGET}")