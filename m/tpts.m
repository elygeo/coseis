% TP timeseries plots

clear all
filter = 0;
dirs = { '100' };
dirs = { '50' '100' 'sxy' 'sxz' 'syz' };
dirs = { '50' '100' 'sxy' 'sxz' 'syz' 'uxx' 'uyy' 'uzz' 'uxx-' 'uyy-' 'uzz-' };
fields = { 'su' 'sv' 'ts' };
styles = { 'w--' 'c-' 'y-' 'y-' 'y-' 'm-' 'm-' 'm-' 'g-' 'g-' 'g-' };
srcdir
cd 'out'
format compact
clf
set( gcf, ...
  'PaperPosition', [ 0.5 0.5 6 6 ], ...
  'InvertHardCopy', 'off', ...
  'Color', 'k', ...
  'DefaultAxesColor', 'none', ...
  'DefaultTextColor', 'w', ...
  'DefaultAxesXColor', 'w', ...
  'DefaultAxesYColor', 'w', ...
  'DefaultAxesZColor', 'w' )
count = 0;
for i = 1:6, h(i) = axes; end
set( h(1:2), 'Position', [ .08 .54 .4 .4 ] )
set( h(3),   'Position', [ .08 .06 .4 .4 ] )
set( h(4:5), 'Position', [ .52 .54 .4 .4 ] )
set( h(6),   'Position', [ .52 .06 .4 .4 ] )
% Small fig
%set( h(1:2), 'Position', [ .1 .55 .35 .35 ] )
%set( h(3),   'Position', [ .1 .1 .35 .35 ] )
%set( h(4:5), 'Position', [ .55 .55 .35 .35 ] )
%set( h(6),   'Position', [ .55 .1 .35 .35 ] )

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
      elseif abs( r - 6000 ) < dx, ax = ax + 3;
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
set( h([1 2 4 5]), 'YLim', [ 0 3.5 ] )
set( h([1 4]), 'Color', 'none' );
set( h(4:6), 'YAxisLocation', 'right' );
axes( h(1) ), title( 'PI' ); ylabel( 'Slip Rate (m/s)' )
axes( h(4) ), title( 'PA' ); ylabel( 'Slip (m)' )
axes( h(3) ), title( 'PI' ); xlabel( 'Time (s)' ), ylabel( 'Shear Stress (MPa)')
axes( h(6) ), title( 'PA' ); xlabel( 'Time (s)' ), ylabel( 'Shear Stress (MPa)')

srcdir
cd 'out'
print( '-depsc', 'tpts' )

