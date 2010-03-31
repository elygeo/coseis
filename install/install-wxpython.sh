#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# wxPython
url="http://downloads.sourceforge.net/wxpython/wxPython-src-2.8.10.1.tar.bz2"
ver="$( basename "${url}" .tar.bz2 )"

# dowload
cd "${prefix}"
#curl "${url}" | tar jx
wget "${url}"
tar jxf "${ver}.tar.bz2"

# wxWidgets
cd "${ver}"
mkdir bld
cd bld
../configure \
    --prefix="${prefix}" \
    --with-gtk \
    --with-gnomeprint \
    --with-opengl \
    --enable-geometry \
    --enable-graphics_ctx \
    --enable-sound --with-sdl \
    --enable-mediactrl \
    --enable-display \
    --enable-monolithic \
    --enable-unicode \
    --with-libjpeg=builtin \
    --with-libpng=builtin \
    --with-libtiff=builtin \
    --with-zlib=builtin \
    --enable-optimize \
    --enable-debug_flag \
    --enable-rpath="${prefix}/lib"
make
make -C contrib/src/gizmos
make -C contrib/src/stc
make install
make -C contrib/src/gizmos install
make -C contrib/src/stc install

# wxPython
cd ../wxPython
python setup.py build_ext --inplace
python setup.py install

export LD_LIBRARY_PATH="${prefix}/lib"

