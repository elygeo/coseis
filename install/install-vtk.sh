#!/bin/bash -e

# install location
prefix="${1:-${HOME}/local}"

# CMake
url="http://www.cmake.org/files/v2.8/cmake-2.8.1.tar.gz"
dir=$( basename "$url" .tar.gz )
cd "${prefix}"
curl "${url}" | tar zx
cd "${dir}"
bash bootstrap --prefix="${prefix}"
make
make install

# VTK
url="http://www.vtk.org/files/release/5.4/vtk-5.4.2.tar.gz"
cd "${prefix}"
curl "${url}" | tar zx
cd VTK
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS:BOOL=ON -DVTK_WRAP_PYTHON:BOOL=ON -DVTK_USE_TK:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH="${prefix}"
make
make install
export LD_LIBRARY_PATH="${prefix}/lib/vtk-5.4"

# VTK for Snow Leopard (from Mayavi page, untested)
#export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:/usr/local/lib/vtk-5.4
#BUILD_SHARED_LIBS:BOOL=ON
#CMAKE_OSX_ARCHITECTURES:STRING=x86_64
#CMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.6
#VTK_WRAP_PYTHON:BOOL=ON
#VTK_PYTHON_SETUP_ARGS:STRING=

