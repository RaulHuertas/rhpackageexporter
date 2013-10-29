cmake_minimum_required(VERSION 2.8)
project (RHServerTools)





if("${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")
   message(SEND_ERROR "In-source builds are not allowed.")
endif("${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")

set(CMAKE_BINARY_DIR ${PROJECT_BINARY_DIR}/build )
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})

set(${PROJECT_NAME}_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include) 

include_directories("${PROJECT_NAME}_INCLUDE_DIR")
add_subdirectory(RHExportLib)
add_subdirectory(PackageCompressor)
add_subdirectory(RHPacketServer)
add_subdirectory(BenchmarkingTest)


