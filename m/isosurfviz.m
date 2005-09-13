%------------------------------------------------------------------------------%
% ISOSURFVIZ

hisosurf = [];
if ~fscl, return, end
isoval = isofrac * fscl;
if comp, isoval = isoval * [ -1 1 ]; end
for iz = 1:size( volumes, 1 )
  [ i1, i2 ] = zone( volumes(iz,:), nn, noff, i0, inrm );
  if cellfocus, i2 = i2 - 1; end
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  ng = i2 - i1 + 1;
  if any( ng <= 1 ), error 'volume', end
  switch field
  case 'a'
    if comp, vg = w1(j,k,l,comp); 
    else     vg = s1(j,k,l);
    end
  case 'v'
    if comp, vg = v(j,k,l,comp); 
    else     vg = s2(j,k,l);
    end
  case 'u'
    if comp, vg = u(j,k,l,comp); 
    else     vg = s1(j,k,l);
    end
  case 'w'
    switch inrm
    case 1, j(j==i0(1)) = [];
    case 2, k(k==i0(2)) = [];
    case 3, l(l==i0(3)) = [];
    end
    if     comp > 3, vg = w2(j,k,l,comp-3); 
    elseif comp,     vg = w1(j,k,l,comp); 
    else             vg = s2(j,k,l); 
    end
  otherwise return
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
    ival = abs( isoval(i) );
    tmp = isosurface( xg(:,:,:,1), xg(:,:,:,2), xg(:,:,:,3), ...
      sign( isoval(i) ) * vg, ival );
    if ~isempty( tmp.vertices )
      hisosurf(end+1) = patch( tmp, ...
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

