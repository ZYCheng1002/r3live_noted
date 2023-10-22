# boost
FIND_PACKAGE(Boost REQUIRED COMPONENTS filesystem iostreams program_options system serialization)
if (Boost_FOUND)
    INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIRS})
    LINK_DIRECTORIES(${Boost_LIBRARY_DIRS})
endif ()

#ceres
#find_package(Ceres REQUIRED)

# PCL
find_package(PCL REQUIRED)
include_directories(${PCL_INCLUDE_DIRS})

# OpenCV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# Find OpenMP
FIND_PACKAGE(OpenMP)
if (OPENMP_FOUND)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    #cmake only check for separate OpenMP library on AppleClang 7+
    #https://github.com/Kitware/CMake/blob/42212f7539040139ecec092547b7d58ef12a4d72/Modules/FindOpenMP.cmake#L252
    if (CMAKE_CXX_COMPILER_ID MATCHES "AppleClang" AND (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0"))
        SET(OpenMP_LIBS ${OpenMP_libomp_LIBRARY})
        LIST(APPEND OpenMVS_EXTRA_LIBS ${OpenMP_LIBS})
    endif ()
else ()
    message("-- Can't find OpenMP. Continuing without it.")
endif ()

# OpenMVS
find_package(OpenMVS)
if (OpenMVS_FOUND)
    include_directories(${OpenMVS_INCLUDE_DIRS})
    add_definitions(${OpenMVS_DEFINITIONS})
endif ()

# ros
find_package(catkin REQUIRED COMPONENTS
        roscpp
        rospy
        std_msgs
        geometry_msgs
        nav_msgs
        tf
        cv_bridge
)

# cgal
find_package(CGAL REQUIRED)
include_directories(${CGAL_INCLUDE_DIRS})

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
find_package(Eigen3)