====
SORD
====
Support Operator Rupture Dynamics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: ely-saf-surface.jpg
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
<http://www.blackwell-synergy.com/doi/abs/10.1111/j.1365-246X.2007.03633.x>`__,
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
`[PDF] <http://earth.usc.edu/~gely/pub/ely-saf-20091030.pdf>`__
`[Electronic supplement] <http://earth.usc.edu/~gely/ely-saf-esupp.html>`__


User Guide
==========

Quick test
----------

Run a simple point source explosion test and plot a 2D slice of particle
velocity::

    cd scripts/sord
    python example.py -i

Plotting requires Matplotlib, and the result should look like this:

    .. image:: ../scripts/sord/example.png

Scripting with Python
---------------------

For a simple example consider the above test,
`sim.py <../scripts/sord/example.py>`__:

.. include:: ../scripts/sord/example.py
   :literal:

Every script starts by importing the ``cst`` module.  SORD parameters are
specified as a dictionary and/or keyword arguments passed to the
``cst.sord.run()`` function. The ``locals()`` built-in Python function is a
convenient way to create the parameter dictionary from the local scope.  Any
dictionary parameters 

A complete list of possible SORD parameters and default values are specified in
`parameters.py <../cst/sord/parameters.py>`_.

FIXME: OUTDATED.

The Python language gives a powerful way to construct SORD input.  For example,
it may be desirable to specify the total simulation time, and divide by ``dt``
to determine the number of time steps::

    T = 100.0            # total time temporary variable
    nt = int( T / dt )   # number of time steps

The ``T`` variable is not a valid SORD parameter; it is only used for temporary
storage.  Variables with single single character names or names ending with an
underscore, are ignored by SORD, so may be safely used for temporary storage.
More example scripts can be found in the ``scripts`` directory.


Running jobs
------------

The ``cst.sord.run()`` function does four tasks: (1) configure job
parameters (2) compile the source code if necessary (3) create a new run
directory populated with executable code and input files, and (4) launch the
job interactively or through a batch processing system.  Step (2) only occurs
as needed for a fresh install or when the source code has been modified.  By
default, step (4) is skipped, giving the user an opportunity to inspect the
run directory prior to launching the job.

FIXME: UNFINISHED SECTION.

has been done beforehand, so is skipped.  
cop
and
called, a run directory is staged at the
location set by the ``rundir`` parameter (``tmp/`` in this case).  The
directory contains the executable and scripts to run the code, and will contain
all of the generated output and metadata.  You may examine the run directory
and manually launch the executable from there.  The job can be run automatically 

Or, submit the job to the batch system


Field I/O
---------

Multidimensional field arrays can be accessed for input and output through the
``fieldio`` list.  The `fieldnames.py <../cst/sord/fieldnames.py>`_ file
specifies the list of available field variables, which are categorized in four
ways: (1) static vs. dynamic, (2) settable vs. output only, (3) node vs. cell
registration, and (4) volume vs. fault surface.  For example, density ``rho``
is a static, settable, cell, volume variable.  Slip path length ``sl`` is a
dynamic, output, node, fault variable.  The ``fieldio`` list is order dependent
with subsequent inputs overwriting previous inputs.  So, for example, a field
may be assigned to one value for the entire volume, followed by a different
value for a sub-region of the volume.

All field I/O operations require slice indices ``[j,k,l,t]``, which specify a
four-dimensional sub-volume of the array in space and time.  Array indexing
starts at 1 for the first node, and 1.5 for the first cell.  Negative indices
count inward from end of the array, starting at -1 for the last node, and -1.5
for the last cell.  Indices can be either a single index, a range ``(start,
end)``, or a strided range ``(start, end, step)``.  Empty parentheses ``()`` are
shorthand for a full range.  Empty brackets ``[]`` are shorthand for the entire
4D volume.  Some examples of slice notation::

    [10, 20, 1, (1,-1)]       # Single node, full time history
    [10.5, 20.5, 1.5, ()]     # Single cell, full time history
    [2, (), (), (1,-1,10)]    # j=2 node surface, every 10th time step
    [(), (), (), -1]          # Full 3D volume, last time step
    []                        # Entire 4D volume

Each member of the ``fieldio`` list contains a mode, a field name, and slice
indices, followed by mode dependent parameters.  The following I/O modes are
available, where ``'f'`` is the field variable name (from the list
fieldnames.py_), and ``[]`` are the slice indices::

    ('=',   'f', [], val),             # Set f to value
    ('+',   'f', [], val),             # Add value to f
    ('=s',  'f', [], val),             # Set f to random numbers in range (0, val)
    ('=f',  'f', [], val, tfunc, T),   # Set f to time function with period T, scaled by val
    ('=r',  'f', [], filename),        # Read from filename into f
    ('=R',  'f', [], filename),        # Read from filename into f with exrapolation.
    ('=w',  'f', [], filename),        # Write f to filename
    ('=wi', 'f', [], filename),        # Write weighted average of f to filename.

A letter ``'i'`` in the mode indicates sub-cell positioning via weighted
averaging.  In this case the spatial indices are single logical coordinates
that may vary continuously over the range.  The fractional part of the index
determines the weights.  For example, an index of 3.2 to the 1D variable f
would specify the weighted average: 0.8 * f(3) + 0.2 * f(4).

Reading and writing to disk uses flat binary files where j is the fastest
changing index, and t is the slowest changing index.  Mode 'R' extrapolates any
singleton dimensions to fill the entire array.  This is useful for reading 1D
or 2D models into 3D simulations, obviating the need to store (possibly very
large) 3D material and mesh coordinate files.

All input modes may use '+' instead of '=' to add to, rather than replace,
preexisting values.  For a list of available time functions, see the
``time_function`` subroutine in `util.f90 <../cst/sord/src/util.f90>`_.  The
routine can be easily modified to add new time functions.  Time functions can
be offset in time with the ``tm0`` initial time parameter.


Boundary Conditions
-------------------

Boundary conditions for the six faces of the model domain are specified by the
parameters ``bc1`` (near-size, x, y, and z faces) and ``bc2`` (far-side, x, y,
and x faces).  The symmetry boundary conditions can be use to reduce
computations for problems where they are applicable.  These are not used for
specifying internal slip boundaries. However, for problems with symmetry across
a slip surface, the fault may be placed at the boundary and combined with an
anti-mirror symmetry condition.  The following BC types are supported:

**Type 0**: Vacuum free-surface.  Stress is zero in cells outside the boundary.

    .. image:: bc0.png

**Type 3**: Rigid surface. Displacement is zero at the boundary.

    .. image:: bc3.png

**Type 1**: Mirror symmetry at the node.  Normal displacement is zero at the
boundary.  Useful for a boundary corresponding to (a) the plane orthogonal to
the two nodal planes of a double-couple point source, (b) the plane normal to
the mode-III axis of a symmetric rupture, or (c) the zero-width axis of a 2D
plane strain problem.

    .. image:: bc1.png

**Type -1**: Anti-mirror symmetry at the node.  Tangential displacement is zero
at the boundary.  Useful for a boundary corresponding to (a) the nodal planes
of a double-couple point source, (b) the plane normal to the mode-II axis of a
symmetric rupture, or (c) the zero-width axis of a 2D antiplane strain problem.

    .. image:: bc-1.png

**Type 2**: Mirror symmetry at the cell. Same as type 1, but centered on the cell.

    .. image:: bc2.png

**Type -2**: Anti-mirror symmetry at the cell.  Same as type -1, but centered
on the cell.  Can additionally be used when the boundary corresponds to the
slip surface of a symmetric rupture.

    .. image:: bc-2.png

**Type 10**: Perfectly match layer (PML) absorbing boundary.

Example: a 3D problem with a free surface at Z=0, and PML absorbing boundaries
on all other boundary faces::

    nn  = 50, 50, 50
    bc1 = 10, 10,  0
    bc2 = 10, 10, 10

Example: a 2D antiplane strain problem with PML absorbing boundaries.  The
number of nodes is 2 for the zero-width axis::

    nn  = 50, 50,  2
    bc1 = 10, 10, -1
    bc2 = 10, 10, -1


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

Alternatively, put the rupture surface along the near z boundary
::

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


Memory Usage and Scaling
========================

For rectilinear meshes, 23 single precision (four-byte) memory variables are
required per mesh point.  Curvilinear meshes have two options with a trade-off
in memory usage vs. floating-point operations.  Stored operators require 44
variables per mesh point and give the best performance, while on-the-fly
operators require 23 variables per mesh point at the cost of a factor of four
increase in floating point operations.  As CPU improvement tends to out-pace
memory bandwidth improvement, in the future, on-the-fly operators may become
faster than stored operators.  The operator type is controlled by the
``oplevel`` parameter, but can generally be left alone, as the default is to
automatically detect rectilinear and curvilinear meshes and assign the proper
operator type for fastest performance.

On current hardware, computation time is on the order of the one second per
time step per one million mesh points.  SORD scalability has been benchmarked
up to 16 thousand processors at the TACC Ranger facility.  The following chart
is the wall-time per step for 8 million mesh points per core (click for PDF):

.. image:: ../scripts/benchmark/sord-benchmark-ranger.png
    :target: ../scripts/benchmark/sord-benchmark-ranger.pdf

This benchmark tests computation only. For many applications, disk output is
the primary bottleneck and will limit scalability.

Achieving I/O Performance
-------------------------

For computations with significant disk input and output, on large numbers of
cores, domain decomposition layout is critical to performance.  The most
important principle is to minimize partitioning of I/O amongst processes.  A
best-case scenario is that a file is accessed by only a single processes.  The
following example is used to illustrate.  Using 4096 cores, compute spontaneous
rupture, outputting slip-velocity on the fault plane as well as vertical
ground-motions at selected sites::

    nproc3 = 1, 1024, 4                        # number of processes in j, k, l
    nn = 6000, 4000, 800                       # number of mesh nodes
    faultnormal = 2                            # fault normal to y-axis
    ihypo = 2000, 2000, 100                    # hypocenter indices
    i = (2000,4000), 2000, (1,160), (1,-1, 10) # fault output 4d region
    fieldio = [
        ( '=w', 'sv1', i, 'slip-velocity-x' ),
        ( '=w', 'sv2', i, 'slip-velocity-y' ),
        ( '=w', 'sv3', i, 'slip-velocity-z' ),
        ( '=w', 'v3', [2000, 1000, -1, ()], 'vz-station-1' ),
        ( '=w', 'v3', [2000, 1500, -1, ()], 'vz-station-2' ),
        ( '=w', 'v3', [2000, 2500, -1, ()], 'vz-station-3' ),
        ( '=w', 'v3', [2000, 3000, -1, ()], 'vz-station-4' ),
    ]

Here the problem has been partitioned (using nproc3) such that the entire fault
output surface lies on a single process by making many thin slices parallel to
the fault-plane, and placing the first vertical domain boundary below the depth
of the fault output region.  The surface stations are located at a single node
point, so they always naturally occur on a single process.  With this
configuration no coordination is required amongst the processes, and all I/O
occurs independently.

To scale this problem to higher numbers of processes, we eventually must start
partitioning the fault-plane I/O.  In that case, the second most important
principle for designing domain decomposition is to minimize I/O striping.
Striping is an alternating or cyclical pattern of access to file from multiple
processes.  A best-case scenario is for each processes to accesses a contiguous
section of a file, rather than many small segments.  The important thing to
know about SORD is that I/O occurs in Fortran-contiguous order, where the first
index changes fastest.  To scale up our example to 32,768 cores, we prevent
striping by keeping the number of processes along the x-axis equal to one::

    nproc3 = 1, 1024, 32

Some I/O layouts are not amenable to minimizing partitioning and striping.  An
example is two orthogonal output planes, such as the fault surface in addition
to the entire ground surface.  One solution to that situation is to run
multiple computations for each of the desired outputs, with each optimally
partitioned for the output.

In cases where minimizing partitioning and striping does not achieve acceptable
performance, depending on the system architecture, it may be useful to test
non-collective MPI-IO by setting the parameter::

    mpout = -1

When all else fails, another option is to turn off MPI-IO altogether with:
::

    mpout = 0

In that case, each process writes a separate output file.  If you have been
careful to minimize I/O striping, assembling the separate output files may be
as simple as concatenating them together with the UNIX ``cat`` utility.  This
approach is limited by the capability of the file system to handle large
numbers files.


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

    **3**: Dump field variable output in text files at every step. Only do this
    for small tests or you will fill up your disk!

During testing, compiler checks, such as array overflow and floating-point
exceptions, can be turned on with the ``-t`` or ``--testing`` option.
Additionally, to compile and run under a debugger use the ``-g`` or
``--debugging`` option.  Naturally, these options depend on the capabilities of
the particular compiler.  The specific flags passed to the compiler can be
configured by editing ``conf.py``.


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


.. vim: filetype=rst

