cmake_minimum_required(VERSION 2.8.9)
project(tg_assistant)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -g")
set(Boost_USE_MULTITHREADED ON)

find_library(CONFIG_LIBRARY
    NAMES config++ libconfig++
)

execute_process(
    COMMAND perl -MExtUtils::Embed -e xsinit -- -o perlxsi.h
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/
)

find_package(Threads REQUIRED)
find_package(PerlLibs REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Boost COMPONENTS system iostreams REQUIRED)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include ${PERL_INCLUDE_PATH} ${OPENSSL_INCLUDE_DIR} ${Boost_INCLUDE_DIR})

add_executable(tg_assistant src/main.cpp)
target_link_libraries(tg_assistant ${CMAKE_CURRENT_SOURCE_DIR}/lib/libTgBot.a ${CONFIG_LIBRARY} ${PERL_LIBRARY} ${CMAKE_THREAD_LIBS_INIT} ${OPENSSL_LIBRARIES} ${Boost_LIBRARIES})

message(STATUS "Perl version: [${PERL_VERSION}]")
