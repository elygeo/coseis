% Terashake grid

clear all
clf
format compact
colorscheme

srcdir
cd 'data'
n = [ 1991 161 ]
fid = fopen( 'ts1.l', 'r', 'l' ); th = fread( fid, n, 'float32' ); fclose( fid );

thmax = max( abs( th(:) ) )
imagesc( fliplr( th' ), thmax * [ -3 1 ] )
axis image
title( 'T_s' )
colorbar( 'SouthOutside' )
drawnow

