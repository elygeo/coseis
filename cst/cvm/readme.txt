==========
SCEC CVM 4
==========

Fixes
-----

*   For SUN Fortran, optimization greater than -O2 breaks it.

*   Do not rely on the compiler to initialize variables to zero.

*   Any open statements with the syntax type='old', change to standard syntax
    status='old'.

*   Remove unused labels (stops warning messages): 1188 877 1182

*   Change character declarations to character(n) form (stops warnings)


The following note from Scott Callaghan describes another possibly necessary
fix:

I added the line at 2233:
rtvelp(j) = 0.
to make sure the array is initialized.

I think the rest of my changes were in the mohodepth:  basically I changed
everything to double precision.  The int1, int2, int3, int4 are intermediate
variables which I used to break down where the issues occurred;  I don't think
they're necessary.  However, rdemoh does need to be double precision, so all
the variables that contribute to the calculation need to be too.  I didn't know
how to force computations to be double when the inputs are floats.

I think that's the extent of my changes, but there may be other things as well.
Let me know if you have any questions.

       double precision rsuqus(ibig,isurmx)
       double precision rdemoh, rtemp01, rtemp05, rtemp07, rtemp22
       double precision rtemp36,rtemp47,rtemp50,rtemp55,rtemp56
       double precision rtemp57,rtemp62,rtemp63,rtemp64,rtemp65
       double precision rtemp68,rtemp69,rtemp70,rtemp73
       double precision rrt,rru

Documentation
=============

`SCEC CVM page <http://www.data.scec.org/3Dvelocity/>`__

Magistrale, H., et al. (1996) *A geology-based 3D velocity model of the Los
Angeles basin sediments*, BSSA
`86(4):1161–1166 <http://www.bssaonline.org/cgi/content/abstract/86/4/1161>`__

Magistrale, H., et al. (2000), *The SCEC southern California reference
three-dimensional seismic velocity model version 2*, BSSA,
`90(6B):S65–76 <http://www.bssaonline.org/cgi/content/abstract/90/6B/S65>`__,
doi: 10.1785/0120000510. 
`[PDF] <Magistrale2000.pdf>`__

.. vim: filetype=rst

