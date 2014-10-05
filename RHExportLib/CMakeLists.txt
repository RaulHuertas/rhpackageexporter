cmake_minimum_required(VERSION 2.8)
project (RHExportLib)
FIND_PACKAGE( Boost COMPONENTS system filesystem REQUIRED )

set(PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set(PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR}/src)  

set(    
    ${PROJECT_NAME}_SRCS 
    ${PROJECT_SOURCE_DIR}/StandarExporter_GenerateFinalResult.cpp
    ${PROJECT_SOURCE_DIR}/StandardExporter.cpp
    ${PROJECT_SOURCE_DIR}/RHExportLib.cpp
    ${PROJECT_SOURCE_DIR}/MurmurHasher.cpp
    ${PROJECT_SOURCE_DIR}/MurmurHash3.cpp
    ${PROJECT_SOURCE_DIR}/ExportResult.cpp
    ${PROJECT_SOURCE_DIR}/ExportOptions.cpp
    ${PROJECT_SOURCE_DIR}/Exporter.cpp
    ${PROJECT_SOURCE_DIR}/RHGenerateHashBenchmarkTestData.cpp
    ${PROJECT_SOURCE_DIR}/RHGenerateBinarySearchStats.cpp
)  


include_directories("${PROJECT_INCLUDE_DIR}")
add_library(${PROJECT_NAME} SHARED ${${PROJECT_NAME}_SRCS})
target_include_directories( ${PROJECT_NAME} PUBLIC ${PROJECT_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} ${Boost_LIBRARIES})

IF(CMAKE_COMPILER_IS_GNUCXX)
    MESSAGE(STATUS "GCC detected - Adding compiler flags")
    set (CMAKE_CXX_FLAGS "-std=c++11")
    set (CMAKE_C_FLAGS "-std=c++11")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

