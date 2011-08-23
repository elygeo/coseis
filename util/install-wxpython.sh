#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"

# wxPython
if [ "${OSTYPE}" = 'darwin10.0' ]; then

# Mac OS X
url='http://downloads.sourceforge.net/wxpython/wxPython2.8-osx-unicode-2.8.12.1-universal-py2.7.dmg'
url='http://downloads.sourceforge.net/wxpython/wxPython2.8-osx-unicode-2.8.12.1-universal-py2.6.dmg'
tag=$( basename "$url" )
cd "${prefix}"
curl -LO "${url}"
hdid "${tag}"
sudo installer -pkg '/Volumes/${tag}/${tag}.pkg' -target '/'

else

# Linux
url="http://downloads.sourceforge.net/wxpython/wxPython-src-2.8.12.1.tar.bz2"
tag="$( basename "${url}" .tar.bz2 )"
cd "${prefix}"
curl -L "${url}" | tar jx
cd "${tag}"
mkdir bld
cd bld

../configure \
    --prefix="${prefix}" \
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
    --with-gtk \
    --with-gnomeprint \
    --enable-rpath="${prefix}/lib"
#   --with-mac \

export LD_LIBRARY_PATH="${prefix}/lib"

make
make -C contrib/src/gizmos
make -C contrib/src/stc
make install
make -C contrib/src/gizmos install
make -C contrib/src/stc install

# wxPython
cd ../wxPython
#export WX_CONFIG="${prefix}/bin/wx-config"
python setup.py build_ext --inplace
python setup.py install

fi

echo "Now set your LD_LIBRARY_PATH!"

cd "${pwd}"

