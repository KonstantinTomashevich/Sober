file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_executable (Application ${HEADERS} ${SOURCES})
sober_internal_get_variant_target_name (ApplicationLogic Production PRODUCTION_LOGIC_TARGET)
target_link_libraries (Application PRIVATE "${PRODUCTION_LOGIC_TARGET}")