#!/bin/bash -e
pwd="${PWD}"
cd "${1:-.}"
prefix="${PWD}"
echo -n "Install CMake and VTK in ${prefix}? [y/N]: "
read confirm
[ "$confirm" = "y" ]

# CMake
url="http://www.cmake.org/files/v2.8/cmake-2.8.5.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${tag}"
bash bootstrap --prefix="${prefix}"
make
make install

# VTK
url="http://www.vtk.org/files/release/5.6/vtk-5.6.1.tar.gz"
cd "${prefix}"
curl "${url}" | tar zx
cd VTK
mkdir build
cd build

if [ "${OSTYPE}" = 'darwin10.0' ]; then

# untested
export DYLD_LIBRARY_PATH="${prefix}/lib/vtk-5.6"
cmake .. \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_OSX_ARCHITECTURES:STRING=x86_64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.6 \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_SETUP_ARGS:STRING= \
    -DVTK_USE_RPATH=ON \
    #-DVTK_USE_COCOA=ON \
    #-DVTK_USE_CARBON=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH="${prefix}"

else

export LD_LIBRARY_PATH="${prefix}/lib/vtk-5.6"
cmake .. \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_USE_TK:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH="${prefix}"

fi

make
make install
echo "Now set your LD_LIBRARY_PATH!"
cd "${pwd}"

