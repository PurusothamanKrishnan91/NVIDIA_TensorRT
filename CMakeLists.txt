cmake_minimum_required(VERSION 2.8)
project( opfl )
include(cmake/CMakePrintHelpers.cmake)

find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )

addSubDirectory(src/opfl)
