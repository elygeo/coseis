% TP timeseries plots

clear all
filter = 0;
dirs = { '100' };
dirs = { '050' '100' '100-1a' '100-2a' '100-3a' };
fields = { 'su' 'sv' };
styles = { 'w--' 'c-' 'y-' 'y-' 'y-' };
srcdir
cd 'out'
format compact
clf
colorscheme
set( gcf, ...
  'PaperPosition', [ 0.5 0.5 6 3 ], ...
  'InvertHardCopy', 'off', ...
  'DefaultAxesColor', 'none' )
count = 0;
for i = 1:4, h(i) = axes; end
set( h(1:2), 'Position', [ .1  .14 .38 .76 ] )
set( h(3:4), 'Position', [ .52 .14 .38 .76 ] )

for ii = 1:length( dirs )
  model = dirs{ii};
  style = styles{ mod( ii-1, length(styles) ) + 1 };
  disp( [ model ' ' style ] )
  srcdir
  cd 'out'
  cd( model )
  meta
  for i = 1:length( out )
    field = out{i}{2};
    dit   = out{i}{3};
    match = strcmp( field, fields );
    if dit == 1 && any( match )
      [ msg, t, v, x ] = tsread( field, [ out{i}{4:6} ], filter );
      s = sqrt( sum( v .* v, 2 ) );
      r = sqrt( sum( x .* x ) );
      ax = find( match );
      if     abs( r - 7500 ) < dx, count = count + 1;
      elseif abs( r - 6000 ) < dx, ax = ax + 2;
      else,  ax = 0;
      end
      if ax
        axes( h(ax) );
        plot( t, s, style );
        hold on
      end
    end
  end
end

count
set( h, 'XLim', [ 0 12 ] )
set( h, 'XLim', [ 2.8 3.3 ] )
set( h, 'YLim', [ 0 3.5 ] )
set( h, 'Color', 'none' );
set( h(3:4), 'YAxisLocation', 'right' );
axes( h(1) ), title( 'PI' ); xlabel( 'Time (s)' ); ylabel( 'Slip Rate (m/s)' )
axes( h(3) ), title( 'PA' ); xlabel( 'Time (s)' ); ylabel( 'Slip (m)' )

srcdir
cd 'out'
print( '-depsc', 'tpts' )

