#!/bin/bash -e
prefix="${1:-${HOME}/local}"
pwd="${PWD}"

# CMake
url="http://www.cmake.org/files/v2.8/cmake-2.8.2.tar.gz"
tag=$( basename "$url" .tar.gz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${tag}"
bash bootstrap --prefix="${prefix}"
make
make install

# VTK
url="http://www.vtk.org/files/release/5.6/vtk-5.6.0.tar.gz"
cd "${prefix}"
curl "${url}" | tar zx
cd VTK
mkdir build
cd build
cmake .. \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_USE_TK:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH="${prefix}"
make
make install
export LD_LIBRARY_PATH="${prefix}/lib/vtk-5.6"

# VTK for Snow Leopard (from Mayavi page, untested)
#BUILD_SHARED_LIBS:BOOL=ON
#VTK_WRAP_PYTHON:BOOL=ON
#VTK_PYTHON_SETUP_ARGS:STRING=
#CMAKE_OSX_ARCHITECTURES:STRING=x86_64
#CMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.6
#DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:/usr/local/lib/vtk-5.4

echo "Now set your LD_LIBRARY_PATH!"
cd "${pwd}"

