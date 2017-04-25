cmake_minimum_required(VERSION 2.8.9)
project (hello)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

find_library(CONFIG_LIBRARY
    NAMES config++ libconfig++
)

find_package(PerlLibs REQUIRED)

include_directories(${PERL_INCLUDE_PATH})

add_executable(hello hello.cpp)
target_link_libraries(hello ${CONFIG_LIBRARY} ${PERL_LIBRARY})
