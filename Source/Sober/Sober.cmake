# Sober.cmake is Sober umbrella script, that includes all other Sober scripts.
# But if it is required, Sober modules can be included independently.

include_guard (GLOBAL)
message (STATUS "Including Sober framework. Branch: master.")

include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Library.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Service.cmake)