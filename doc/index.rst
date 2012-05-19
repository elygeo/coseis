======
Coseis
======
Computational Seismology Tools
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. class:: navbar

+ Install_
+ Examples_
+ SORD_
+ WebSims_
+ `Source Code`_

.. _SORD:         sord.html
.. _WebSims:      http://scec.usc.edu/websims
.. _Source Code:  https://github.com/gely/coseis/

Summary
=======

Coseis is an open-source toolkit for earthquake simulation featuring:

*   The Support Operator Rupture Dynamics (SORD_) code for modeling spontaneous
    rupture and 3D wave propagation.

*   SCEC Community Velocity Models (CVM) codes, with MPI parallelization for
    `Magistrale version`__ (CVM-S), and new `geotechnical layer
    implementation`__ for the `Harvard version`__ (CVM-H).

*   WebSims_ web application for cataloging, exploring, and disseminating large
    numerical simulations data sets.

*   Utilities for mesh generation, coordinate projection, and visualization.

__ http://www.data.scec.org/3Dvelocity/
__ http://earth.usc.edu/~gely/vs30gtl/
__ http://structure.harvard.edu/cvm-h/

The primary interface is through a Python module which (for high-performance
components) wraps Fortran parallelized with MPI.

Coseis is written by `Geoffrey Ely`_ with contributions from Steven Day,
Bernard Minster, Feng Wang, Zheqiang Shi, and Jun Zhou.  It is licensed under
BSD_ terms.

.. _Geoffrey Ely: http://www.alcf.anl.gov/~gely/
.. _GPLv3:        http://www.gnu.org/licenses/gpl-3.0.html
.. _BSD:          http://opensource.org/licenses/BSD-2-Clause

.. class:: warning

    **WARNING**: Coseis is a research code under active development.  Changes
    are frequent and it has known bugs!


OSX Install Requirements
========================

1.  For Mac OS X, first install Xcode_ and Homebrew_, and then do:
    ::

        brew install gfortran git

2.  For multiprocessing with MPI (for SORD or CVMS), MPICH2_ is recommended:
    ::

        PREFIX="$HOME/local"
        export PATH="${PREFIX}/bin:${PATH}"
        cd "${PREFIX:?}"
        curl -L http://www.mcs.anl.gov/research/projects/mpich2/downloads/tarballs/1.4.1p1/mpich2-1.4.1p1.tar.gz | tar zx
        cd mpich2-1.4.1p1
        ./configure -prefix="$PREFIX" --with-pm=gforker 
        make install

3.  For plotting and visualization, Enthought Python Distribution (EPD_) is
    recommended.


Install
=======

1.  Clone the source code from the `Coseis GitHub repository
    <http://github.com/gely/coseis>`__ using Git_::

        git clone git://github.com/gely/coseis.git

2.  Set path variables for the Pyhon module and executables. For bash shell,
    with the code located in your home directory (for example) add these lines to
    ``.bash_profile``::

        export PYTHONPATH="$HOME/coseis"
        export PATH="$PATH:$HOME/coseis/bin"

3.  For laptop and workstation installations, the default system configuration
    is usually adequate.  Systems with batch schedulers (such as PBS or
    LoadLeveler) require custom configuration to specify system resources, compiler
    options, and scheduler scripts.  Custom configuration modules are located in the
    ``cst/conf/`` directory.  You may create a new module following the
    included examples.  To activate a configuration, create a site configuration
    module ``cst/conf/site.py``, and set the  ``machine`` parameter to the name
    of the configuration module. For example::

        machine = 'tacc_ranger'

    Other useful options may be placed in your ``site.py`` module.  For example,
    the account for billing of service units, and email address for notifications
    may be specified in ``site.py`` module with::

        machine = 'tacc_ranger'
        account = 'your_project_name_here'
        email = 'your_email_address_here'

6.  Run the ``setup.py`` script to test your configuration. This will display
    all of the configuration parameters::

        python setup.py

.. _Git:               http://git-scm.com/
.. _MPICH2:            http://www.mcs.anl.gov/research/projects/mpich2/
.. _Xcode:             http://itunes.apple.com/us/app/xcode/id497799835
.. _Homebrew:          http://mxcl.github.com/homebrew/
.. _EPD:               http://www.enthought.com/products/epddownload.php
.. _Python:            http://www.python.org/
.. _NumPy:             http://numpy.scipy.org/
.. _SciPy:             http://www.scipy.org/
.. _Mayavi:            http://code.enthought.com/projects/mayavi/
.. _Matplotlib:        http://matplotlib.sourceforge.net/
.. _nose:              http://readthedocs.org/docs/nose/


Examples
========

CVM depth planes
----------------

.. image:: ../scripts/cvm/cvms-vs500.png
.. image:: ../scripts/cvm/cvmh-vs500.png

Extract S-wave velocity at 500 meters depth. Plot using Matplotlib
::

    cd scripts/cvm
    python plane.py

Source code:
`plane.py <../scripts/cvm/plane.py>`__

CVM-S fence diagram
-------------------

.. image:: ../scripts/cvm/cvms-vp-fence.png

Build a fence diagram similar to Magistrale (2000) figure 10. Plot using
Mayavi::

    cd scripts/cvm
    python fence.py

Source code:
`fence.py <../scripts/cvm/fence.py>`__

CVM-S Basin depth
-----------------

.. image:: ../scripts/basindepth/cvm-z25.png

Extract 3D mesh and search for the shallowest surface of Vs = 2.5 km/s.
Plot over topography using Mayavi::

    cd scripts/basindepth
    python mesh.py
    python search.py
    python viz.py

Source code:
`mesh.py <../scripts/basindepth/mesh.py>`__
`search.py <../scripts/basindepth/search.py>`__
`viz.py <../scripts/basindepth/viz.py>`__

