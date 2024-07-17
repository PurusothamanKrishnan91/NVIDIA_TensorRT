#!/bin/bash

set +ex

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as a sudo user."
  exit 1
fi

OCV_VERSION=4.4.0
# Removed older version of OPENCV
apt purge libopencv-dev libopencv-python libopencv-samples libopencv* -y

apt install build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev python3-pip python3-numpy -y
#install gstramer
apt install gstreamer1.0* -y
apt install ubuntu-restricted-extras -y
apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev -y


if [ -z $1 ]; then
    echo "using Default version of openCV: $OCV_VERSION"
else
    echo "using $1 version of openCV"
    OCV_VERSION=$1
fi

mkdir -p tmpWorkspace
cd ./tmpWorkspace
git clone https://github.com/opencv/opencv.git -b $OCV_VERSION --depth 1

git clone https://github.com/opencv/opencv_contrib.git -b $OCV_VERSION --depth 1

cd opencv
mkdir -p build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_GENERATE_PKGCONFIG=ON -D BUILD_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=OFF -D INSTALL_C_EXAMPLES=OFF -D PYTHON_EXECUTABLE=$(which python2) -D BUILD_opencv_python2=OFF -D PYTHON3_EXECUTABLE=$(which python3) -D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") -D ENABLE_PRECOMPILED_HEADERS=OFF  -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/ -D WITH_GSTREAMER=ON -D WITH_CUDA=OFF  ..

make -j8
make install
ldconfig