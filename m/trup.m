% Contour plots

field = 'trup'
v = 0:0.5:7;
styles = { 'r-' 'b-' 'r--' 'b--' };
dir0 = 'out'; dirs = { '100-0' '100-1a' '100-2a' '100-3a' };
dir0 = 'out'; dirs = { '050-0' '100-0' };
dir0 = 'out'; dirs = { 'corner050' 'corner100' };
dir0 = 'out'; dirs = { '050-0' '100-0' 'corner050' 'corner100' };

format compact
clf
labels = fieldlabels( field, 0 );
set( gcf, 'Name', labels{1} )
axes( 'Position', [ .1 .2 .8 .7 ] );
plot( 0, 0, 'p', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 11 )
axis image;
axis( [ -15 15 -7.5 7.5 ] )
hold on
title( labels{1} )
xlabel( 'X (km)' )
ylabel( 'Y (km)' )

for ii = 1:length( dirs )
  model = dirs{ii};
  style = styles{ mod( ii-1, length(styles) ) + 1 };
  disp( [ model ' ' style ] )
  srcdir
  cd( dir0 )
  cd( model )
  [ x, y, f ] = faultread( field );
  [ c, h ] = contour( x, y, f );
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
cd( dir0 )
print( '-depsc', 'trup' )
system( [ '/usr/bin/ps2pdf -dPDFSETTINGS=/prepress trup.eps &' ] );

