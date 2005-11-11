% Plot Kostrov results

clear all

meta
tsfigure( 0 )

dofilter = 1;
for ir = 10:10:50
  sensor = ihypo + [ ir 0 0 ];
  [ t, v, ta, va, labels, msg ] = timeseries( 'sv', sensor, 1 );
  plot( t, v(:,1) )
  hold on
  plot( ta, va, ':' )
end
xlabel( 'Time' )
ylabel( 'Slip Velocity' )

print -dpsc2 kostrov.ps
unix( 'ps2pdf kostrov.ps' )

