#!/bin/bash
set -e

CURL_URL="https://github.com/curl/curl/releases/download/curl-7_88_1/curl-7.88.1.tar.bz2"

apt-get update
apt-get install build-essential libssl-dev wget
apt-get remove curl libcurl4
cd /tmp
wget -O curl.tar.bz2 "${CURL_URL}"
tar xfvj curl.tar.bz2
cd curl
./configure --with-openssl --enable-websockets --prefix=/usr
make install
