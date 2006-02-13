% Reynolds Glyph

function h = reynoldsglyph( xx, vv, flim, glyphexp, dx )

h = [];
if ~length( vv ) || ~flim, return, end
scl = .5 * dx * ( 1 / flim ) ^ glyphexp;
np = 16;

switch size( vv, 2 )
case 3
  theta = 2 * pi * ( 0 : 2 / np : 1 );
  row   = ones( size( theta ) );
  phi   = pi * ( 0 : 1 / np : 1 )';
  dphi  = phi(2) - phi(1);
  sinf  = sin( phi );
  cosf  = cos( phi );
  r     = abs( cosf ) .^ glyphexp;
  x(:,:,1) = ( r .* sinf ) * cos( theta );
  x(:,:,2) = ( r .* sinf ) * sin( theta );
  x(:,:,3) = ( r .* cosf ) * row;
  x( abs( x ) < .00001 ) = 0;
  r = cos( phi + dphi / 2 ) * row;
  q = x;
  q(:,:,3) = q(:,:,3) .* ( ( 1 - glyphexp / ( glyphexp+1 ) ./ cosf ./ cosf ) * row );
  n = size( x );
  rglyph = r;
  xglyph = x;
  qglyph = q;
  for ig = 1:size( vv, 1 )
    v = vv(ig,:);
    m = sqrt( sum( v .* v ) );
    if m < sqrt( eps ), continue, end
    v = v / m;
    x = xglyph;
    q = qglyph;
    r = rglyph * m;
    if v(1) || v(2)
      vec = [ v(2)   v(1)*v(3)             v(1) 
             -v(1)   v(2)*v(3)             v(2) 
                0   -v(1)*v(1)-v(2)*v(2)   v(3) ];
      tmp = sqrt( sum( vec .* vec, 1 ) );
      for i = 1:3
        vec(i,:) = vec(i,:) ./ tmp;
      end
      vec = scl * m ^ glyphexp * vec;
      x = vec * reshape( x, [ n(1) * n(2) 3 ] )';
      q = vec * reshape( q, [ n(1) * n(2) 3 ] )';
      x = reshape( x', n );
      q = reshape( q', n );
    else
      x = scl * m ^ glyphexp * x;
    end
    for i = 1:3
      x(:,:,i) = x(:,:,i) + xx(ig,i);
    end
    h(ig) = surf( x(:,:,1), x(:,:,2), x(:,:,3), r, 'VertexNormals', q );
    hold on
  end
case 6
  theta = 2 * pi * ( 0 : 1 / np : 1 );
  row   = ones( size( theta ) );
  phi   = pi * ( 0 : 1 / np : 1 )';
  sinf  = sin( phi );
  cosf  = cos( phi );
  x(:,:,1) = sinf * cos( theta );
  x(:,:,2) = sinf * sin( theta );
  x(:,:,3) = cosf * row;
  x( abs( x ) < .00001 ) = 0;
  n = size( x );
  sphr = reshape( x, [ n(1) * n(2) 3 ] )';
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  for ig = 1:size( vv, 1 )
    w = vv(ig,:);
    [ vec, val ] = eig( w(c) );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i);
    vec = vec(:,i);
    vec(:,1) = cross( vec(:,2), vec(:,3) );
    tmp = scl * abs( val(3) ) ^ ( glyphexp - 1 );
    r = val * ( sphr .* sphr );
    x = tmp * vec * ( sphr .* repmat( r, [ 3 1 ] ) );
    x = reshape( x', [ np+1 np+1 3 ] );
    r = reshape( r,  [ np+1 np+1 ] );
    i = 1:np;
    r(i,i) = 0.25 * ( r(i,i) + r(i+1,i) + r(i,i+1) + r(i+1,i+1) );
    for i = 1:3
      x(:,:,i) = x(:,:,i) + xx(ig,i);
    end
    j0 = [ np 1:np     ];
    j1 =      1:np+1    ;
    j2 = [    2:np+1 2 ];
    vec1 = x(:,j0,:) - x(:,j2,:);
    vec2 = x(j0,:,:) - x(j2,:,:);
    m4 = floor( np / 4 );
    for i = 1:3
      vec1(1,:,i)   = x(2,m4+1,i)     - x(2,3*m4+1,i);
      vec2(1,:,i)   = x(2,1,i)        - x(2,2*m4+1,i);
      vec2(end,:,i) = x(end-1,m4+1,i) - x(end-1,3*m4+1,i);
      vec1(end,:,i) = x(end-1,1,i)    - x(end-1,2*m4+1,i);
    end
    q(j1,j1,1) = vec1(:,:,2) .* vec2(:,:,3) - vec1(:,:,3) .* vec2(:,:,2);
    q(j1,j1,2) = vec1(:,:,3) .* vec2(:,:,1) - vec1(:,:,1) .* vec2(:,:,3);
    q(j1,j1,3) = vec1(:,:,1) .* vec2(:,:,2) - vec1(:,:,2) .* vec2(:,:,1);
    for i = 1:3
      q(:,:,i) = q(:,:,i) .* -sign( r );
    end
    h(ig) = surf( x(:,:,1), x(:,:,2), x(:,:,3), r, 'VertexNorm', q );
    hold on
  end
otherwise, error 'size vv'
end

set( h, ...
  'BackFaceLighting', 'lit', ...
  'FaceAlpha', .9, ...
  'FaceColor', 'flat', ...
  'EdgeColor', 'none', ...
  'AmbientStrength', .6, ...
  'DiffuseStrength', .6, ...
  'SpecularStrength', .9, ...
  'SpecularExponent', 10, ...
  'FaceLighting', 'phong' )

if 0
  quiver3( x(:,:,1), x(:,:,2), x(:,:,3), q(:,:,1), q(:,:,2), q(:,:,3), 'g' )
end

