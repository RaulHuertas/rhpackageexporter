cmake_minimum_required(VERSION 2.8)
project (RHPacketServer)


set(PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set(PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR}/src)  

set(    
    ${PROJECT_NAME}_SRCS 
    ${PROJECT_SOURCE_DIR}/RHPacketServer.cpp
)  


include_directories("${PROJECT_INCLUDE_DIR}")
add_executable(${PROJECT_NAME} ${${PROJECT_NAME}_SRCS})
target_link_libraries(${PROJECT_NAME} RHExportLib)
target_link_libraries(${PROJECT_NAME} pthread)


IF(CMAKE_COMPILER_IS_GNUCXX)
    MESSAGE(STATUS "GCC detected - Adding compiler flags")
    set (CMAKE_CXX_FLAGS "-std=c++11")
    set (CMAKE_C_FLAGS "-std=c++11")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

