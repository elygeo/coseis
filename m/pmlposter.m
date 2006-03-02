% Plot PML Test

loc = [
  0  0  20
  10 0  20
  10 10 20
  20 20 20
];

n = size( loc, 1 );
dt = 0.0075;

for i = 1:n
  tsfigure( 0 )
  orient tall
  cd 'pmltest1'
  meta
  sensor = ihypo + loc(i,:);
  [ msg, t, v, ta, va, labels ] = tsread( 'v', sensor, 1 );
  cd '..'
  h1 = axes( 'Position', [ 4/32 23/42 26/32 16/42 ] );
  plot( ta, va, ':' )
  hold on
  plot( t, v(:,1), 'k' )
 %plot( t, v(:,2), 'r' )
 %plot( t, v(:,3), 'b' )
  ylim( [ -.01 .03 ] )
  ylabel( 'Velocity' )
  title( num2str( loc(i,:) ) )
  h2 = axes( 'Position', [ 4/32 3/42 26/32 16/42 ] );
  plot( ta-dt, va, ':' )
  hold on
  plot( t, v(:,1), 'k' )
 %plot( t, v(:,2), 'r' )
 %plot( t, v(:,3), 'b' )
  ylim( [ -.001 .001 ] )
  ylabel( 'Velocity' )
  xlabel( 'Time' )
  cd 'pmltest2'
  meta
  sensor = ihypo + loc(i,:);
  [ msg, t, v, ta, va, labels ] = tsread( 'v', sensor, 1 );
  cd '..'
  axes( h1 )
  plot( t, v(:,1), 'k--' )
 %plot( t, v(:,2), 'r--' )
 %plot( t, v(:,3), 'b--' )
  axes( h2 )
  plot( t, v(:,1), 'k--' )
 %plot( t, v(:,2), 'r--' )
 %plot( t, v(:,3), 'b--' )
  drawnow
  file = sprintf( 'frame%d.ps', i );
  print( '-dpsc2', file )
  %print( '-depsc', file )
  unix( [ 'ps2pdf ' file ] );
end

unix( 'pdftk frame*.pdf cat output pmltest.pdf' );

