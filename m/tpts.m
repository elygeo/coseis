% TP timeseries plots

clear all
filter = 0;
dirs = { '50-0' '100-0' '100-1a' '100-2a' '100-3a' };
dirs = { '50-0' '100-0' };
dirs = { '100-0' '100-1a' '100-2a' '100-3a' };

srcdir
cd 'out'

format compact
figure(1), clf
figure(2), clf
figure(3), clf
figure(4), clf

for ii = 1:length( dirs )

model = dirs{ii};
disp( model )
cd( model )
meta
for i = 1:length( out )
  field = out{i}{2};
  dit   = out{i}{3};
  match = strcmp( field, { 'su' 'sv' 'ts' } );
  if dit == 1 && any( match )
    [ msg, t, v, x ] = tsread( field, [ out{i}{4:6} ], filter );
    s = sqrt( sum( v .* v, 2 ) );
    r = sqrt( sum( x .* x ) );
    if     abs( r - 6000 ) < 1, fig = 1;
    elseif abs( r - 7500 ) < 1, fig = 3;
    else, break
    end
    fig = fig + strcmp( field, 'ts' );
    set( 0, 'CurrentFigure', fig );
    plot( t, s, 'k' );
    hold on
  end
end
cd '..'

set( 0, 'CurrentFigure', 1 ); title( 'PA' ); xlabel( 'Time (s)' ), ylabel( 'Slip (m)' )
set( 0, 'CurrentFigure', 2 ); title( 'PA' ); xlabel( 'Time (s)' ), ylabel( 'Shear Stress (MPa)' )
set( 0, 'CurrentFigure', 3 ); title( 'PI' ); xlabel( 'Time (s)' ), ylabel( 'Slip (m)' )
set( 0, 'CurrentFigure', 4 ); title( 'PI' ); xlabel( 'Time (s)' ), ylabel( 'Shear Stress (MPa)' )

%set( gca, 'Color', 'none', 'YAxisLocation', 'right' );

end

