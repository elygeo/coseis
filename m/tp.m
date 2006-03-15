% TP timeseries plots

dirs = { '0' '1a' };
xg = [ 0 6000. ];
filter = 0;

clf
h(1) = axes( 'Box', 'off' );
ylabel( 'Slip (m) / Slip rate (m/s)')
xlabel( 'Time (s)' )
h(2) = axes( 'Box', 'off', ...
  'YAxisLocation', 'right', ...
  'XAxisLocation', 'top', ...
  'Color', 'none' );
ylabel( 'Shear Stress (MPa)' )

for dir = dirs
cd( dir )
meta

for i = 1:length( out )
  field = out{i}{2};
  dit   = out{i}{3};
  if dit == 1
    [ msg, t, s, x ] = tsread( field, [ out{i}{4:6} ], filter );
    if all( x == xg )
      axes( h(1) )
      if strcmp( field, 'ts' ), axes( h(2) ), end
      h(end+1) = plot( t, s, 'k' );
      hold on
    end
  end
  end
end

cd '..'
end

