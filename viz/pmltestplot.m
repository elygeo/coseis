% Plot PML Test

loc = [
  0  0  20
  10 0  20
  10 10 20
  20 20 20
];

n = size( loc, 1 );

for i = 1:n
  tsfigure( 0 )
  cd 'pmltest1'
  meta
  sensor = ihypo + loc(i,:);
  [ t, v, ta, va, labels, msg ] = timeseries( 'v', sensor, 1 );
  cd '..'
  h1 = subplot(2,1,1);
  plot( ta, va, ':' )
  hold on
  plot( t, v(:,1), 'k' )
  plot( t, v(:,2), 'r' )
  plot( t, v(:,3), 'b' )
  title( num2str( sensor ) )
  ylabel( 'Velocity' )
  ylim( .03 * [ -1 1 ] )
  h2 = subplot(2,1,2);
  plot( ta, va, ':' )
  hold on
  plot( t, v(:,1), 'k' )
  plot( t, v(:,2), 'r' )
  plot( t, v(:,3), 'b' )
  ylim( .0003 * [ -1 1 ] )
  ylabel( 'Velocity' )
  xlabel( 'Time' )
  cd 'pmltest2'
  meta
  sensor = ihypo + loc(i,:);
  [ t, v, ta, va, labels, msg ] = timeseries( 'v', sensor, 1 );
  cd '..'
  axes( h1 )
  plot( t, v(:,1), 'k--' )
  plot( t, v(:,2), 'r--' )
  plot( t, v(:,3), 'b--' )
  axes( h2 )
  plot( t, v(:,1), 'k--' )
  plot( t, v(:,2), 'r--' )
  plot( t, v(:,3), 'b--' )
end

