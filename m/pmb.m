function h2 = pmb( h1, dx, dy )

n = 16;
ii = 0;
for h = h1
  haxes = get( h, 'Parent' );
  pos = get( h, 'Position' );
  for i = 1:n
    phi = (i-1)/n*2*pi;
    x = pos(1) + dx * cos( phi );
    y = pos(2) + dy * sin( phi );
    ii = ii + 1;
    h2(ii) = copyobj( h, haxes );
    set( h2(ii), 'Position', [ x, y, pos(3)-1 ] );
  end
end
%if nargout < 1, clear h2, end
