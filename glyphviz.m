%------------------------------------------------------------------------------%
% GLYPHVIZ

xga = [];
vga = [];
mga = [];
switch field
case 'v'
  for iz = 1:size( glyphs, 1 )
    zone = glyphs(iz,:);
    [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    o = i1 - 1;
    nn = i2 - i1 + 1;
    ii = find( s1(j,k,l) > vcut * vcut );
    if ii
      [ j, k, l ] = ind2sub( nn, ii );
      j = repmat( j + o(1), [ 1 3 ] );
      k = repmat( k + o(2), [ 1 3 ] );
      l = repmat( l + o(3), [ 1 3 ] );
      c = repmat( 1:3, size( ii ) );
      i = sub2ind( size( x ), j, k, l, c );
      xga = [ xga; x(i) + uscl * u(i) ];
      vga = [ vga; v(i) ];
      mga = [ mga; s1(i) ];
    end
  end
  if ~isempty( vga ), vectorviz, end
case 'w'
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  for iz = 1:size( glyphs, 1 )
    zone = glyphs(iz,:);
    [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
    i2 = i2 - 1;
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    o = i1 - 1;
    nn = i2 - i1 + 1;
    ii = find( s2(j,k,l) > wcut * wcut );
    for ii = ii(:)'
      [ j, k, l ] = ind2sub( nn, ii );
      j = j + o(1);
      k = k + o(2);
      l = l + o(3);
      wg(1:3) = w1(j,k,l,:);
      wg(4:6) = w2(j,k,l,:);
      wg = wg(c);
      for i = 1:3
        xg(i) = 0.125 * ( ( ...
          x(j,k,l,i) + x(j+1,k+1,l+1,i) + ...
          x(j+1,k,l,i) + x(j,k+1,l+1,i) + ...
          x(j,k+1,l,i) + x(j+1,k,l+1,i) + ...
          x(j,k,l+1,i) + x(j+1,k+1,l,i) ) + ...
          uscl * ( ...
          u(j,k,l,i) + u(j+1,k+1,l+1,i) + ...
          u(j+1,k,l,i) + u(j,k+1,l+1,i) + ...
          u(j,k+1,l,i) + u(j+1,k,l+1,i) + ...
          u(j,k,l+1,i) + u(j+1,k+1,l,i) ) );
      end
      [ vec, val ] = eig( wg );
      val = diag( val );
      [ tmp, i ] = sort( abs( val ) );
      val = val(i);
      vec = vec(:,i);
      xga = [ xga; xg ];
      mga = [ mga; val' ];
      vga = [ vga; vec(:)' ];
    end
    clear xg
  end
  if ~isempty( vga ), tensorviz, end
end

