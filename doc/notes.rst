==========
SORD Notes
==========

This is a collection of notes on SORD that will eventually be filled out into a
user manual.

Boundary Conditions
-------------------

Boundary conditions for the six faces of the model domain are specified by the
parameters ``bc1`` (near-size, x, y, and z faces) and ``bc2`` (far-side, x, y,
and x faces).  The symmetry boundary conditions can be use to reduce
computations for problems where they are applicable.  These are not used for
specifying internal slip boundaries. However, for problems with symmetry across
a slip surface, the fault may be placed at the boundary and combined with an
anti-mirror symmetry condition.  The following BC types are supported:

0: Vacuum free surface. Stress is zero in cells outside the boundary.

.. image:: bc0.png

1: Mirror symmetry at the node. Normal displacement is zero at the boundary.
Useful for a boundary corresponding to the plane orthogonal to the two nodal
planes for double-couple point sources, or the plane normal to the mode-III
axis for symmetric ruptures.

.. image:: bc1.png

2: Mirror symmetry at the cell. Same as type 1, but centered on the cell.

.. image:: bc2.png

-1: Anti-mirror symmetry at the node. Tangential displacement is zero at the
boundary.  Useful for a boundary corresponding to the nodal planes of
double-couple point sources, or the plane the plane normal to the mode-II axis
for symmetric ruptures.

.. image:: bc-1.png

-2: Anti-mirror symmetry at the cell. Same as type -1, but centered on the
cell.  Can additionally be used when the boundary corresponds to the fault
surface for symmetric ruptures.

.. image:: bc-2.png

3: Rigid boundary. Displacement is zero at the boundary.

.. image:: bc3.png

10: Perfectly match layer (PML) absorbing boundary.

Example: a problem with a free surface at Z=0, and PML aborbing
boundaries on all other boundary faces::

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


