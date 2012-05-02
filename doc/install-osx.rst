OSX Installation 
----------------


First install Xcode_ and Homebrew_. Then install Gfortran:
::

    brew install gfortran

That is the bare minimum to run the SORD code in serial mode.  To add MPI
support do:: 

    PREFIX="$HOME/local"
    export PATH="${PREFIX}/bin:${PATH}"
    cd "${PREFIX:?}"
    curl -L http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.4.1p1/mpich2-1.4.1p1.tar.gz | tar zx
    cd mpich2-1.4.1p1
    ./configure -prefix="$PREFIX" --with-pm=gforker 
    make install


To run the MPI version,
or use 

Enthought Python Distributions (EPD_)
For EPD Free:
::

    brew install vtk
    easy_install 'Mayavi[app]'
    easy_install pyproj

Others
::

    easy_install pypdf
    easy_install obspy.core
    easy_install obspy.mseed
    easy_install obspy.sac
    easy_install obspy.gse2
    easy_install obspy.imaging
    easy_install obspy.signal

.. _Xcode:    http://itunes.apple.com/us/app/xcode/id497799835
.. _Homebrew: http://mxcl.github.com/homebrew/
.. _EPD:      http://www.enthought.com/products/getepd.php

