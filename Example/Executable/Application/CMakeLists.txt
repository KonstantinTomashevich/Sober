file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_executable (Application ${HEADERS} ${SOURCES})
target_link_libraries (Application ApplicationLogicProduction)