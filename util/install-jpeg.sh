#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# jpeg
url="http://www.ijg.org/files/jpegsrc.v8b.tar.gz"
tag=$( basename "$url" .tar.gz | sed 's/src.v/-/' )
cd "${prefix}"
curl -L "${url}" | tar zx
cd "${tag}"
./configure --prefix="${prefix}"
make install

cd "${pwd}"

