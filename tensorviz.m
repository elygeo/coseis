%------------------------------------------------------------------------------%
% TENSORVIZ
%function tensor( xga, vga, mga, h, wscl, wexp, glyphtype )

testing = 1;
if testing
  clear all
  testing = 1;
  clf
  h = 1;
  glyphtype = 1;
  xga = [ 0 0 0 ];
  wg = [ 0 0 0  0 0 1 ];
  wexp = 1;
  c = [ 1 6 5; 6 2 4; 5 4 3 ];
  wg = wg(c)
  [ vec, val ] = eig( wg );
  val = diag( val );
  [ tmp, i ] = sort( abs( val ) );
  val = val(i);
  vec = vec(:,i);
  mga = val';
  vga = vec(:)';
  wscl = 1 / sqrt( max( abs( val ) ) );
end

if glyphtype
  scl = 0.5 * h * wscl ^ wexp;
  lw = get( 1, 'DefaultLineLineWidth' );
  for ii = 1:3
    if glyphtype < 0
      ng = size( mga, 1 );
      for i = 1:3
        vg = scl * vga(:,(i-1)*3+ii) .* abs( mga(:,i) ) .^ wexp;
        xg{i} = [ xga(:,i) - vg xga(:,i) + vg repmat( NaN, ng, 1 ) ]';
        xg{i} = xg{i}(:);
      end
      plot3( xg{1}, xg{2}, xg{3} );
      hold on
    else
      ig = find( mga(:,ii) > 0 );
      ng = size( ig, 1 );
      for i = 1:3
        vg = scl * vga(ig,(i-1)*3+ii) .* abs( mga(ig,i) ) .^ wexp;
        xg{i} = [ xga(ig,i) - vg xga(ig,i) + vg repmat( NaN, ng, 1 ) ]';
        xg{i} = xg{i}(:);
      end
      plot3( xg{1}, xg{2}, xg{3}, 'Color', [ 1 .5 0 ], 'LineWidth', 2 * lw );
      hold on
      ig = find( mga(:,ii) < 0 );
      ng = size( ig, 1 );
      for i = 1:3
        vg = scl * vga(ig,(i-1)*3+ii) .* abs( mga(ig,i) ) .^ wexp;
        xg{i} = [ xga(ig,i) - vg xga(ig,i) + vg repmat( NaN, ng, 1 ) ]';
        xg{i} = xg{i}(:);
      end
      plot3( xg{1}, xg{2}, xg{3}, 'Color', [ 0 .5 1 ], 'LineWidth', 2 * lw );
    end
  end
  clear ig
else
  clear xg ng rg
  m     = 16;
  theta = 2 * pi * ( 0 : 1 / m : 1 );
  row   = ones( size( theta ) );
  phi   = pi * ( 0 : 1 / m : 1 )';
  dphi  = phi(2) - phi(1);
  sinf  = sin( phi );
  cosf  = cos( phi );
  xg(:,:,1) = sinf * cos( theta );
  xg(:,:,2) = sinf * sin( theta );
  xg(:,:,3) = cosf * row;
  xg( abs( xg ) < .0001 ) = 0;
  nn = size( xg );
  sphr = reshape( xg, [ nn(1) * nn(2) 3 ] )';
  for ig = 1:size( vga, 1 )
    val = mga(ig,:);
    vec = reshape( vga(ig,:), [3 3] );
    vec(:,1) = cross( vec(:,2), vec(:,3) );
    scl = 0.5 * h * wscl ^ wexp * abs( val(3) ) ^ ( wexp - 1 );
    rg = val * ( sphr .* sphr );
    %xg = scl * vec * diag( abs( val ) ) * sphr; % elipsoide
    xg = scl * vec * ( sphr .* repmat( rg, [ 3 1 ] ) );
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
    surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), rg, ...
      'VertexNormals', ng, ...
      'BackFaceLighting', 'reverselit', ...
      'AmbientStrength', .6, ...
      'DiffuseStrength', .6, ...
      'SpecularStrength', .9, ...
      'SpecularExponent', 10, ...
      'FaceLighting', 'gouraud', ...
      'EdgeColor', 'none', ...
      'FaceColor', 'flat' )
    hold on
    if testing
      axis equal vis3d
      shading faceted
      %quiver3(xg(:,:,1),xg(:,:,2),xg(:,:,3),ng(:,:,1),ng(:,:,2),ng(:,:,3),'k')
      xlabel( 'X' )
      ylabel( 'Y' )
      zlabel( 'Z' )
    end
  end
end

