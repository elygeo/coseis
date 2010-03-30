#!/bin/bash -e

# set location here:
path="\${HOME}/local"
prefix="$( eval echo ${path} )"

# confirm
echo -n "Installing in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# CMake
version="cmake-2.8.1"
cd "${prefix}"
curl "http://www.cmake.org/files/v2.8/${version}.tar.gz" | tar zx
cd "${version}"
bash bootstrap --prefix="${prefix}"
make
make install

# VTK
version="vtk-5.4.2"
cd "${prefix}"
curl "http://www.vtk.org/files/release/5.4/${version}.tar.gz" | tar zx
mkdir VTK-build
cd VTK-build
cmake ../VTK -DBUILD_SHARED_LIBS:BOOL=ON -DVTK_WRAP_PYTHON:BOOL=ON -DVTK_USE_TK:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH="${prefix}"
make
make install

# PATH
echo 'Now add this to your .bashrc or .profile:'
echo "export LD_LIBRARY_PATH=\"${path}/lib/vtk-5.4\""
export LD_LIBRARY_PATH="${prefix}/lib/vtk-5.4"

# VTK for Snow Leopard (from Mayavi page, untested)
#export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:/usr/local/lib/vtk-5.4
#BUILD_SHARED_LIBS:BOOL=ON
#CMAKE_OSX_ARCHITECTURES:STRING=x86_64
#CMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.6
#VTK_WRAP_PYTHON:BOOL=ON
#VTK_PYTHON_SETUP_ARGS:STRING=

