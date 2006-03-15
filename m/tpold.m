
clf
format compact
f = 0;

srcdir
cd out/0
meta
j = ihypo(1);
k = ihypo(2);
l = ihypo(3);
subplot( 2,1,1 )
[ msg, t, s ] = tsread( 'sl', [ 101 k l ], f ); plot( t, s, 'k' ); hold on
[ msg, t, s ] = tsread( 'sv', [ 101 k l ], f ); plot( t, s, 'k' )
title( 'In-plane' )
xlabel( 'Time (s)' )
ylabel( 'Slip (m) / Slip rate (m/s)')
subplot( 2,1,2 )
[ msg, t, s ] = tsread( 'sl', [ j 41 l ], f ); plot( t, s, 'k' ); hold on
[ msg, t, s ] = tsread( 'sv', [ j 41 l ], f ); plot( t, s, 'k' )
title( 'Anti-plane' )
xlabel( 'Time (s)' )
ylabel( 'Slip (m) / Slip rate (m/s)')

srcdir
cd out/2b
meta
j = ihypo(1);
k = ihypo(2);
l = ihypo(3);
subplot( 2,1,1 )
[ msg, t, s ] = tsread( 'sl', [ 136 k l ], f ); plot( t, s, 'r--' )
[ msg, t, s ] = tsread( 'sl', [ 286 k l ], f ); plot( t, s, 'r--' )
[ msg, t, s ] = tsread( 'sv', [ 136 k l ], f ); plot( t, s, 'r--' )
[ msg, t, s ] = tsread( 'sv', [ 286 k l ], f ); plot( t, s, 'r--' )
subplot( 2,1,2 )
[ msg, t, s ] = tsread( 'sl', [ j 76 l ], f ); plot( t, s, 'r--' )
[ msg, t, s ] = tsread( 'sv', [ j 76 l ], f ); plot( t, s, 'r--' )

return

srcdir
cd out/3b
meta
j = ihypo(1);
k = ihypo(2);
l = ihypo(3);
subplot( 2,1,1 )
[ msg, t, s ] = tsread( 'sl', [ 136 k l ], f ); plot( t, s, 'b--' )
[ msg, t, s ] = tsread( 'sl', [ 286 k l ], f ); plot( t, s, 'b--' )
[ msg, t, s ] = tsread( 'sv', [ 136 k l ], f ); plot( t, s, 'b--' )
[ msg, t, s ] = tsread( 'sv', [ 286 k l ], f ); plot( t, s, 'b--' )
subplot( 2,1,2 )
[ msg, t, s ] = tsread( 'sl', [ 271 76 l ], f ); plot( t, s, 'b--' )
[ msg, t, s ] = tsread( 'sv', [ 271 76 l ], f ); plot( t, s, 'b--' )

