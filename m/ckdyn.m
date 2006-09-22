% Terashake grid

clear all
clf
format compact
colorscheme

srcdir
cd 'data'
xf = 10 * [ 0 28.230 74.821 103.231 129.350 198.778 ];
zf = [ 0; 160 ] * ones( size( xf ) );
n = [ 1991 161 ]
fid = fopen( 'ts1.l', 'r', 'l' ); th = fread( fid, n, 'float32' ); fclose( fid );

thmax = max( abs( th(:) ) )
axes( 'Position', [ .02 .02 .96 .96 ] );
imagesc( fliplr( th' ), thmax * [ -3 1 ] )
hold on
plot( [ xf; xf ], zf, ':' )
axis image
colorbar( 'SouthOutside' )
drawnow

