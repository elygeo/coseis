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


System requirements
===================

*   Python_, and NumPy_ (Numerical Python).

*   Git_ version control system.

*   (+) Fortran 95 compiler.  Required only for SORD and CVM-S modules.

*   (+) Message Passing Interface (MPI) library.  Required only for
    multiprocessing with SORD and CVM-S.

*   (+) Matplotlib_, SciPy_, and Pyproj Python packages.  Required only for
    supplemental plotting, signal processing, and mesh generation utilities.

(+) Optional


Install
=======

Fortran and MPI installation should only be necessary for personal computers.
HPC systems generally supply specifically tuned Fortran compilers and MPI
libraries.

1.  GNU Fortran is recommended if you don't already have a Fortran 95 compiler.

    Fedora/Red Hat Linux:
    ::

        sudo yum install gfortran git

    Ubuntu Linux:
    ::

        sudo apt-get install gfortran git

    For Mac OS X, first install Xcode_ and Homebrew_, and then do:
    ::

        brew install gfortran git

2.  If you need MPI (for SORD of CVMS), MPICH2_ is recommended.

3.  For plotting and visualization, Enthought Python Distribution (EPD_) is
    recommended.

4.  Clone the source code from the `Coseis GitHub repository
    <http://github.com/gely/coseis>`__ using Git_::

        git clone git://github.com/gely/coseis.git

    Update to the latest changes anytime with:
    ::

        git pull

5.  For laptop and workstation installations, the default system configuration
    is usually be adequate.  To test the default configuration::

        cd coseis/
        python setup.py

    Systems with batch schedulers (such as PBS or LoadLeveler) generally require
    custom configuration to specify system resources, compiler options, and
    scheduler scripts.  If Coseis has already been configured for your system you
    can use one of the included configurations.  For example, for the TeraGrid
    Ranger system at TACC::

        python setup.py --machine=tacc-ranger

    To see the list of included configurations look in the ``cst/conf/`` directory.
    Each custom configuration is located in a separate sub-directory.  To create a
    new custom configuration, make a new sub-directory following the example of
    the supplied configurations.

6.  Build the components you need (options are: ``sord``, ``cvms``,
    ``cvmh``, ``cfm``, ``rspectra``, ``mapdata``). For example::

        python setup.py sord cvmh cfm mapdata

7.  If building SORD, you may want to run the test suite:
    ::

        python setup.py test 

8.  Finally, set path variables for the Pyhon module and executables. For bash
    shell, with the code located in your home directory (for example) add these
    lines to ``.bash_profile``::

        export PYTHONPATH="$HOME/coseis"
        export PATH="$PATH:$HOME/coseis/bin"

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

