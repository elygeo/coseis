% TP timeseries plots

dirs   = { '0' '1a' };
styles = { 'k' 'r'  };
filter = 0;
xg = [ 0 6000 0 ];
xg = [ 7500 6000 0 ];
xg = [ 7500 0 0 ];

format compact
srcdir
cd 'out'
clf
haxes(1) = axes( 'Box', 'off' );
ylabel( 'Slip (m) / Slip rate (m/s)')
xlabel( 'Time (s)' )
waitforbuttonpress

haxes(2) = axes( 'Box', 'off', ...
  'YAxisLocation', 'right', ...
  'XAxisLocation', 'top', ...
  'Color', 'none' );
ylabel( 'Shear Stress (MPa)' )
waitforbuttonpress

h = [];

for ii = 1:length( dirs )
  cd( dirs{ii} )
  meta
  for i = 1:length( out )
    field = out{i}{2};
    dit   = out{i}{3};
    if dit == 1
      [ msg, t, s, x ] = tsread( field, [ out{i}{4:6} ], filter );
{ field length( t ) length( s ) out{i}{4:6} x(1) x(2) }
      if all( abs( x ) ~= xg )
        axes( haxes(1) )
        if strcmp( field, 'ts' ), axes( haxes(2) ), end
        h(end+1) = plot( t, s, styles{ii} );
        hold on
waitforbuttonpress
      end
    end
  end
  cd '..'
end

