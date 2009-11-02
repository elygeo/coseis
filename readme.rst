====
SORD
====

.. image:: doc/ely-saf-surface.jpg
   :align: right
   :target: http://earth.usc.edu/~gely/ely-saf-surface.mov

.. contents::


Summary
=======

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

SORD simulations are configured with Python scripts.  Underlying computations
are coded in Fortran 95 and parallelized for multi-processor execution using
Message Passing Interface (MPI).  The code is portable and tested with a
variety of Fortran 95 compilers, MPI implementations, and operating systems
(Linux, Mac OS X, IBM AIX, SUN Solaris).


License
-------

SORD is open-source and released under the `GNU General Public License Version 3
<license.txt>`_.  You are free to use or redistribute the code, with the
obligation that you contribute back any modification or derived works.


Author
------

| `Geoffrey Ely <http://earth.usc.edu/~gely>`_
| `Department of Earth Sciences <http://www.usc.edu/dept/earth/>`_
| `University of Southern California <http://www.usc.edu/>`_
| http://earth.usc.edu/~gely/
| gely@usc.edu


Publications
============

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

.. class:: ref

Ely, G. P., S. M. Day, and J.-B. Minster (2009),
*A support-operator method for 3D rupture dynamics*,
Geophys. J. Int.,
`177(3), 1140-1150 <http://www3.interscience.wiley.com/journal/122267744/abstract>`__,
doi:10.1111/j.1365-246X.2009.04117.x.
`[PDF] <http://earth.usc.edu/~gely/pub/ely-sord-20090504.pdf>`__

.. class:: ref

Ely, G. P., S. M. Day, and J.-B. Minster (2010),
*Dynamic rupture models for the southern San Andreas fault*,
BSSA, 100(1).
`[PDF] <http://earth.usc.edu/~gely/pub/ely-saf-20090721.pdf>`__
`[Electronic supplement] <http://earth.usc.edu/~gely/ely-saf-esupp.html>`__


Installation - Linux or Mac OS X
================================

1.  A Fortran 95 compiler is required.  GNU Fortran is a good option if you do
    not already have one.  To install on Fedora or Red Hat Linux::

        yum install gfortran

    For Mac OS X, first install either the iPhone or the Mac-only version of `Xcode
    <http://developer.apple.com/technology/xcode.html>`_ available from Apple
    Developer Connection (free `membership <http://connect.apple.com>`__ required).
    Then install the GNU Fortran version available from the `R for Mac OS X
    Developer's Page <http://r.research.att.com/tools>`_ (versions from MacPorts
    and Fink seem to be problematic and are not recommended).

2.  MPI is required if you wish to use multiple cores or processors to speed-up
    computations.  The `MPICH2 <http://www.mcs.anl.gov/research/projects/mpich2/>`_
    implementation is recommended if you do not already have one.  The script
    `install-mpich.sh <extras/install-mpich.sh>`__ in the ``extras/`` directory can
    automate this for you.

3.  Most systems already have `Python <http://www.python.org/download/>`_, but
    it is recommended that you install an updated version.  The `Enthought Python
    Distribution <http://www.enthought.com/products/epddownload.php>`_ includes
    packages such as `matplotlib <http://matplotlib.sourceforge.net/>`_, `SciPy
    <http://www.scipy.org/>`_, and `Mayavi
    <http://code.enthought.com/projects/mayavi>`_, that will allow you to run
    of the plotting examples included with SORD.

4.  Download and unpack the source code
    ::

        curl http://earth.usc.edu/~gely/sord/sord.tgz | tar zxv

5.  For laptop and workstation installations, the default system configuration
    is usually be adequate.  To test the default configuration::

        cd sord/
        ./configure.py

    Systems with batch schedulers (such as PBS or LoadLeveler) generally require
    custom configuration to specify system resources, compiler options, and
    scheduler scripts.  If SORD has already been configured for your system you can
    use one of the included configurations.  For example, for the TeraGrid Ranger
    system at TACC::

        ./configure.py tacc-ranger

    To see the list of included configurations look in the ``conf/`` directory.
    Each custom configuration is located in a separate sub-directory.  To create a
    new custom configuration, make a new sub-directory following the example of
    the supplied configurations.

6.  Compile the code by running:
    ::

        ./setup.py

7.  To enable Python to find the ``sord`` module, add the enclosing directory
    the Python path.  For example, if your installation location is
    ``~/packages/sord``, in Bash shell do::

        export PYTHONPATH=~/packages

    Alternatively, if you are the administrator of your Python installation, you
    can do::

        ./setup.py path


User Guide
==========


Quick test
----------

Run a simple point source explosion test and plot a snapshot of particle
velocity (plotting requires that Matplotlib is installed)::

    cd scripts/example
    ./sim.py -i
    ./plot.py

.. image:: doc/example.png


Scripting with Python
---------------------

For a simple example consider the explosion test, `<scripts/example/sim.py>`__:

.. include:: scripts/example/sim.py
   :literal:

Every script starts by importing the ``sord`` module.  SORD parameters are
specified as local variables that are passed to the ``sord.run()`` function by
the ``locals()`` built-in Python function.  A complete list of possible SORD
parameters and default values are specified in `<parameters.py>`__.

Python scripting enables great flexibilty for assigning parameters. 
provides great flexibility.  For example, it may be desirable to specify the
total run time, and use that to determine the number of time steps::

    T = 100.0            # total time temporary variable
    nt = int( T / dt )   # number of time steps

The ``T`` variable is not a valid SORD parameter; it is only sued for temporary
storage.  Variables with single single character names or names ending with an
underscore, are ignored by SORD, so may be safely used for temporary storage.


Running jobs
------------

Each time ``sord.run()`` is called, a run directory is created at the location
set by the ``rundir`` parameter (``tmp/`` in this case).  The directory
contains the executable and scripts to run the code, and will contain all of
the generated output and metadata.  From the run directory, start the job
interactively with the ``run.sh`` script::

    tmp/run.sh

Or, submit the job to the batch system with the ``queue.sh`` script
::

    tmp/queue.sh


Output (and large input, such as the material model) is stored in flat binary
binary files.  Statistic, such as peak acceleration and peak velocity, are
computed periodically during each run and stored in the ``stats/`` directory.


Boundary Conditions
-------------------

Boundary conditions for the six faces of the model domain are specified by the
parameters ``bc1`` (near-size, x, y, and z faces) and ``bc2`` (far-side, x, y,
and x faces).  The symmetry boundary conditions can be use to reduce
computations for problems where they are applicable.  These are not used for
specifying internal slip boundaries. However, for problems with symmetry across
a slip surface, the fault may be placed at the boundary and combined with an
anti-mirror symmetry condition.  The following BC types are supported:

**Type 0:** vacuum free-surface.  Stress is zero in cells outside the boundary.

.. image:: doc/bc0.png

**Type 3:** rigid surface. Displacement is zero at the boundary.

.. image:: doc/bc3.png

**Type 1:** mirror symmetry at the node.  Normal displacement is zero at the
boundary.  Useful for a boundary corresponding to the plane orthogonal to the
two nodal planes for double-couple point sources, or the plane normal to the
mode-III axis for symmetric ruptures.

.. image:: doc/bc1.png

**Type 2:** mirror symmetry at the cell. Same as type 1, but centered on the cell.

.. image:: doc/bc2.png

**Type -1:** anti-mirror symmetry at the node.  Tangential displacement is zero
at the boundary.  Useful for a boundary corresponding to the nodal planes of
double-couple point sources, or the plane the plane normal to the mode-II axis
for symmetric ruptures.

.. image:: doc/bc-1.png

**Type -2:** anti-mirror symmetry at the cell.  Same as type -1, but centered
on the cell.  Can additionally be used when the boundary corresponds to the
slip surface for symmetric ruptures.

.. image:: doc/bc-2.png

**Type 10:** perfectly match layer (PML) absorbing boundary

Example: a problem with a free surface at Z=0, and PML aborbing boundaries on
all other boundary faces::

    bc1 = 10, 10, 0
    bc2 = 10, 10, 10


Defining the fault rupture surface
----------------------------------

Fault rupture always follows a surface of the (possibly non-planar) logical
mesh.  The orientation of the fault plane is defined by the ``faultnormal``
parameter.  This can be either 1, 2, or 3 corresponding to surfaces normal to
the j, k, or l logical mesh directions. Any other value (typically 0) disables
rupture altogether. The location of the rupture plane with in the mesh is
determined by the ``ihypo`` parameter, which has a dual purpose of also
defining the nucleation point. So, the indices of the collocated fault double
nodes are given by ``int(ihypo(faultnormal))``, and ``int(ihypo(faultnormal)) +
1``. For example, a 3D problem of dimensions 200.0 x 200.0 x 200.0, with a
fault plane located at z = 100.0, and double nodes at l = (21, 22), may be set
up as such::

    dx = 5.0
    faultnormal = 3
    ihypo = 21, 21, 21.5
    nn  = 41, 41, 42
    bc1 = 0, 0, 0
    bc2 = 0, 0, 0

For problems with symmetry across the rupture surface (where mesh and material
properties are mirror images), the symmetry may be exploited for computational
savings by using an appropriate boundary condition and solving the elastic
equations for only one side of the fault.  In this case, the fault double nodes
must lie at the model boundary, and the and the cell-centered anti-mirror
symmetry condition used.  For example, reducing the size of the previous
example to put the rupture surface along the far z boundary::

    nn = 41, 41, 22
    bc2 = 0, 0, -2

Alternatively, put the rupture surface along the near z boundary::

    ihypo = 21, 21, 1.5
    nn = 41, 41, 22
    bc1 = 0, 0, -2
    bc2 = 0, 0, 0

Further symmetries may present. If our previous problem has slip only in the
x direction, then we may also use node-centered mirror symmetry along the in-plane 
axis, and node-centered anti-mirror symmetry along the anti-plane axis, to reduce
computations eight-fold::

    ihypo = 21, 21, 21.5
    nn = 21, 21, 22
    bc1 = 0, 0, 0
    bc2 = -1, 1, -2


Development
===========

Suggestions for improvements, and contributions to the SORD code and
documentation are greatly appreciated.


Debugging
---------

The ``debug`` input parameter is useful for finding problems, and can take the
following values:

    **0**: Debugging off.

    **1**: Verbose status output.

    **2**: Synchronize multiple processors. This is useful for tracking down MPI
    related bugs.

    **3**: Dump field variable output in text files at every step. Only do this for
    small tests or you will fill up your disk!

Additionally, SORD can be compiled and run under a debugger using the ``-g`` or
``--debugging`` option.


Profiling
---------

Internal code timings, for benchmarking performance, are collected and saved to
the ``prof/`` directory.  The file format is flat binary that can be examined
with the UNIX command ``od -f``.  Eight categories are timed for every time
iteration step, and save in the following files:

    **1time**: Time integration subroutine.

    **2stress**: Stress subroutine.

    **3accel**: Acceleration subroutine, including multiprocessor halo swapping
    communications.

    **4stats**: Statistics subroutine, including multiprocessor min/max reductions.

    **5ckpt**: Checkpoint subroutine.

    **6mp**: Aggregate of all multiprocessor operations, including halo swap,
    global reductions, and parallel I/O.

    **7io**: Aggregate of all input and output operations, including checkpointing
    and field I/O.

    **8step**: Total for complete time iteration.

Profiling can be very difficult to interpret for multiprocessor runs.  Timing
is only saved for the master processor.  It can be helpful to synchronize the
processors using ``debug = 2`` to give more accurate relative timing values.

Additionally, SORD can be run with compiler generated code profiling using the
``-p`` or ``--profiling`` option.


Source control
--------------

We use `Bazaar <http://bazaar-vcs.org/>`_ for version control.  The simplest
way to install Bazaar is to use Python `Easy Install
<http://pypi.python.org/pypi/setuptools>`_::

    easy_install bzr

To retrieve the latest version of SORD
::

    bzr get http://earth.usc.edu/~gely/sord

See code changes since the last commit
::

    bzr diff

Undo changes
::

    bzr revert

Commit changes
::

    bzr commit -m "Great new feature"

Create a patch
::

    bzr send -o great-new-feature.patch

See the
`Bazaar tutorials <http://doc.bazaar-vcs.org/latest/en/tutorials/index.html>`__
for more.

