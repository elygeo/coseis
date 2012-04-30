Install Notes
-------------

    PREFIX="$HOME/local"

MPICH2
::

    export PATH="${PREFIX}/bin:${PATH}"
    cd "${PREFIX}"
    curl -L http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.4.1p1/mpich2-1.4.1p1.tar.gz | tar zx
    cd mpich2-1.4.1p1
    ./configure -prefix="$PREFIX" --with-pm=gforker 
    make install

Python
::

    export PATH="${PREFIX}/bin:${PATH}"
    cd "${PREFIX}"
    curl http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz | tar zx
    cd Python-2.7.3
    ./configure --prefix="${PREFIX}"
    make install
    curl -O http://python-distribute.org/distribute_setup.py
    ./python distribute_setup.py
    easty_install pip
    pip install numpy
    pip install configobj
    pip install nose
    pip install GitPython
    pip install pyflakes

Enthought Python Distributions (EPD)
::
    
    export PATH="${PREFIX}/python/bin:${PATH}"
    cd "${PREFIX}"
    curo -O http://download.enthought.com/epd_7.2/epd-7.2-2-rh5-x86_64.sh
    bash epd-7.2-2-rh5-x86_64.sh
    ln -s epd-7.2-2-rh5-x86_64 python
    easty_install pip
    pip install GitPython
    pip install pyflakes

Enthought Python Distributions (EPD) - Max OSX
::
    
    curl -O http://download.enthought.com/epd_7.2/epd-7.2-2-macosx-i386.dmg
    curl -O http://download.enthought.com/epd_7.2/epd-7.2-2-macosx-x86_64.dmg
    export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"

Analysis and plotting
::

    ++ libjpeg
    ++ wxpython
    ++ pip install ipython
    ++ pip install matplotlib
    ++ pip install scipy
    ++ pip install PIL
    + pip install pyproj
    + pip install 'Mayavi[app]'
    + zlib
    + vtk
    pip install pypdf
    pip install obspy.core
    pip install obspy.mseed
    pip install obspy.sac
    pip install obspy.gse2
    pip install obspy.imaging
    pip install obspy.signal


CMake
::
    cd "${PREFIX}"
    curl http://www.cmake.org/files/v2.8/cmake-2.8.5.tar.gz | tar zx
    cd cmake-2.8.5
    bash bootstrap --prefix="${PREFIX}"
    make install

VTK
::
    cd "${PREFIX}"
    curl http://www.vtk.org/files/release/5.6/vtk-5.6.1.tar.gz | tar zx
    cd VTK
    mkdir build
    cd build
    export LD_LIBRARY_PATH="${prefix}/lib/vtk-5.6"
    cmake .. \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DVTK_WRAP_PYTHON:BOOL=ON \
        -DVTK_USE_TK:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}"
    make install

