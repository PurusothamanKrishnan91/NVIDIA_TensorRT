#/ /bin/bash

set -ex
CUDNN_VERSION="9.1.1"

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as a sudo user."
  exit 1
fi

ROOT_DIR=$( dirname $( dirname -- "$( readlink -f -- "$0" )" ))
source $ROOT_DIR/set_workspace

# Read the file line by line
while IFS= read -r package; do
    echo "Installing $package..."
    # Fix dependencies
    apt-get install -y $package
done < $ROOT_DIR/deps/depedendcies.txt

cat $ROOT_DIR/deps/depedendcies.txt
architecture=$(uname -m)
if [ $architecture == "aarch64" ]; then
    architecture="arm64"
fi
os_name=$(grep -oP '^NAME="\K[^"]+' /etc/os-release)
os_version=$(grep -oP '^VERSION="\K[^"][0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}.' /etc/os-release)
os_namelower=$(echo "$os_name" | tr '[:upper:]' '[:lower:]')
os_version_string=$(echo $os_version | tr -d '.' | cut -c 1-4)
distro=$os_namelower$os_version_string

CUDNN_BASE_PATH="https://developer.download.nvidia.com/compute/cudnn"
CUDNN_CROSS_PATH="local_installers/cudnn-local-repo-cross-aarch64-"
CUDNN_NATIVE_PATH="local_installers/cudnn-local-tegra-repo-"
CUDNN_NATIVE_NAME="cudnn-local-tegra-repo-"
CUDNN_NAME=$distro-${CUDNN_VERSION}_1.0-1_$architecture.deb
CUDNN_DEB_NAME=$CUDNN_NATIVE_NAME$CUDNN_NAME
CUDNN_DEB_PATH=$CUDNN_BASE_PATH/$CUDNN_VERSION/$CUDNN_NATIVE_PATH$CUDNN_NAME

pushd  $WORKSPACE_DIR
echo $CUDNN_DEB_PATH
if [ -e $CUDNN_DEB_NAME ]; then
  rm -rf $CUDNN_DEB_NAME
else
  wget $CUDNN_DEB_PATH
fi
dpkg -i $CUDNN_DEB_NAME

#copy the keyring 
cp /var/cudnn-local-tegra-repo-$distro-${CUDNN_VERSION}/cudnn-*-keyring.gpg /usr/share/keyrings/
apt-get update
apt-get -y install cudnn
popd