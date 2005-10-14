% Isosurface viz

hisosurf = [];
if ~fscl, return, end
isoval = isofrac * fscl;
if comp, isoval = isoval * [ -1 1 ]; end
for iz = 1:size( i1volume, 1 )
  [ i1, i2 ] = zone( i1volume(iz,:), i2volume(iz,:), nn, nnoff, ihypo, ifn );
  vfsave = vizfield;
  if xscl > 0.
    vizfield = 'u';
    i1s = [ i1 it ];
    i2s = [ i2 it ];
    get4dsection
    xg = xscl * vg;
  else
    xg = 0;
  end
  vizfield = 'x';
  i1s = [ i1 0 ];
  i2s = [ i2 0 ];
  get4dsection
  xg = xg + vg;
  if cellfocus
    i2 = i2 - 1;
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    xg = 0.125 * ( ...
      xg(j,k,l,:) + xg(j+1,k+1,l+1,:) + ...
      xg(j+1,k,l,:) + xg(j,k+1,l+1,:) + ...
      xg(j,k+1,l,:) + xg(j+1,k,l+1,:) + ...
      xg(j,k,l+1,:) + xg(j+1,k+1,l,:) );
  end
  vizfield = vfsave;
  i1s = [ i1 it ];
  i2s = [ i2 it ];
  get4dsection
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

