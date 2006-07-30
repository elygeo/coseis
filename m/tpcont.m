% Contour plots

field = 'trup';
field = 'su';
field = 'svp';
v = 0:0.5:7;
styles = { 'w--' 'c-' 'y-' 'y-' 'y-' };
dirs = { '50' '100' };
dirs = { '50' '100' '50-corner' '100-corner' };
dirs = { '50' '100' 'sxy' 'sxz' 'syz' };
dirs = { '50' '100' 'uxx' 'uxx-' 'uyy' 'uyy-' 'uzz' 'uzz-' };

format compact
clf
set( gcf, ...
  'PaperPosition', [ 0.25 0.25 4 4 ], ...
  'InvertHardCopy', 'off', ...
  'Color', 'k', ...
  'DefaultAxesColor', 'none', ...
  'DefaultTextColor', 'w', ...
  'DefaultAxesXColor', 'w', ...
  'DefaultAxesYColor', 'w', ...
  'DefaultAxesZColor', 'w' )

labels = fieldlabels( field, 0 );
set( gcf, 'Name', labels{1} )
axes( 'Position', [ .1 .2 .8 .7 ] );
plot( 0, 0, 'p', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'k', 'MarkerSize', 11 )
axis image;
axis( [ -15 15 -7.5 7.5 ] )
axis( [ 0 15 0 7.5 ] )
hold on
title( labels{1} )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )

for ii = 1:length( dirs )
  model = dirs{ii};
  style = styles{ mod( ii-1, length(styles) ) + 1 };
  disp( [ model ' ' style ] )
  srcdir
  cd 'out'
  cd( model )
  [ x, f ] = tpreadfault( field );
  if size( f, 3 ) > 1
    f = sqrt( sum( f .* f, 3 ) );
  end
  [ c, h ] = contour( x(:,:,1), x(:,:,2), f );
  delete( h );
  i = 1;
  while i < size( c, 2 )
    n  = c(2,i);
    c(:,i) = nan;
    i  = i + n + 1;
  end
  h = plot( c(1,:), c(2,:), style );
end

srcdir
cd 'out'
print( '-depsc', 'tpcont' )

