%------------------------------------------------------------------------------%
% VECTORVIZ
%function vector( xga, vga, mga, h, vscl, vexp, glyphtype )

testing = 1;
if testing
  clear all
  testing = 1;
  clf
  h = 1;
  vexp = 1;
  glyphtype = -1;
  xga = [ 0 0 0; 0 0 1; 0 0 2; 0 0 3; 0 0 4; 0 0 5; 0 0 6; 0 0 7 ];
  vga = [ 0 0 1 ];
  vga = [ 2 0 0; 1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0; 1 1 1; ];
  mga = sum( vga .* vga, 2 );
  vscl = 1 / sqrt( max( mga ) );
end

if glyphtype
  ng = size( vga, 1 );
  scl = h * vscl ^ vexp;
  lw = get( 1, 'DefaultLineLineWidth' );
  lw = 2
  for i = 1:3
    vga(:,i) = scl * vga(:,i) .* mga .^ ( 0.5 * vexp - 0.5 );
  end
  if glyphtype < 0
    for i = 1:3
      xg{i} = [ xga(:,i) - vga(:,i) xga(:,i) + vga(:,i) repmat( NaN, ng, 1 ) ]';
      xg{i} = xg{i}(:);
    end
    plot3( xg{1}, xg{2}, xg{3} );
    hold on
  else
    for i = 1:3
      xg{i} = [ xga(:,i) xga(:,i) - vga(:,i) repmat( NaN, ng, 1 ) ]';
      xg{i} = xg{i}(:);
    end
    plot3( xg{1}, xg{2}, xg{3}, 'Color', [ 0 .5 1 ], 'LineWidth', 2 * lw );
    hold on
    for i = 1:3
      xg{i} = [ xga(:,i) xga(:,i) + vga(:,i) repmat( NaN, ng, 1 ) ]';
      xg{i} = xg{i}(:);
    end
    plot3( xg{1}, xg{2}, xg{3}, 'Color', [ 1 .5 0 ], 'LineWidth', 2 * lw );
  end
else
  clear xg ng rg
  m     = 16;
  theta = 2 * pi * ( 0 : 2 / m : 1 );
  row   = ones( size( theta ) );
  phi   = pi * ( 0 : 1 / m : 1 )';
  dphi  = phi(2) - phi(1);
  sinf  = sin( phi );
  cosf  = cos( phi );
  rr    = abs( cosf ) .^ vexp;
  vglyphr = cos( phi + dphi / 2 ) * row;
  xg(:,:,1) = ( rr .* sinf ) * cos( theta );
  xg(:,:,2) = ( rr .* sinf ) * sin( theta );
  xg(:,:,3) = ( rr .* cosf ) * row;
  xg( abs( xg ) < .0001 ) = 0;
  ng = xg;
  ng(:,:,3) = ng(:,:,3) .* ( ( 1 - vexp / ( vexp+1 ) ./ cosf ./ cosf ) * row );
  nn = size( xg );
  vglyphx = xg;
  vglyphn = ng;
  for ig = 1:size( vga, 1 )
    vg = vga(ig,:);
    nn = size( vglyphx );
    xg = vglyphx;
    ng = vglyphn;
    rg = sqrt( mga(ig) ) * vglyphr;
    scl = h * vscl ^ vexp * mga(ig) ^ ( 0.5 * vexp );
    vec = ones( 3 );
    if vg(1) || vg(2)
      vec = [ vg(2)   vg(1)*vg(3)            vg(1) 
             -vg(1)   vg(2)*vg(3)            vg(2) 
                 0   -vg(1)*vg(1)-vg(2)*vg(2) vg(3) ];
      val = scl ./ sqrt( sum( vec .* vec ) );
      vec = vec .* [ val; val; val ];
      xg = vec * reshape( xg, [ nn(1) * nn(2) 3 ] )';
      ng = vec * reshape( ng, [ nn(1) * nn(2) 3 ] )';
      xg = reshape( xg', nn );
      ng = reshape( ng', nn );
    else
      xg = scl * xg;
    end
    for i = 1:3
      xg(:,:,i) = xg(:,:,i) + xga(ig,i);
    end
    surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), rg, ...
      'VertexNormals', ng, ...
      'BackFaceLighting', 'unlit', ...
      'AmbientStrength', .6, ...
      'DiffuseStrength', .6, ...
      'SpecularStrength', .9, ...
      'SpecularExponent', 10, ...
      'FaceLighting', 'phong', ...
      'EdgeColor', 'none', ...
      'FaceColor', 'flat' )
    hold on
  end
end
if testing
  %quiver3(xg(:,:,1),xg(:,:,2),xg(:,:,3),ng(:,:,1),ng(:,:,2),ng(:,:,3),'k')
  axis equal vis3d
  shading faceted
  xlabel( 'x' )
end

