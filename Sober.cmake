# Sober.cmake is Sober umbrella script, that includes all other Sober scripts.
# But if it is required, Sober modules can be included independently.

# Common terms, that will be used in comments in script modules:
#
# - Top level routine opener is a function, that opens top level configuration routine (like service or
#   library routine) and should not be called inside any other configuration routine.
#
# - Top level routine closer is a function, that closes current top level configuration routine.
#   Should not be called if there is no active top level routine of same type or if current routine is not top level.
#
# - Secondary level routine opener is a function, that opens secondary level configuration routine (like implementation
#   or variant routine). Should be called inside according top level routine and not inside any other secondary level
#   routine.
#
# - Secondary level routine closer is a function, that closes current secondary level configuration routine.
#   Should not be called if there is no active secondary level routine of same type.

include_guard (GLOBAL)
message (STATUS "Including Sober framework. Branch: master.")

include (${CMAKE_CURRENT_LIST_DIR}/Naming.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Library.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Service.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Test.cmake)
include (${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)
