%------------------------------------------------------------------------------%
% ISOSURFVIZ

hand = [];
if ~fscl, return, end
isoval = isofrac * fscl;
if comp, isoval = isoval * [ -1 1 ]; end
for iz = 1:size( volumes, 1 )
  zone = volumes(iz,:);
  [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
  if cellfocus, i2 = i2 - 1; end
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  ng = i2 - i1 + 1;
  if sum( ng > 1 ) < 3, error( 'bad volume' ), end
  switch field
  case 'u'
    if comp, vg = u(j,k,l,comp); 
    else     vg = sum( u(j,k,l,:) .^ 2, 4 )
    end
  case 'v'
    if comp, vg = v(j,k,l,comp); 
    else     vg = s1(j,k,l);
    end
  case 'w'
    if     comp > 3, vg = w2(j,k,l,comp-3); 
    elseif comp,     vg = w1(j,k,l,comp); 
    else             vg = s2(j,k,l); 
    end
  end
  if ~cellfocus
    xg = x(j,k,l,:) + xscl * u(j,k,l,:); 
  else
    xg = 0.125 * ( ( ...
      x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
      x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
      x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
      x(j,k,l+1,:) + x(j+1,k+1,l,:) ) + ...
      xscl * ( ...
      u(j,k,l,:) + u(j+1,k+1,l+1,:) + ...
      u(j+1,k,l,:) + u(j,k+1,l+1,:) + ...
      u(j,k+1,l,:) + u(j+1,k,l+1,:) + ...
      u(j,k,l+1,:) + u(j+1,k+1,l,:) ) );
  end
  vg = permute( vg, [2 1 3] );
  xg = permute( xg, [2 1 3 4] );
  for i = 1:length( isoval );
    if comp, ival = abs( isoval(i) );
    else,    ival = isoval(i) .* isoval(i);
    end
    tmp = isosurface( xg(:,:,:,1), xg(:,:,:,2), xg(:,:,:,3), ...
      sign( isoval(i) ) * vg, ival );
    if ~isempty( tmp.vertices )
      hand(end+1) = patch( tmp, ...
        'CData', isoval(i), ...
        'Tag', 'isosurf', ...
        'EdgeColor', 'none', ...
        'FaceColor', 'flat', ...
        'AmbientStrength',  .6, ...
        'DiffuseStrength',  .6, ...
        'SpecularStrength', .9, ...
        'SpecularExponent', 10, ...
        'FaceLighting', 'phong', ...
        'BackFaceLighting', 'lit' );
    end
  end
end 

