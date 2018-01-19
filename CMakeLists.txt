cmake_minimum_required(VERSION 2.8)

project(NTUcd)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -O3 -std=c++17 -fopenmp -ffast-math")

add_executable(
	NTUcd
	src/main.cpp
	src/RTL.cpp
	src/Util.cpp
)

find_package(Boost REQUIRED COMPONENTS system)

target_link_libraries(
	NTUcd
	${Boost_SYSTEM_LIBRARY} 
)
