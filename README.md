# Sober CMake framework

**Sober** stands for **S**ervice **O**riented **B**uild**er**, compact CMake 
framework for API-Implementation separation on build configuration level. 

## Features

- **Sober** allows hide complex libraries functionality under 
  implementation-agnostic APIs, called **Services**. Build variables allow 
  users to select both common **service** implementation for all dependant 
  libraries and custom **service** implementation for some special library. 
  
- **Sober** allows to create multiple **link variants** for one library. This 
  allows users to create two versions of their library with different 
  **service** implementations without compiling it twice: test version with 
  mock **services** and production version with the real ones.