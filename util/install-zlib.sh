#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# zlib
url="http://www.zlib.net/zlib-1.2.5.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make install
./configure --prefix="${prefix}" --shared
make install

cd "${pwd}"

