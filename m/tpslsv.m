% TP timeseries plots

filter = 0;
meta
h = [];

for i = 1:length( out )
  field = out{i}{2};
  dit   = out{i}{3};
  if dit == 1 && any( strcmp( field, { 'sl' 'sv' } ) )
    [ msg, t, s, x ] = tsread( field, [ out{i}{4:6} ], filter );
    h(end+1) = plot( t, s, 'k' );
    hold on
  end
end
ylabel( 'Slip (m) / Slip rate (m/s)')
xlabel( 'Time (s)' )

