    Using the SCEC Version 4 southern California
         reference seismic velocity model
                  9/27/05  H. Magistrale

  First read:
Magistrale, H., S. Day, R. W. Clayton, and R. Graves, 2000. The SCEC
southern California reference 3D seismic velocity model Version 2,
Bull. Seismol. Soc. Am., v. 90, no. 6B, p. S65-S76

  This has pictures of the basin boundaries, tomographic coverage, etc.
A pdf file of a preprint of the manuscript is in the anonymous ftp site:
  moho.sdsu.edu
in the directory:
pub/Version2
with the file name 'manuscript.pdf'.

  Version 3 differs from Version 2 in including tomographically determined
Upper mantle seismic velocities. See:
Kohler, M., H. Magistrale, and R. Clayton, 2003, Mantle heterogeneities and
the SCEC three-dimensional seismic velocity model version 3, Bulletin 
Seismological Society of America 93, 757-774.

  Version 4 - the current version - differs from Version 3 in the 
following ways:
San Bernardino Valley: A new San Bernardino Valley basement is based 
on recent USGS inversion of gravity data confirmed by comparison to a 
seismic reflection line. The new model features a deep trough in the 
central valley, in contrast to the previous flat-bottomed valley 
model. The new basement joins smoothly to the relatively shallow 
Chino basin to the west.
Salton Trough: A new model is motivated by the needs of TeraShake 
simulations of southern San Andreas fault events. Depth to basement 
is defined by a combination of seismic refraction surveys, inversion 
of gravity observations, surface geology, and boreholes. Sediment 
velocity-depth gradients depend on the nature of the basement, 
smoothing merging into deep metasedimentary basement, and having a 
discontinuity above shallow crystalline basement. The model includes 
the portion of the Trough south of the international border.
Vp-density: The new Vp-density relation is based on density 
measurements from oil well samples in the Los Angeles basin and the 
San Gabriel Valley, geotechnical boreholes throughout southern 
California, and 12 oil wells along the LARSE lines.
The newly determined Vp-density ratio is constant, in contrast to the 
old relation. This is true even for low Vp, as defined by the 
geotechnical data. The new densities are higher, for a given Vp, than 
the old. This will tend to lower the Poisson ratio, which will lower 
Vp/Vs; that is, changing the Vp-density relation produces a new Vs 
model.

  The model exists as a fortran code and associated files.
The code reads a file of points specified by latitude, longitude and
depth, and writes out Vp, Vs, and density at those points.

  The compressed tar file Version4.0.tar.Z contains all the files.
First uncompress (assuming a Unix machine):
   uncompress Version4.0.tar.Z
        or
   zcat Version4.0.tar.Z > Version4.0.tar
Next extract the files:
   tar xvf Version4.0.tar
Then compile:
   f77 version4.0.f -o version3.0

  The file of points should be named "btestin" (this can be changed
in the subroutine "readpts"). Here is a sample file:

8
33.50000 -118.50000 30.0
33.50000 -118.50833 30.0
33.50000 -118.51667 30.0
33.50000 -118.52500 30.0
33.97200 -118.08800   3000.0
33.97200 -118.08800   3001.0
33.97200 -118.08800   3002.0
33.97200 -118.08800   3003.0

  The first line contains the number of points in the file
(8 in this example). The code has array dimensions allowing
up to 750,000 points. To handle more points, the arrays can
be redimensioned by changing the parameter "ibig" in the include
file "in.h", or by dividing the total point set into chunks
of less than 750,000.
  The remaining lines are the latitude, longitude (both in
decimal degrees, with the longitude negative, because this
is the western hemisphere), and depth (in meters. Note in the
version 1 model the depth was given in feet). These are read
with free format. It is a common error to forget the negative
longitudes.
  The model consists of rule and object parameterized basins
embedded in a tomography background. The objects are reference
surfaces outlined by polygons, so the code must figure out
which polygon an input point is within. You can speed up the code
by putting all of the points at the same latitude and longitude
sequentially in the input file (as in the last 4 points in the
sample). See note 2 below.
  The output will be a file name "btestout" (this name can be
changed in the subroutine "writepts"). Here is a sample (for
the last 4 points of the input sample):

33.97200 -118.08800   3000.00   3509.8   1817.4   2304.0
33.97200 -118.08800   3001.00   3510.8   1818.1   2304.2
33.97200 -118.08800   3002.00   3511.8   1818.9   2304.3
33.97200 -118.08800   3003.00   3512.8   1819.6   2304.5

  These echo the latitude, longitude and depth, and then give
Vp, Vs (both in m/s), and density (in kg/m^3).

  Notes and warnings:

  1. This is a research code, and bugs and glitches may be revealed
as it is subjected to new applications.

  2. Input points can be in any order, although the code will run
faster if the points are given with the same lat-longs sequentially.
If you want to recover the geotechnical borehole shear wave
you must give the lat-long to within 50 m of the borehole's lat-long.

  3. The code assigns a minimum density of 1500 kg/m^3 to points
with a Vp of 1586 m/s or less. This is done at line 825 of the
main program.

  4. The boundary between the Los Angeles area basins (see note 6) and
the background model is relatively smooth except along the south and
west edges (mostly in the ocean) of the basins model. This produces
an artificial abrupt transition from the seismically slow basin
sediments to the faster background model. This may produce unrealistic
artifacts in, for example, waveform modeling. Watch out.

  5. Points outside the area of the tomographic background (see note 6)
will be assigned velocities from a smooth Hadley-Kanamori 1D model.

