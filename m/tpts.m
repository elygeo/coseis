% TP timeseries plots

filter = 0;
meta
h = [];

for i = 1:length( out )
  field = out{i}{2};
  dit   = out{i}{3};
  if dit == 1 && strcmp( field, 'ts' )
    [ msg, t, s, x ] = tsread( 'ts', [ out{i}{4:6} ], filter );
    h(end+1) = plot( t, s, 'k' );
    hold on
  end
end
set( gca, 'Color', 'none', 'YAxisLocation', 'right' );
ylabel( 'Shear Stress (MPa)' )

