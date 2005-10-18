% Reynolds Glyph

hglyph = [];
if ~length( vga ) || ~fscl, return, end
clear xg ng rg
scl = .5 * dx * ( 1 / fscl ) ^ glyphexp;
m = 16;
switch size( vga, 2 )
case 3
  theta = 2 * pi * ( 0 : 2 / m : 1 );
  row   = ones( size( theta ) );
  phi   = pi * ( 0 : 1 / m : 1 )';
  dphi  = phi(2) - phi(1);
  sinf  = sin( phi );
  cosf  = cos( phi );
  rg    = abs( cosf ) .^ glyphexp;
  vglyphr = cos( phi + dphi / 2 ) * row;
  xg(:,:,1) = ( rg .* sinf ) * cos( theta );
  xg(:,:,2) = ( rg .* sinf ) * sin( theta );
  xg(:,:,3) = ( rg .* cosf ) * row;
  xg( abs( xg ) < .00001 ) = 0;
  ng = xg;
  ng(:,:,3) = ng(:,:,3) .* ( ( 1 - glyphexp / ( glyphexp+1 ) ./ cosf ./ cosf ) * row );
  vglyphx = xg;
  vglyphn = ng;
  for ig = 1:size( vga, 1 )
    vg = vga(ig,:);
    mg = sqrt( sum( vg .* vg ) );
    vg = vg / mg;
    n  = size( vglyphx );
    xg = vglyphx;
    ng = vglyphn;
    rg = mg * vglyphr;
    vec = ones( 3 );
    if vg(1) || vg(2)
      vec = [ vg(2) vg(1)*vg(3)             vg(1) 
             -vg(1) vg(2)*vg(3)             vg(2) 
                 0 -vg(1)*vg(1)-vg(2)*vg(2) vg(3) ];
      tmp = sqrt( sum( vec .* vec, 1 ) );
      for i = 1:3
        vec(i,:) = vec(i,:) ./ tmp;
      end
      vec = scl * mg ^ glyphexp * vec;
      xg = vec * reshape( xg, [ n(1) * n(2) 3 ] )';
      ng = vec * reshape( ng, [ n(1) * n(2) 3 ] )';
      xg = reshape( xg', n );
      ng = reshape( ng', n );
    else
      xg = scl * mg ^ glyphexp * xg;
    end
    for i = 1:3
      xg(:,:,i) = xg(:,:,i) + xga(ig,i);
    end
    hglyph(ig) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), rg, 'VertexNormals', ng );
    hold on
  end
  set( hglyph, 'BackFaceLighting', 'lit' )
case 6
  theta = 2 * pi * ( 0 : 1 / m : 1 );
  row   = ones( size( theta ) );
  phi   = pi * ( 0 : 1 / m : 1 )';
  dphi  = phi(2) - phi(1);
  sinf  = sin( phi );
  cosf  = cos( phi );
  xg(:,:,1) = sinf * cos( theta );
  xg(:,:,2) = sinf * sin( theta );
  xg(:,:,3) = cosf * row;
  xg( abs( xg ) < .00001 ) = 0;
  n = size( xg );
  sphr = reshape( xg, [ n(1) * n(2) 3 ] )';
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  for ig = 1:size( vga, 1 )
    wg = vga(ig,:);
    [ vec, val ] = eig( wg(c) );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i);
    vec = vec(:,i);
    vec(:,1) = cross( vec(:,2), vec(:,3) );
    tmp = scl * abs( val(3) ) ^ ( glyphexp - 1 );
    rg = val * ( sphr .* sphr );
    %xg = tmp * vec * diag( abs( val ) ) * sphr; % elipsoide
    xg = tmp * vec * ( sphr .* repmat( rg, [ 3 1 ] ) );
    xg = reshape( xg', [ m+1 m+1 3 ] );
    rg = reshape( rg, [ m+1 m+1 ] );
    i = 1:m;
    rg(i,i) = 0.25 * ( rg(i,i) + rg(i+1,i) + rg(i,i+1) + rg(i+1,i+1) );
    for i = 1:3
      xg(:,:,i) = xg(:,:,i) + xga(ig,i);
    end
    j0 = [ m 1:m     ];
    j1 = [   1:m+1   ];
    j2 = [   2:m+1 2 ];
    vec1 = xg(:,j0,:) - xg(:,j2,:);
    vec2 = xg(j0,:,:) - xg(j2,:,:);
    m4 = floor( m / 4 );
    for i = 1:3
      vec1(1,:,i)   = xg(2,m4+1,i)     - xg(2,3*m4+1,i);
      vec2(1,:,i)   = xg(2,1,i)        - xg(2,2*m4+1,i);
      vec2(end,:,i) = xg(end-1,m4+1,i) - xg(end-1,3*m4+1,i);
      vec1(end,:,i) = xg(end-1,1,i)    - xg(end-1,2*m4+1,i);
    end
    ng(j1,j1,1) = vec1(:,:,2) .* vec2(:,:,3) - vec1(:,:,3) .* vec2(:,:,2);
    ng(j1,j1,2) = vec1(:,:,3) .* vec2(:,:,1) - vec1(:,:,1) .* vec2(:,:,3);
    ng(j1,j1,3) = vec1(:,:,1) .* vec2(:,:,2) - vec1(:,:,2) .* vec2(:,:,1);
    rg = double( rg );
    for i = 1:3
      ng(:,:,i) = ng(:,:,i) .* -sign( rg );
    end
    hglyph(ig) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), rg, 'VertexNorm', ng );
    hold on
  end
  set( hglyph, 'BackFaceLighting', 'lit' )
otherwise error 'vga'
clear n
end
set( hglyph, ...
  'Tag', 'glyph', ...
  'FaceAlpha', .9, ...
  'FaceColor', 'flat', ...
  'EdgeColor', 'none', ...
  'AmbientStrength', .6, ...
  'DiffuseStrength', .6, ...
  'SpecularStrength', .9, ...
  'SpecularExponent', 10, ...
  'FaceLighting', 'phong' )

%quiver3(xg(:,:,1),xg(:,:,2),xg(:,:,3),ng(:,:,1),ng(:,:,2),ng(:,:,3),'g')

