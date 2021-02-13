# TODO: Add default CMake boilerplate.

project (SoberExample)

add_subdirectory (Executable)
add_subdirectory (Library)
# WARNING: All targets, that use services, must be defined before service definitions.
add_subdirectory (Service)