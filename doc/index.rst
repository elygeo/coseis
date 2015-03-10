******
Coseis
******

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
components) wraps Fortran parallelized with hybrid OpenMP and MPI.

Coseis is written by `Geoffrey Ely`_ with contributions from Steven Day,
Bernard Minster, Feng Wang, Zheqiang Shi, and Jun Zhou.  It is licensed under
BSD_ terms.

.. _Geoffrey Ely: http://www.alcf.anl.gov/~gely/
.. _BSD:          http://opensource.org/licenses/BSD-2-Clause

.. class:: warning

    **WARNING**: Coseis is a research code under active development.  Changes
    are frequent and it has known bugs!


Install
=======

1.  If on Mac OS X, first install Xcode_ from the App Store. From the Xcode
    preferences pane, install the Command Line Tools. Then install Homebrew_,
    followed by Git_ and Fortran_ with::

        brew install git gfortran

    OpenMP is broken in GCC 4.3 on Lion, so if you need multiprocessing speed-up,
    install either MPICH_ or a newer GCC_ version.  Optionally, install and EPD_
    for visualization and analysis. 

2.  Clone the source code from the `Coseis GitHub repository
    <http://github.com/gely/coseis>`__::

        git clone git://github.com/gely/coseis.git

3.  Set path variables for the Python module and executables. For bash shell,
    with the code located in your home directory (for example) add these lines to
    ``.bash_profile``::

        export PYTHONPATH="$HOME/coseis"
        export PATH="$PATH:$HOME/coseis/bin"

4.  Run the ``setup.py`` script to test your configuration. This will display
    all of the configuration parameters::

        python setup.py

5.  These parameters may be customized by creating a file ``cst/conf/site.py``.
    For example, the account for billing of service units, and email address for
    notifications may be specified in ``site.py`` module with::

        account = 'your_project_name_here'
        email = 'your.email@address.here'

.. _Xcode:       http://itunes.apple.com/us/app/xcode/id497799835
.. _Homebrew:    http://mxcl.github.com/homebrew/
.. _Git:         http://git-scm.com/
.. _Fortran:     http://r.research.att.com/tools/
.. _MPICH:       http://www.mcs.anl.gov/research/projects/mpich2/
.. _GCC:         http://gcc.gnu.org/
.. _EPD:         http://www.enthought.com/products/epddownload.php

Testing
=======

To run the test suite interactively::

    cd cst/tests
    python test_runner.py --run=exec

Or, submit a job for batch processing::

    python test_runner.py --run=submit

After completion, a report is printed to the screen (or saved in
run/test_suite/test_suite.output)::

    PASSED: doctest.testmod(cst.util)
    PASSED: doctest.testmod(cst.coord)
    PASSED: doctest.testmod(cst.sord)
    PASSED: cst.tests.syntax.test()
    PASSED: cst.tests.configure.test()
    PASSED: cst.tests.hello_mpi.test()
    PASSED: cst.tests.point_source.test()
    PASSED: cst.tests.pml_boundary.test()
    PASSED: cst.tests.kostrov.test()


Examples
========

CVM depth plane
---------------

.. image:: ../Images/CVM-Depth-Plane-Vs-S.png
.. image:: ../Images/CVM-Depth-Plane-Vs-H.png

Extract S-wave velocity at 500 meters depth. Plot using Matplotlib::

    cd Scripts
    python CVM-Depth-Plane.py

Source code:
`CVM-Depth-Plane.py <../Scripts/CVM-Depth-Plane.py>`__

CVM-S fence diagram
-------------------

.. image:: ../Images/CVM-Fence-Vp-S.png

Build a fence diagram similar to Magistrale (2000) figure 10. Plot using
Mayavi::

    python CVM-Fence.py

Source code:
`CVM-Fence.py <../Scripts/CVM-Fence.py>`__

CVM-S basin depth
-----------------

.. image:: ../Images/CVM-Basins.png

Extract 3D mesh and search for the shallowest surface of Vs = 2.5 km/s.
Plot over topography using Mayavi::

    python Basins-Mesh.py
    python Basins-Search.py
    python Basins-Viz.py

Source code:

| `CVM-Basins-Mesh.py <../Scripts/CVM-Basins-Mesh.py>`__
| `CVM-Basins-Search.py <../Scripts/CVM-Basins-Search.py>`__
| `CVM-Basins-Viz.py <../Scripts/CVM-Basins-Viz.py>`__

