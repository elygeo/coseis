#!/bin/bash -e
# Install Python and related tools

# set location here:
path="\${HOME}/local"

# confirm
prefix="$( eval echo ${path} )"
echo -n "Installing Python-${version} in ${prefix}. Are you sure? [y/N]: "
read confirm
[ "$confirm" = "y" ]
mkdir -p "${prefix}"

# Python
version="2.6.5"
cd "${prefix}"
if [ ! -d "Python-${version}" ]; then
    curl "http://www.python.org/ftp/python/${version}/Python-${version}.tgz" | tar zx
    cd "Python-${version}"
    ./configure --prefix="${prefix}"
    make
    make install
    curl -O http://peak.telecommunity.com/dist/ez_setup.py
    python ez_setup.py --prefix="${prefix}"
    #curl -O http://python-distribute.org/distribute_setup.py
    #python distribute_setup.py --prefix="${prefix}"
fi
export PATH="${prefix}/bin:${PATH}"

# CMake
version="cmake-2.8.1"
cd "${prefix}"
if [ ! -d "${version}" ]; then
    curl "http://www.cmake.org/files/v2.8/${version}.tar.gz" | tar zx
    cd "${version}"
    bash bootstrap --prefix="${prefix}"
    make
    make install
fi

# VTK
version="vtk-5.4.2"
cd "${prefix}"
if [ ! -d VTK -a ! -d VTK-build ]; then
    curl "http://www.vtk.org/files/release/5.4/${version}.tar.gz" | tar zx
    mkdir VTK-build
    cd VTK-build
    cmake ../VTK -DBUILD_SHARED_LIBS:BOOL=ON -DVTK_WRAP_PYTHON:BOOL=ON -DVTK_USE_TK:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH="${prefix}"
    make
    make install
fi
export LD_LIBRARY_PATH="${prefix}/lib/vtk-5.4"

# PyPI packages
easy_install cython
easy_install numpy
easy_install PIL
easy_install pyproj
easy_install wxpython
easy_install matplotlib
easy_install configobj
easy_install "Mayavi[app]"
easy_install scipy

echo 'Now add this to your .bashrc or .profile:'
echo "export PATH=\"${path}/python/bin:\${PATH}\""

