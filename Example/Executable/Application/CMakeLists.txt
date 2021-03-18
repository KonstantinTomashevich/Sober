file (GLOB_RECURSE SOURCES *.cpp)
file (GLOB_RECURSE HEADERS *.hpp)

add_executable (Application ${HEADERS} ${SOURCES})
sober_naming_variant_target (ApplicationLogic Production PRODUCTION_LOGIC_TARGET)
target_link_libraries (Application PRIVATE "${PRODUCTION_LOGIC_TARGET}")