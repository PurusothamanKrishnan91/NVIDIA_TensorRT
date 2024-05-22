#/ /bin/bash

set +ex
CUDA_VERSION="12.2.2"


if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as a sudo user."
  exit 1
fi
NVIDIA_CUDA_REPO_BASE="https://developer.download.nvidia.com/compute/cuda/repos"
NVIDIA_CUDA_PATH="https://developer.download.nvidia.com/compute/cuda"
PIN_NAME="cuda-"
if [ -z $1 ]; then
    echo "Using Default CUDA version"
    echo $CUDA_VERSION
else
    echo "Using  CUDA version: $1"
    CUDA_VERSION=$1
fi
ROOT_DIR=$( dirname $( dirname -- "$( readlink -f -- "$0" )" ))
source $ROOT_DIR/set_workspace

ret=128
lspci | grep -i nvidia > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "NVIDIA Device is not available.Exiting...!"
    exit 128
else
    echo  "NVIDIA Device found..!"
fi
# Get Operating system details 
architecture=$(uname -m)
if [ $architecture == "aarch64" ]; then
    architecture="arm64"
fi
os_name=$(grep -oP '^NAME="\K[^"]+' /etc/os-release)
os_version=$(grep -oP '^VERSION="\K[^"][0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}.' /etc/os-release)

echo "$os_name"
echo "$os_version"
#get GCC details

gcc --version  > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "GCC is not installed in the system. Installing...!"
    apt update
    apt install build-essential
else
    echo "GCC installed.!"
fi

MAJOR=$(echo $CUDA_VERSION | cut -f1 -d '.')
MINOR=$(echo $CUDA_VERSION | cut -f2 -d '.')
RELEASE=$(echo $CUDA_VERSION | cut -f3 -d '.')

NVCC_PATH="/usr/local/cuda-$MAJOR.$MINOR/bin/nvcc"
echo $NVCC_PATH
$NVCC_PATH --version

if [ $? -ne 0 ]; then
    echo "CUDA is not installed. installing..!"
else
    echo "CUDA is installed in this device"
    NVCC_VERSION=$($NVCC_PATH --version)
    echo $NVCC_VERSION
    exit 0
fi

pushd  $WORKSPACE_DIR

os_namelower=$(echo "$os_name" | tr '[:upper:]' '[:lower:]')
os_version_string=$(echo $os_version | tr -d '.' | cut -c 1-4)
os_nameversion=$os_namelower$os_version_string
PIN_NAME=$PIN_NAME$os_nameversion.pin

echo $PIN_NAME
PIN_URL=$NVIDIA_CUDA_REPO_BASE/$os_nameversion/$architecture/$PIN_NAME
echo $PIN_URL
wget $PIN_URL
mkdir -p /etc/apt/preferences.d/cuda-repository-pin-600
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600


DEB_NAME=cuda-tegra-repo-$os_nameversion-$MAJOR-$MINOR-local_$CUDA_VERSION-1_$architecture.deb
VAR_DEB_PATH=/var/cuda-tegra-repo-$os_nameversion-$MAJOR-$MINOR-local
CUDA_DEB_PATH=$NVIDIA_CUDA_PATH/$CUDA_VERSION/local_installers/$DEB_NAME

echo "Debian file name to be installed $DEB_NAME"
if [ -e $DEB_NAME ]; then
    echo "File exists. Installing..!"
else
    echo "File does not exist. Downloading..!"
    wget $CUDA_DEB_PATH
fi

dpkg -i $DEB_NAME
cp $VAR_DEB_PATH/cuda-*-keyring.gpg /usr/share/keyrings/
apt-get update
apt-get -y install cuda
popd