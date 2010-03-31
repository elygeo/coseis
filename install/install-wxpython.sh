#!/bin/bash -e

prefix="${HOME}/local"

# wxPython
url="http://downloads.sourceforge.net/wxpython/wxPython-src-2.8.10.1.tar.bz2"
dir=$( basename "${url}" .tar.bz2 )
curl -O "$url" | tar jx
cd "${dir}"
mkdir bld
cd bld
../configure --prefix="${prefix}" --enable-optimize --enable-debug_flag
make
make install
export LD_LIBRARY_PATH="${prefix}/lib"

