====
SORD
====

.. image:: ely-saf-surface.jpg
   :align: right
   :target: http://earth.usc.edu/~gely/ely-saf-surface.mov

.. contents::


Summary
-------

The Support Operator Rupture Dynamics (SORD) code simulates spontaneous rupture
within a 3D isotropic viscoelastic solid.  Wave motions are computed on a
logically rectangular hexahedral mesh, using the generalized finite difference
method of support operators.  Stiffness and viscous hourglass corrections are
employed to suppress suppress zero-energy grid oscillation modes.  The fault
surface is modeled by coupled double nodes, where the strength of the coupling
is determined by a linear slip-weakening friction law.  External boundaries may
be reflective or absorbing, where absorbing boundaries are handled using the
method of perfectly matched layers (PML).  The hexahedral mesh can accommodate
non-planar ruptures and surface topography

SORD is a Python module that allows for flexible scripting of jobs.  Underlying
computations are coded in Fortran 95 and parallelized for multi-processor
execution using Message Passing Interface (MPI).  The code is portable and
tested with a variety of Fortran 95 compilers, MPI implementations, operating
systems (Linux, IBM AIX, Mac OS X, SUN Solaris).


News
----

2008, Nov 11. New version finished introducing a revamped I/O scheme and Python
based configuration. Beware that it is not well tested yet.


License
-------

SORD is open-source and released under the `GNU General Public License Version 3
<license.txt>`_.  You are free to use or redistribute the code, with the
obligation that you contribute back any modification or derived works.


Author
------

| `Geoffrey Ely <http://earth.usc.edu/~gely>`_
| `Southern California Earthquake Center <http://www.scec.org/>`_
| `University of Southern California <http://www.usc.edu/>`_
| gely@usc.edu


Publications
------------

The first two papers give (for wave propagation and spontaneous rupture,
respectively) the formulation, numerical algorithm, and verification of the
SORD method. The third paper presents an application to simulating earthquakes
in southern California.

.. class:: ref

Ely, G. P., S. M. Day, and J.-B. Minster (2008),
*A support-operator method for visco-elastic wave modeling in 3D heterogeneous media*,
Geophys. J. Int., `172(1), 331-344
<http://www.blackwell-synergy.com/doi/abs/10.1111/j.1365-246X.2007.03633.x>`_,
doi: 10.1111/j.1365-246X.2007.03633.x.
`[PDF] <http://earth.usc.edu/~gely/pub/ely-som-20080426.pdf>`__
`[BibTex] <http://earth.usc.edu/~gely/pub/Ely2008a.bib>`__

.. class:: ref

Ely, G. P., S. M. Day, and J.-B. Minster (2008),
*A support-operator method for 3D rupture dynamics*,
Geophys. J. Int., in revision.
`[PDF] <http://earth.usc.edu/~gely/pub/ely-sord-20080426.pdf>`__

.. class:: ref

Ely, G. P., S. M. Day, and J.-B. Minster (2008),
*Dynamic rupture models for the southern San Andreas fault*,
BSSA, in revision.
`[PDF] <http://earth.usc.edu/~gely/pub/ely-saf-20080426.pdf>`__
`[Electronic supplement] <http://earth.usc.edu/~gely/ely-saf-esupp.html>`__


Download
--------

.. include:: download.txt

Older versions can be extracted from the source code repository (see
Development_).


Installation - Linux or Mac OS X
--------------------------------

1.  A Fortran 95 compiler is required.  SORD has been tested with GNU, IBM,
    SUN, Intel, and Portland Group compilers.  GNU Fortran is a fine option if you
    do not already have one.  To install GNU Fortran on Fedora or Red Hat Linux use
    ``yum``::

        yum install gfortran

    For Mac OS X, first install `Xcode Tools
    <http://developer.apple.com/technology/xcode.html>`_ available from Apple
    Developer Connection (free `membership <http://connect.apple.com>`__ required).
    Then install the GNU Fortran version available from the `R for Mac OS X
    Developer's Page <http://r.research.att.com/tools>`_ (versions from MacPorts
    and Fink seem to be problematic and are not recommended).

2.  MPI is required if you wish to use multiple cores or processors to speed-up
    computations.  SORD has been tested with ANL MPICH2, IBM MPI, and Myricom
    MPICH-GM.  The `MPICH2 <http://www.mcs.anl.gov/research/projects/mpich2/>`_
    implementation is recommended if you do not already have one.  The script
    `install-mpich.sh <extras/install-mpich.sh>`__ in the ``extras/`` directory can
    automate this for you.

3.  Most systems already have `Python <http://www.python.org/download/>`_, but
    you may want to update it.  The `Enthought Python Distribution
    <http://www.enthought.com/products/epddownload.php>`_ is a convenient way to
    install Python with many useful included packages such as `matplotlib
    <http://matplotlib.sourceforge.net/>`_, `SciPy <http://www.scipy.org/>`_, and
    `Mayavi <http://code.enthought.com/projects/mayavi>`_.  If you want to install
    only Python without the bells a whistles (on a remote server, for example), the
    `install-python.sh <extras/install-python.sh>`__ script in the ``extras/``
    directory can automate this for you.

4.  Next, unpack the tar archive and enter the ``sord/`` directory:
    ::

        tar zxvf sord.tgz
        cd sord/

5.  For simple laptop and workstation installations the default system
    configuration may be adequate.  To test the default configuration run::

        ./configure.py

    Systems with batch schedulers (such as PBS or LoadLeveler) generally require
    custom configuration to specify system resources, compiler options, and
    scheduler scripts.  If SORD has already been configured for your system you can
    use one of the included configurations.  For example, for the TeraGrid Ranger
    system at TACC, run::

        ./configure.py tacc-ranger

    To see the list of included configurations look in the ``conf/`` directory.
    Each custom configuration is located in a separate sub-directory.  To create a
    new custom configuration, make a new sub-directory following the example of
    the supplied configurations.

6.  Compile the code by running:
    ::

        ./setup.py

7.  To use SORD, Python needs to be able to find the ``sord`` module.  The
    simplest way is to make sure you have a copy of, or a symbolic link to the
    ``sord`` directory in your current working directory.  More convenient is to
    add the directory above the ``sord`` directory to your Python path so that the
    module can be found from any location.  The PYTHONPATH environmental variable
    can be used, or if you are the administrator of your Python installation, you
    can do::

        ./setup.py path


Basic usage
-----------

SORD is run from Python by importing the ``sord`` module and passing a
dictionary containing the input parameters to the ``sord.run()`` function.  The
file `default-prm.py <default-prm.py>`__ contains a short description of each
SORD input parameter and it's default value.  Annotated example scripts are
located in the ``examples/`` directory.  To run the layer over halfspace
example (LOH.1), do::

    cd examples/
    ./loh1.py

Each time ``sord.run()`` is called, a run directory is created at the location
set by the ``rundir`` parameter, which defaults to ``~/run/`` plus the script
file name (``run/loh1`` in this case).  The directory contains the executable
and scripts to run the code, and will contain all of the generated output and
metadata.  From the run directory start the job interactively with the
``run.sh`` script::

    cd ~/run/loh1/
    ./run.sh

Or, submit the job to the batch system with the ``queue.sh`` script
::

    cd ~/run/loh1/
    ./queue.sh

Output (and large input, such as the material model) is stored in flat binary
binary files.  Statistic, such as peak acceleration and peak velocity, are
computed periodically during each run and stored in the ``stats/`` directory.
Internal code timings, for benchmarking performance, are collected and saved to
the ``prof/`` directory.  Inspecting these files during a run is a good way to
check that it is proceeding correctly.  The binary files can be examined with
the UNIX command ``od -f``.

The best place to go from here to learn more is to look at the example scripts
and `default-prm.py <default-prm.py>`__.  Studying the Fortran source code in
the ``src/`` directory will be educational as well.  As much as possible, I
have tried to keep it clean and readable.

.. include:: sources.txt


Development
-----------

Suggestions for improvements, and contributions to the SORD code and
documentation are greatly appreciated.  The latest development version can be
obtained from the `Bazaar <http://bazaar-vcs.org/>`_ source code repository
with::

    bzr checkout http://earth.usc.edu/~gely/sord

Why Bazaar?  Because Subversion is painful to use in my opinion.  Better,
modern alternatives are available.  `Mercurial
<http://www.selenic.com/mercurial/wiki/>`_, another strong candidate, was also
considered.  The simplest way to install Bazaar is to use Python `Easy Install
<http://pypi.python.org/pypi/setuptools>`_::

    easy_install bzr

