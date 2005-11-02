% Plot PML Test

clear all

meta
tsfigure( 1 )

subplot( 3, 2, 1 )
[ tt, vt, tta, vta, labels, msg ] = timeseries( 'v', [ 31 21 21 ], 1 );
tsplot

subplot( 3, 2, 2 )
[ tt, vt, tta, vta, labels, msg ] = timeseries( 'v', [ 31 26 21 ], 1 );
tsplot

subplot( 3, 2, 3 )
[ tt, vt, tta, vta, labels, msg ] = timeseries( 'v', [ 31 31 21 ], 1 );
tsplot

subplot( 3, 2, 4 )
[ tt, vt, tta, vta, labels, msg ] = timeseries( 'v', [ 31 31 26 ], 1 );
tsplot

subplot( 3, 2, 5 )
[ tt, vt, tta, vta, labels, msg ] = timeseries( 'v', [ 31 31 31 ], 1 );
tsplot

subplot( 3, 2, 6 )
[ tt, vt, tta, vta, labels, msg ] = timeseries( 'v', [ 31 26 26 ], 1 );
tsplot

%print -dpsc2 pml.ps

