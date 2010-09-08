#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# Lighttpd
url="http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.28.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make
make install
export PATH="${prefix}/sbin:${PATH}"
cd "${pwd}"

