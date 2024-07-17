#!/bin/bash

set +ex

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as a sudo user."
  exit 1
fi

apt update -y

apt install build-essential zlib1g-dev -y

cd /usr/local/src/

wget https://www.openssl.org/source/openssl-3.0.8.tar.gz

tar xzvf openssl-3.0.8.tar.gz

cd openssl-3.0.8

./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib

make

make test

make install

cd /etc/ld.so.conf.d/

echo "/usr/local/ssl/lib64" >> openssl-3.0.8.conf

ldconfig -v

mv /bin/openssl /bin/openssl.backup

echo "OPENSSL_PATH=\"/usr/local/ssl/bin\"" > /etc/profile.d/openssl.sh
echo "export OPENSSL_PATH" >> /etc/profile.d/openssl.sh
echo "PATH=\$PATH:\$OPENSSL_PATH"  >> /etc/profile.d/openssl.sh
echo "export PATH" >> /etc/profile.d/openssl.sh

chmod +x /etc/profile.d/openssl.sh

source /etc/profile.d/openssl.sh

openssl version -a