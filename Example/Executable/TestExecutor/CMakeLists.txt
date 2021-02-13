file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_executable (TestExecutor ${HEADERS} ${SOURCES})
target_link_libraries (TestExecutor ApplicationLogicTest)