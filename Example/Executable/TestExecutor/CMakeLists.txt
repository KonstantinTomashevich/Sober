file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_executable (TestExecutor ${HEADERS} ${SOURCES})
sober_naming_variant_target (ApplicationLogic Test TEST_LOGIC_TARGET)
target_link_libraries (TestExecutor PRIVATE "${TEST_LOGIC_TARGET}")