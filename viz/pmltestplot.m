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
  tsfigure( 1 )
  sensor = sensors(i,:);
  cd 'pmltest1'
  [ tt, vt, tta, vta ] = timeseries( 'v', sensor, 1 );
  plot( tta, vta, ':' )
  hold on
  plot( tt, vt(:,1) )
  cd '..'
  cd 'pmltest2'
  [ tt, vt, tta, vta ] = timeseries( 'v', sensor, 1 );
  plot( tt, vt(:,1), '--' )
  cd '..'
  title( num2str( sensor ) )
  xlabel( 'Time' )
  ylabel( 'Velocity' )
end

