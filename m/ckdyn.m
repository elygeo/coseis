% Terashake grid

clear all
format compact

srcdir
cd 'data'
n = [ 1991 161 ]
fid = fopen( 'th.l', 'r', 'l' ); th = fread( fid, n, 'float32' ); fclose( fid );

srcdir
cd 'runs/ts200'
i1 = [ 1317 0 -81 ];
i2 = [ 2311 0  -1 ];
[ msg, th1 ] = read4d( 'tsm', [ i1 0 ], [ i2 0 ] );
th1 = squeeze( th1 );

clf

subplot(2,1,1)
th1max = max( abs( th1(:) ) )
imagesc( th1', th1max * [ -1 1 ] )
axis image
axis xy
title( 'Th1' )
colorbar( 'SouthOutside' )
drawnow

subplot(2,1,2)
thmax = max( abs( th(:) ) )
imagesc( fliplr( th' ), thmax * [ -3 1 ] )
axis image
title( 'Th' )
colorbar( 'SouthOutside' )
drawnow

