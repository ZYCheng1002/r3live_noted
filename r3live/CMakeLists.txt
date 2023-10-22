cmake_minimum_required(VERSION 2.8.3)
project(r3live)

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++14 -O3 -lboost_system -msse2 -msse3 -pthread -Wenum-compare") # -Wall
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_definitions(-DROOT_DIR=\"${CMAKE_CURRENT_SOURCE_DIR}/\")
include(cmake/packages.cmake)
# Add OpenCV if available

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}   ${OpenMP_C_FLAGS}")

find_package(message_generation)

add_message_files(
        FILES
        CustomMsg.msg
        CustomPoint.msg
)

generate_messages(
        DEPENDENCIES
        geometry_msgs
)

catkin_package(CATKIN_DEPENDS
        geometry_msgs roscpp rospy message_runtime)

include_directories(${catkin_INCLUDE_DIRS})

include_directories(
        ${catkin_INCLUDE_DIRS}
        ${EIGEN3_INCLUDE_DIR}
        ./src
        ./src/loam/include
        ./src/tools/
        ./src/rgb_map
        ./src/meshing
)


message(STATUS "===== ${PROJECT_NAME}: OpenCV library status: =====")
message(STATUS "===== OpenCV ersion: ${OpenCV_VERSION}  =====")
message(STATUS "===== OpenCV libraries: ${OpenCV_LIBS} =====")
message(STATUS "===== OpenCV include path: ${OpenCV_INCLUDE_DIRS} =====")

add_executable(r3live_LiDAR_front_end src/loam/LiDAR_front_end.cpp)
target_link_libraries(r3live_LiDAR_front_end ${catkin_LIBRARIES} ${PCL_LIBRARIES})
if (Ceres_FOUND)
    message(STATUS "===== Find ceres, Version ${Ceres_VERSION} =====")
    include_directories(${CERES_INCLUDE_DIRS})
    add_executable(r3live_cam_cali src/r3live_cam_cali.cpp)
    target_link_libraries(r3live_cam_cali ${catkin_LIBRARIES} ${OpenCV_LIBRARIES} ${CERES_LIBRARIES})

    add_executable(r3live_cam_cali_create_cali_board src/r3live_cam_cali_create_cali_board.cpp)
    target_link_libraries(r3live_cam_cali_create_cali_board ${catkin_LIBRARIES} ${OpenCV_LIBRARIES})
endif ()
add_executable(test_timer src/tools/test_timer.cpp)

add_executable(r3live_mapping src/r3live.cpp
        src/r3live_lio.cpp
        src/loam/include/kd_tree/ikd_Tree.cpp
        src/loam/include/FOV_Checker/FOV_Checker.cpp
        src/loam/IMU_Processing.cpp
        src/rgb_map/offline_map_recorder.cpp
        # From VIO
        src/r3live_vio.cpp
        src/optical_flow/lkpyramid.cpp
        src/rgb_map/rgbmap_tracker.cpp
        src/rgb_map/image_frame.cpp
        src/rgb_map/pointcloud_rgbd.cpp
)
target_link_libraries(r3live_mapping
        ${catkin_LIBRARIES}
        ${Boost_LIBRARIES}
        ${Boost_FILESYSTEM_LIBRARY}
        ${Boost_SERIALIZATION_LIBRARY} # serialization
        ${OpenCV_LIBRARIES}
        # ${OpenMVS_LIBRARIES}
        ${PCL_LIBRARIES})


if (CGAL_FOUND)
    add_definitions(${CGAL_DEFINITIONS})
    link_directories(${CGAL_LIBRARY_DIRS})
    ADD_DEFINITIONS(-D_USE_BOOST -D_USE_EIGEN -D_USE_OPENMP)
    SET(_USE_BOOST TRUE)
    SET(_USE_OPENMP TRUE)
    SET(_USE_EIGEN TRUE)
    add_executable(r3live_meshing src/r3live_reconstruct_mesh.cpp
            src/rgb_map/image_frame.cpp
            src/rgb_map/pointcloud_rgbd.cpp
            # Common
            src/meshing/MVS/Common/Common.cpp
            src/meshing/MVS/Common/Log.cpp
            src/meshing/MVS/Common/Timer.cpp
            src/meshing/MVS/Common/Types.cpp
            src/meshing/MVS/Common/Util.cpp
            # MVS
            src/meshing/MVS/Mesh.cpp
            src/meshing/MVS/PointCloud.cpp
            src/meshing/MVS/Camera.cpp
            src/meshing/MVS/Platform.cpp
            src/meshing/MVS/PLY.cpp
            src/meshing/MVS/OBJ.cpp
            src/meshing/MVS/IBFS.cpp
    )
    target_link_libraries(r3live_meshing
            ${catkin_LIBRARIES}
            ${Boost_LIBRARIES}
            ${Boost_FILESYSTEM_LIBRARY}
            ${Boost_SERIALIZATION_LIBRARY} # serialization
            ${CGAL_LIBS}
            ${OpenCV_LIBRARIES}
            ${JPEG_LIBRARIES}
            gmp
            pcl_common
            pcl_io
            pcl_kdtree)

endif ()
