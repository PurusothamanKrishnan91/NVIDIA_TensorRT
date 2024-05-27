#/ /bin/bash

set -ex

CUDA_VERSION="12.0"
CUDNN_VERSION="9.1.1"
TRT_VERSION="8.6.1"
TRT_INSTALL_PATH="/usr"

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as a sudo user."
  exit 1
fi

ROOT_DIR=$( dirname $( dirname -- "$( readlink -f -- "$0" )" ))
source $ROOT_DIR/set_workspace

architecture=$(uname -m)
os_name=$(grep -oP '^NAME="\K[^"]+' /etc/os-release)
os_version_id=$(grep -oP '^VERSION_ID="\K[^"][0-9]{1,2}.[0-9]{1,2}' /etc/os-release)
distro=$os_name-$os_version_id

TRT_BASE_PATH="https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/secure"
TRT_EXT1="tars"
TRT_EXT2="TensorRT-"
TRT_MINOR2="6"
TRT_TAR_NAME=$TRT_EXT2$TRT_VERSION.$TRT_MINOR2.$distro.$architecture-gnu.cuda-$CUDA_VERSION.tar.gz
TAR_PATH=$TRT_BASE_PATH/$TRT_VERSION/$TRT_EXT1/$TRT_TAR_NAME

TRT_INSTALL_VERSION=$TRT_EXT2$TRT_VERSION.$TRT_MINOR2

if [ -d $TRT_INSTALL_PATH/$TRT_INSTALL_VERSION ]; then
  echo "Tension RT is already installed in $TRT_INSTALL_PATH/$TRT_INSTALL_VERSION path. Setting Variables"
  export PATH="$TRT_INSTALL_PATH/$TRT_INSTALL_VERSION/bin:$PATH"
  export LD_LIBRARY_PATH="$TRT_INSTALL_PATH/$TRT_INSTALL_VERSION/lib:$LD_LIBRARY_PATH"
  exit 0
fi
pushd  $WORKSPACE_DIR

if [ -e $TRT_TAR_NAME ]; then
    echo "File Exist... Installing"
else
    echo "File doesn't exist. Downloading from $TAR_PATH"
    wget $TAR_PATH
fi

tar -xzvf $TRT_TAR_NAME -C /usr
popd
