% Terashake grid

clear all
clf
format compact
colorscheme

srcdir
cd 'data'
xf = [ 0 28.230 74.821 103.231 129.350 198.778 ];
n = [ 1991 161 ];
fid = fopen( 'ts1.l', 'r', 'l' ); ts = fread( fid, n, 'float32' ); fclose( fid );

ts = ts * 1e-6 + 10;
axes( 'Position', [ .02 .02 .96 .96 ] );
imagesc( .1 * [ 0 n(1) ], .1 * [ 0 n(2) ], fliplr( ts' ), [ -20 20 ] )
hold on
plot( 190, 5, 'p', 'MarkerSize', 12 )
plot( [ 0 0 199.1 199.1 0 ], [ 0 16 16 0 0 ] )
for i = 2:5
  plot( xf(i) * [ 1 1 ], [ 0 16 ] )
end

colorscale( '\Tau_s: ', 'MPa', [ 80 120 ], [ 20 22 ] )
axis image
axis off
drawnow

