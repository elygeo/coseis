% Plot PML Test

loc = [
  0  0  60
  0  60 60
  60 60 60
];

n = size( loc, 1 );

for i = 1:n
  tsfigure( 0 )
  cd 'pmltest1'
  meta
  sensor = ihypo + loc(i,:);
  [ msg, t, v, x, ta, va, labels ] = tsread( 'v', sensor, 1 );
  cd '..'
  h1 = axes( 'Position', [ 4/32 23/42 26/32 16/42 ] );
  plot( ta, va, ':' )
  hold on
  plot( t, v, 'k' )
  ylim( [ -.01 .03 ] )
  ylabel( 'Velocity' )
  title( num2str( loc(i,:) ) )
  h2 = axes( 'Position', [ 4/32 3/42 26/32 16/42 ] );
  plot( ta-dt, va, ':' )
  hold on
  plot( t, v(:,1), 'k' )
  ylim( [ -.001 .001 ] )
  ylabel( 'Velocity' )
  xlabel( 'Time' )
  cd 'pmltest2'
  meta
  sensor = ihypo + loc(i,:);
  [ msg, t, v, x, ta, va, labels ] = tsread( 'v', sensor, 1 );
  cd '..'
  axes( h1 )
  plot( t, v, 'k--' )
  axes( h2 )
  plot( t, v, 'k--' )
  drawnow
  file = sprintf( 'frame%d.ps', i );
  print( '-depsc', file )
end

%unix( 'pdftk frame*.pdf cat output pmltest.pdf' );

