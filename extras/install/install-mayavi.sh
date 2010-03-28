#!/bin/bash -e

# Set version and loction here:
path="\${HOME}/local"

prefix="$( eval echo ${path} )"
echo -n "Installing CMake, VTK, and Mayavi in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]

mkdir -p "${prefix}"

# CMake
version="cmake-2.8.1"
cd "${prefix}"
curl "http://www.cmake.org/files/v2.8/${version}.tar.gz" | tar zxv
ln -s "${version}" cmake
cd cmake
bash bootstrap --prefix="${prefix}"
make
export PATH="${prefix}/bin/cmake:${PATH}"

# VTK
version="vtk-5.4.2"
cd "${prefix}"
curl "http://www.vtk.org/files/release/5.4/${version}.tar.gz" | tar zxv
mkdir VTK-build
cd VTK-build
cmake ../VTK -DBUILD_SHARED_LIBS:BOOL=ON -DVTK_WRAP_PYTHON:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH="${prefix}/python"
make
make install
export LD_LIBRARY_PATH="${prefix}/python/lib/${version}"

easy_install configobj
easy_install "Mayavi[app]"

echo 'Now add this to your .bashrc or .profile:'
echo "export LD_LIBRARY_PATH=\"${path}/python/lib/${version}"
echo "export PATH=\"${path}/cmake/bin:\${PATH}\""

