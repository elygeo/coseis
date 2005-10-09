% Glyph vizualization

if ~fscl, return, end
if volviz, i1glyph = i1volume; i2glyph = i2volume;
else,      i1glyph = i1slice;  i2glyph = i2slice;
end
minmag = glyphcut * fscl;
mga = [];
vga = [];
xga = [];
c = [ 1 6 5; 6 2 4; 5 4 3 ];
for iz = 1:size( glyphs, 1 )
  [ i1, i2 ] = zone( i1glyph(iz,:), i2glyph(iz,:), nn, noff, ihypo, ifn );
  if cellfocus, i2 = i2 - 1; end
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  switch vizfield
  case 'a'
    ii = find( s1(j,k,l) > minmag );
    if ii
      [ j, k, l ] = ind2sub( i2 - i1 + 1, ii );
      j = j + i1(1) - 1;
      k = k + i1(2) - 1;
      l = l + i1(3) - 1;
      ng = prod( nm );
      iii = sub2ind( nm, j, k, l );
      clear vg xg
      for i = 0:2
        vg(:,i+1) = w1(iii+i*ng);
        xg(:,i+1) = x(iii+i*ng) + xscl * u(iii+i*ng);
      end
      mga = [ mga; s1(iii) ];
      vga = [ vga; vg ];
      xga = [ xga; xg ];
    end
  case 'v'
    ii = find( s2(j,k,l) > minmag );
    if ii
      [ j, k, l ] = ind2sub( i2 - i1 + 1, ii );
      j = j + i1(1) - 1;
      k = k + i1(2) - 1;
      l = l + i1(3) - 1;
      ng = prod( nm );
      iii = sub2ind( nm, j, k, l );
      clear vg xg
      for i = 0:2
        vg(:,i+1) = v(iii+i*ng);
        xg(:,i+1) = x(iii+i*ng) + xscl * u(iii+i*ng);
      end
      mga = [ mga; s2(iii) ];
      vga = [ vga; vg ];
      xga = [ xga; xg ];
    end
  case 'u'
    ii = find( s1(j,k,l) > minmag );
    if ii
      [ j, k, l ] = ind2sub( i2 - i1 + 1, ii );
      j = j + i1(1) - 1;
      k = k + i1(2) - 1;
      l = l + i1(3) - 1;
      ng = prod( nm );
      iii = sub2ind( nm, j, k, l );
      clear vg xg
      for i = 0:2
        vg(:,i+1) = u(iii+i*ng);
        xg(:,i+1) = x(iii+i*ng) + xscl * u(iii+i*ng);
      end
      mga = [ mga; s1(iii) ];
      vga = [ vga; vg ];
      xga = [ xga; xg ];
    end
  case 'w'
    ii = find( s2(j,k,l) > minmag );
    for iii = ii(:)'
      [ j, k, l ] = ind2sub( i2 - i1 + 1, iii );
      j = j + i1(1) - 1;
      k = k + i1(2) - 1;
      l = l + i1(3) - 1;
      clear wg
      wg(1:3) = w1(j,k,l,:);
      wg(4:6) = w2(j,k,l,:);
      clear xg
      for i = 1:3
        xg(i) = 0.125 * ( ( ...
          x(j,k,l,i) + x(j+1,k+1,l+1,i) + ...
          x(j+1,k,l,i) + x(j,k+1,l+1,i) + ...
          x(j,k+1,l,i) + x(j+1,k,l+1,i) + ...
          x(j,k,l+1,i) + x(j+1,k+1,l,i) ) + ...
          xscl * ( ...
          u(j,k,l,i) + u(j+1,k+1,l+1,i) + ...
          u(j+1,k,l,i) + u(j,k+1,l+1,i) + ...
          u(j,k+1,l,i) + u(j+1,k,l+1,i) + ...
          u(j,k,l+1,i) + u(j+1,k+1,l,i) ) );
      end
      [ vec, val ] = eig( wg(c) );
      val = diag( val );
      [ tmp, i ] = sort( abs( val ) );
      val = val(i);
      vec = vec(:,i);
      xga = [ xga; xg ];
      mga = [ mga; val' ];
      vga = [ vga; vec(:)' ];
    end
  otherwise return
  end
end

if doglyph > 1
  reynoldsglyph
else
  wireglyph
end

