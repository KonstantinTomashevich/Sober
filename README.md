# Sober CMake framework [WIP]

**Sober** stands for **S**ervice **O**riented **B**uild**er**, compact CMake
framework for API-Implementation separation on build configuration level.

## Terms

- **Service** is an interface target with API headers. Should be
  implementation-agnostic, but could use implementation-specific includes,
  if need arises.

- **Implementation** is a library target, that completely implements
  **Service**. Usually it hides other **Library** or third party target
  under **Service** API.

- **Library** is a family of library targets with same sources and dependencies,
  that has **Service**s among other dependencies. Each **Library** has one or
  more **Variant**s, that link library source code with specified **Service**
  **Implementation**s.

- **Variant** is target from **Library**, that is linked with specified
  **Service** **Implementation**s. If all used **Service**s are
  implementation-agnostic **Variant**s will share compiled library objects.

## Features

- **Sober** allows to hide complex library details under simple
  implementation-agnostic API, therefore making it easier
  to switch implementation library if need arises.

- **Sober** allows to setup multiple instances of one library, that depend on
  different implementations, by creating **Library** target family with
  **Variant**s as library instances. This principle makes it's easy to provide
  library instances with dependency sets, that are optimized for particular
  tasks, or to provide library instance with test mocks instead of dependencies.
  
- **Sober** allows to specify **Implementation**s for **Variant**s from command 
  line, therefore making it easy to use different implementations for different 
  build types. For example, you can use plain text serializer for debug 
  builds, so you can easily check output files, and binary serializer for 
  release builds for better performance.

## Cheat sheet

### Setup service

```cmake
# Service root CMakeLists.txt.
sober_service_begin (<ServiceName>)
    sober_service_include_directory (<PathToAPIHeadersDir>)
    # You can add multiple include directories by calling 
    # sober_service_include_directory multiple times.
    
    # You can add other service headers to your service, but then each implementation 
    # of your service must provide implementation of this base service.
    sober_service_add_api_dependency (<OtherBaseService>)

    # If your service is NOT implementation-agnostic, uncomment next line.
    # sober_service_require_implementation_headers ()
    
    sober_service_add_implementation (<PathToImplementationDirectory>)
    # You can add multiple implementations by calling 
    # sober_service_add_implementation multiple times.

    # Default implementation, that will be used if particular implementation 
    # wasn't specified using command line or during library setup.
    sober_service_set_default_implementation (<DefaultImplementationName>)
sober_service_end ()

# Implementation CMakeLists.txt.
sober_implementation_begin (<ImplementationName>)    
    sober_implementation_setup_target (<STATIC|SHARED> <Source>...)

    # If service is implementation-agnostic, implementation headers will be 
    # private. Otherwise they will be visible to service users.
    sober_implementation_include_directory (<ImplementationIncludes>)

    # Lets add library variant as implementation dependency.
    # Also, if service depends on other services, it's better to provide 
    # implementation for this service as public used service inside library variant.

    # Use sober_naming_* functions to get names of targets, that are created by Sober.
    sober_naming_variant_target (<LibraryName> <VariantName> IMPLEMENTATION_LIBRARY_TARGET)
    sober_implementation_link_library ("${IMPLEMENTATION_LIBRARY_TARGET}")
sober_implementation_end ()
```

### Setup library

```cmake
# Library root CMakeLists.txt.
sober_library_begin (<LibraryName> <STATIC|SHARED>)
    # WARNING: Used services must be configured BEFORE libraries that use them!
    # Second parameter defines service usage visibility scope, which is used to 
    # link service and implementation targets to library targets. For example, 
    # if service usage is PRIVATE, library users will not be able to use service API.
    sober_library_use_service (<ServiceName> <PUBLIC|PRIVATE|INTERFACE>)
    # You can add multiple services usage by calling 
    # sober_library_use_service multiple times.

    sober_library_set_sources (<Source>...)
    
    # Adds include directory to all targets from Sober library.
    sober_library_include_directory (<PUBLIC|PRIVATE|INTERFACE> <IncludeDirectory>)
    # You can add multiple include directories to library by calling
    # sober_library_include_directory multiple times.

    # Links CMake library target to all targets from Sober library.
    sober_library_link_library (<PUBLIC|PRIVATE|INTERFACE> <LibraryTargetName>)
    # You can link multiple CMake libraries by calling
    # sober_library_link_library multiple times.

    sober_variant_begin (<VariantName>)
        # Inside variant configuration routine you can customize 
        # service implementation selection for this variant.

        # If you want to both override service default implementation and to allow user
        # to specify other implementation for this variant, use next command:
        sober_variant_set_default_implementation (<ServiceName> <ImplementationName>)

        # If this variant should always use specified implementation, use next command:
        sober_variant_freeze_implementation (<ServiceName> <ImplementationName>)
        
        # If neither sober_variant_set_default_implementation or
        # sober_variant_freeze_implementation was called for used service,
        # this service default implementation will be used instead.
    sober_variant_end ()
    # You can create multiple variants by adding
    # sober_variant_begin - sober_variant_end routine multiple times.
sober_library_end ()
```

## Links

- [Example project.](https://github.com/KonstantinTomashevich/SoberExampleProject)
