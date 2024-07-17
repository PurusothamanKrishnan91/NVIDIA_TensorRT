set(PROJECT_INCLUDES "" CACHE STRING "Global Include include directories")


function (addSubDirectory dir_name)
      # Add sub directories
      add_subdirectory(${dir_name})
      set(PROJECT_INCLUDES "${PROJECT_INCLUDES};${CMAKE_SOURCE_DIR}/${dir_name}" CACHE STRING "Global Includes" FORCE)
      include_directories(${CMAKE_SOURCE_DIR}/${dir_name})
endfunction()