% TP timeseries plots

clear all
filter = 0;
dirs = { '50-0' '100-0' };
dirs = { '100-0' '100-1a' '100-2a' '100-3a' };
dirs = { '50-0' '100-0' '100-1a' '100-2a' '100-3a' };
dirs = { '50-0' '100-0' '100-1a' '100-2a' '100-3a' '100-1b' '100-2b' '100-3b' };
dirs = { 'corner050' 'corner100' };
fields = { 'su' 'sv' 'ts' };
srcdir
cd 'out'
format compact
clf
count = 0;
for i = 1:6, h(i) = axes; end
set( h(1:2), 'Position', [ .08 .54 .4 .4 ] )
set( h(3),   'Position', [ .08 .06 .4 .4 ] )
set( h(4:5), 'Position', [ .52 .54 .4 .4 ] )
set( h(6),   'Position', [ .52 .06 .4 .4 ] )

for ii = 1:length( dirs )
iii = 0;

model = dirs{ii};
disp( model )
cd( model )
meta
for i = 1:length( out )
  field = out{i}{2};
  dit   = out{i}{3};
  match = strcmp( field, fields )
  if dit == 1 && any( match )
    [ msg, t, v, x ] = tsread( field, [ out{i}{4:6} ], filter );
    s = sqrt( sum( v .* v, 2 ) );
    r = sqrt( sum( x .* x ) );
    ax = find( match );
    if     abs( r - 7500 ) < dx, count = count + 1;
    elseif abs( r - 6000 ) < dx, ax = ax + 3;
    else,  ax = 0;
    end
    if ax
      axes( h(ax) );
      plot( t, s, 'k', 'Linewidth', .2 );
      hold on
    end
  end
end
cd '..'

end

count
set( h([1 2 4 5]), 'YLim', [ 0 3.5 ] )
set( h([1 4]), 'Color', 'none' );
set( h(4:6), 'YAxisLocation', 'right' );
axes( h(1) ), title( 'PI' ); ylabel( 'Slip Rate (m/s)' )
axes( h(4) ), title( 'PA' ); ylabel( 'Slip (m)' )
axes( h(3) ), title( 'PI' ); xlabel( 'Time (s)' ), ylabel( 'Shear Stress (MPa)')
axes( h(6) ), title( 'PA' ); xlabel( 'Time (s)' ), ylabel( 'Shear Stress (MPa)')

orient tall
print( '-depsc', 'ts' )
system( [ '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress ts.eps &' ] );

