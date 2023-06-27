#!/bin/bash
set -e
CURL_URL="https://github.com/curl/curl/releases/download/curl-7_88_1/curl-7.88.1.tar.bz2"

export DEBIAN_FRONTEND=noninteractive
apt-get -yq update
apt-get -yq install build-essential libssl-dev wget
apt-get -yq remove curl libcurl4
cd /tmp
wget -O curl.tar.bz2 "${CURL_URL}"
tar xfvj curl.tar.bz2
cd curl
./configure --with-openssl --enable-websockets --prefix=/usr
make install
cd .. && rm -rf ./curl*