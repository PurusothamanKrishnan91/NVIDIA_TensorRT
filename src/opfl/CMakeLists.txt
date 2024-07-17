add_executable( opfl optical_flow.cpp )
add_executable( opfl_d optical_flow_dense.cpp )

target_link_libraries( opfl ${OpenCV_LIBS} )
target_link_libraries( opfl_d ${OpenCV_LIBS} )