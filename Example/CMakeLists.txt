cmake_minimum_required (VERSION 3.17)
project (SoberExample)

add_subdirectory (Executable)
add_subdirectory (Library)
# WARNING: All targets, that use services, must be defined before service definitions.
add_subdirectory (Service)