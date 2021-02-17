cmake_minimum_required (VERSION 3.17)
project (SoberExample)

set (CMAKE_CXX_STANDARD 17)
include (${SOBER_PATH}/Sober.cmake)

# WARNING: All targets, that use services, must be defined after service definitions.
add_subdirectory (Service)
add_subdirectory (Executable)
add_subdirectory (Library)