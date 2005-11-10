% Plot PML Test

sensors = [
  41 41 41
  51 41 61
  61 41 61
  51 51 61
  61 51 61
  61 61 61
];

n = size( sensors, 1 );

for i = 1:n
  tsfigure( 0 )
  title( num2str( sensor ) )
  subplot(2,1,1)
  sensor = sensors(i,:);
  cd 'pmltest1', [ t, v, ta, va ] = timeseries( 'v', sensor, 1 ); cd '..'
  cd 'pmltest2', [ t, vb ]        = timeseries( 'v', sensor, 1 ); cd '..'
  plot( t, v(:,1) )
  hold on
  plot( t, vb(:,1), '--' )
  plot( ta, va, ':' )
  xlabel( 'Time' )
  ylabel( 'Velocity' )
  subplot(2,1,2)
  plot( t, v(:,1) - vb(:,1) )
  xlabel( 'Time' )
  ylabel( 'Velocity' )
end

