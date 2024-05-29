#!/bin/bash

set -ex

INSTALL_CMAKE_VERSION="3.22"

checkVersion() {
    STRING_MATCH=$(echo $1 | grep -v -E "'[0-9]{1,2}\.[0-9]{1,2}")
    if [ $STRING_MATCH != "" ]; then
        echo 1
    else
        echo 0
    fi
}


maxVersion() {
    INSTALLED_VERSION=$1
    NEW_VERSION=$2
    if [ $(echo -e "$INSTALLED_VERSION\n$NEW_VERSION" | sort -Vr | head -n 1) == $INSTALLED_VERSION ]; then
        echo $INSTALLED_VERSION
    else
        echo $NEW_VERSION
    fi
}

verifyCurlInstllation() {
    which curl
    if [ $? -ne 0 ]; then
        echo 1
    else
        echo 0
    fi
}
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as a sudo user."
  exit 1
fi
echo "Number of arguments: $#"
echo "All arguments: '$@'"
echo "First argument: '$1'"

ROOT_DIR=$( dirname $( dirname -- "$( readlink -f -- "$0" )" ))
source $ROOT_DIR/set_workspace
echo $1
if [[ -z "$1" ]]; then 
    echo "Input version is None. Using Default Version"
else
    retval=$(checkVersion $1)
    if [ $retval -eq 0 ]; then
        echo "Input Version is not valid. Using Default Version:$INSTALL_CMAKE_VERSION"
    else
        INSTALL_CMAKE_VERSION=$1
    fi
fi


CMAKE_VERSION=$(cmake --version | grep -E '[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}' | cut -d ' ' -f 3)

if [ ${CMAKE_VERSION} != "" ]; then
    echo "CMAKE is installed...Version: $CMAKE_VERSION"
    CMAKE_VERSION=$(echo ${CMAKE_VERSION} | grep -o -E '[0-9]{1,2}\.[0-9]{1,2}')
    REQ_VERSION=$(maxVersion $CMAKE_VERSION $INSTALL_CMAKE_VERSION)
    if [ $CMAKE_VERSION != $REQ_VERSION ]; then
        echo "Required Version is newer than installed...Version: $REQ_VERSION"
        echo "installing..."
    else
        echo "Required Version is installed...Version: $REQ_VERSION"
        exit 0
    fi
fi


apt-get install build-essential
CMAKE_REQ_PATH=https://cmake.org/files
CMAKE_BASE_PATH=https://www.cmake.org/files
INSTALL_CMAKE_VERSION=$REQ_VERSION

curlStatus=$(verifyCurlInstllation)

if [ $curlStatus -ne 0 ]; then
    echo "Curl is not installed. Installing"
    apt update
    apt install -y curl
    curlStatus=$(verifyCurlInstllation)
    if [ $curlStatus -ne 0 ]; then 
        echo "Curl installation Failed..! Exiting..!"
        exit 128
    else
        echo "Curl Installation successful"
    fi
fi
CMAKE_VERSION_PATH="${CMAKE_REQ_PATH}/v${INSTALL_CMAKE_VERSION}/"
echo $CMAKE_VERSION_PATH
LATEST_CMAKE_VERSION=$(curl --silent $CMAKE_VERSION_PATH | grep -o 'href=".*">' | grep -o 'href=".*">'  | cut -d'"' -f 2 | grep -o -E 'cmake-[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}' | sort -V | tail -n 1)

pushd  $WORKSPACE_DIR

wget "${CMAKE_BASE_PATH}/v${INSTALL_CMAKE_VERSION}/${LATEST_CMAKE_VERSION}.tar.gz"

tar zxvf ${LATEST_CMAKE_VERSION}.tar.gz

cd ${LATEST_CMAKE_VERSION}
./configure
make clean
make 
make install

popd

