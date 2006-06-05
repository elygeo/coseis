% Contour plots

field = 'svp';
field = 'trup';
field = 'su';
v = 0:0.5:7;
styles = { 'r-' 'b-' 'r--' 'b--' };
dirs = { '100' '100-1a' '100-2a' '100-3a' };
dirs = { '050' '100' };
dirs = { '050-corner' '100-corner' };
dirs = { '050' '100' '050-corner' '100-corner' };

format compact
clf
labels = fieldlabels( field, 0 );
set( gcf, 'Name', labels{1} )
axes( 'Position', [ .1 .2 .8 .7 ] );
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
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
  h = plot( c(1,:), c(2,:), style, 'linewidth', .2 );
end

srcdir
cd 'out'
print( '-depsc', 'tpcont' )
system( [ '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress tpcont.eps &' ] );

