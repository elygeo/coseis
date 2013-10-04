====
SORD
====
Support Operator Rupture Dynamics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: ely-saf-surface.jpg

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

1.  Ely, G. P., S. M. Day, and J.-B. Minster (2008),
    `A support-operator method for visco-elastic wave modeling in 3D
    heterogeneous media
    <http://www.alcf.anl.gov/~gely/pub/Ely2008-GJI.pdf>`__,
    *Geophys. J. Int.*, *172* (1), 331-344,
    `doi:10.1111/j.1365-246X.2007.03633.x
    <http://dx.doi.org/10.1111/j.1365-246X.2007.03633.x>`__.

2.  Ely, G. P., S. M. Day, and J.-B. Minster (2009),
    `A support-operator method for 3D rupture dynamics
    <http://www.alcf.anl.gov/~gely/pub/Ely2009-GJI.pdf>`__,
    *Geophys. J. Int.*, *177* (3), 1140-1150,
    `doi:10.1111/j.1365-246X.2009.04117.x
    <http://dx.doi.org/10.1111/j.1365-246X.2009.04117.x>`__.

3.  Ely, G. P., S. M. Day, and J.-B. Minster (2010),
    `Dynamic rupture models for the southern San Andreas fault
    <http://www.alcf.anl.gov/~gely/pub/Ely2010-BSSA.pdf>`__,
    *Bull. Seism. Soc.  Am.*, *100* (1), 131-150,
    `doi:10.1785/0120090187
    <http://dx.doi.org/10.1785/0120090187>`__.


User Guide
==========

Quick test
----------

Run a simple point source explosion test and plot a 2D slice of particle
velocity::

    cd scripts/sord
    mkdir run
    sord sim.yaml
    python plot.py

Plotting requires Matplotlib, and the result should look like this:

    .. image:: ../scripts/sord/example.png


Running SORD
------------

The simplest way to run SORD is to execute the ``sord`` command giving a
parameter file in YAML_ or JSON_ format. The more powerful way to run the code
is with a Python script. The basic procedure it to import the ``cst`` module,
create a dictionary of parameters, and pass that dictionary to the
``cst.sord.run()`` function. The ``cst/scripts`` directory contains many
examples including the above quick test `sim.yaml
<../scripts/sord/sim.yaml>`__:

.. _YAML: http://www.yaml.org
.. _JSON: http://www.json.org
.. include:: ../scripts/sord/sim.yaml
   :literal:

A complete list of SORD parameters and default values arg given in
`parameters.yaml <../cst/sord/parameters.yaml>`__ and `fieldnames.yaml
<../cst/sord/fieldnames.yaml>`__. In this example, ``rho``, ``vp``, ``vs``,
``v1``, and ``v2`` are 3- and 4-D fields.  Fields may be a single value that is
assigned to the entire array, or various operations that can be performed on
array slices::

    f = val                        # Set f to value
    f = ([], '+', val)              # Add value to f
    f = ([], '=', 'rand', val)      # Random numbers in range (0, val)
    f = ([], '=', 'func', val, tau) # Time function with period tau, scaled by val
    f = ([], '<', 'filename')       # Read filename into f
    f = ([], '>', 'filename')       # Write f into filename

Field variables are categorized in four ways: (1)
static vs. dynamic, (2) settable vs. output only, (3) node vs. cell
registration, and (4) volume vs. fault surface.  For example, density ``rho``
is a static, settable, cell, volume variable. Slip path length ``sl`` is a
dynamic, output, node, fault variable.

Here we have specified the entire 4D volume for the slice using the shorthand
notation empty brackets ``[]``. The array slicing notation follows that of
Python, but is extended here to use integers for node indices and integers +
0.5 for cell indices (1.5, 2.5, 3.5, ...).  Array indexing starts at 1 for the
first node, and 1.5 for the first cell.  Negative indices count inward from end
of the array, starting at -1 for the last node, and -1.5 for the last cell.
Slices can be specified in one of three ways: with a list, with a string, or
using the helper function ``cst.sord.get_slices()``. The helper function is
the only 

    s_ = cst.sord.get_slices()
    j = 10
    k = 20
    []                  # Entire 4D volume
    '[10.5,20.5,1.5,:]' # Single cell, full time history
    '[:,:,:,-1]'        # Full 3D volume, last time step
    [j,k,1,-1]          # Single node, last time step
    s_[j,:,:,::10]      # j=10 node surface, every 10th time step

slice indices and an operation, followed by other parameters.
 The following I/O modes are
available, where ``'f'`` is the field variable name (from the list
fieldnames.yaml_), and ``[]`` are the slice indices::

A tilde ``~`` indicates sub-cell positioning via weighted averaging.  In this
case the spatial indices are single logical coordinates that may vary
continuously over the range.  The fractional part of the index determines the
weights.  For example, an index of 3.2 to the 1D variable f would specify the
weighted average: 0.8 * f(3) + 0.2 * f(4).

Reading and writing to disk uses flat binary files where j is the fastest
changing index, and t is the slowest changing index.  Mode 'R' extrapolates any
singleton dimensions to fill the entire array.  This is useful for reading 1D
or 2D models into 3D simulations, obviating the need to store (possibly very
large) 3D material and mesh coordinate files.

All input modes may use '+' instead of '=' to add to, rather than replace,
preexisting values.  For a list of available time functions, see the
``time_function`` subroutine in `util.f90 <../cst/sord/src/util.f90>`__.  The
routine can be easily modified to add new time functions.  Time functions can
be offset in time with the ``tm0`` initial time parameter.


Boundary Conditions
-------------------

Boundary conditions for the six faces of the model domain are specified by the
parameters ``bc1`` (near-size, x, y, and z faces) and ``bc2`` (far-side, x, y,
and x faces).  The symmetry boundary conditions can be used to reduce
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

    shape = [50, 50, 50, 100]
    bc1 = [10, 10,  0]
    bc2 = [10, 10, 10]

Example: a 2D antiplane strain problem with PML absorbing boundaries.  The
number of nodes is 2 for the zero-width axis::

    shape = [50, 50, 2, 100]
    bc1 = [10, 10, -1]
    bc2 = [10, 10, -1]


Defining the fault rupture surface
----------------------------------

Fault rupture always follows a surface of the (possibly non-planar) logical
mesh.  The orientation of the fault plane is defined by the ``faultnormal``
parameter.  This can be either 1, 2, or 3 corresponding to surfaces normal to
the j, k, or l logical mesh directions. Any other value (typically 0) disables
rupture altogether. The location of the rupture plane with in the mesh is
determined by the ``ihypo`` parameter, which has a dual purpose of also
defining the nucleation point. So, the indices of the collocated fault double
nodes are given by ``int(ihypo[faultnormal])``, and ``int(ihypo[faultnormal]) +
1``. For example, a 3D problem of dimensions 200.0 x 200.0 x 200.0, with a
fault plane located at z = 100.0, and double nodes at l = (21, 22), may be set
up as such::

    delta = [5.0, 5.0, 5.0, 0.1]
    faultnormal = 3
    ihypo = [21, 21, 21.5]
    shape  = [41, 41, 42, 100]
    bc1 = [0, 0, 0]
    bc2 = [0, 0, 0]

For problems with symmetry across the rupture surface (where mesh and material
properties are mirror images), the symmetry may be exploited for computational
savings by using an appropriate boundary condition and solving the elastic
equations for only one side of the fault.  In this case, the fault double nodes
must lie at the model boundary, and the and the cell-centered anti-mirror
symmetry condition used.  For example, reducing the size of the previous
example to put the rupture surface along the far z boundary::

    shape = [41, 41, 22, 100]
    bc2 = [0, 0, -2]

Alternatively, put the rupture surface along the near z boundary::

    ihypo = [21, 21, 1.5]
    shape = [41, 41, 22, 100]
    bc1 = [0, 0, -2]
    bc2 = [0, 0, 0]

Further symmetries may present. If our previous problem has slip only in the
x direction, then we may also use node-centered mirror symmetry along the in-plane
axis, and node-centered anti-mirror symmetry along the anti-plane axis, to reduce
computations eight-fold::

    ihypo = [21, 21, 21.5]
    shape = [21, 21, 22, 100]
    bc1 = [0, 0, 0]
    bc2 = [-1, 1, -2]

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
operator type for fastest performance. The allowed values are:

    | 0: Auto pick 2 or 6
    | 1: Mesh with constant spacing dx
    | 2: Rectangular mesh
    | 3: Parallelepiped mesh
    | 4: One-point quadrature
    | 5: Exactly integrated elements
    | 6: Saved operators, nearly as fast as 2, but doubles the memory usage

On current hardware, computation time is on the order of the one second per
time step per one million mesh points.  SORD scalability has been benchmarked
up to 64 thousand processors at ALCF.  The following chart
is the wall-time per step per core (click for PDF):

.. image:: sord-mpi-benchmark.png
    :target: sord-mpi-benchmark.pdf

