%------------------------------------------------------------------------------%
% SURFVIZ

if domesh, edgecolor = get( 1, 'DefaultTextColor' );
else       edgecolor = 'none';
end
if dosurf, facecolor = 'flat';
else       facecolor = 'none';
end
switch field
case 'v'
  planesi = [
    1 2 3  4 2 6
    1 5 3  4 5 6
    1 2 3  4 5 3
    1 2 6  4 5 6
    1 2 3  1 5 6
    4 2 3  4 5 6
  ];
  tmp = [];
  for iz = 1:size( planes, 1 )
    zone = planes(iz,:);
    tmp = [ tmp; zone( planesi ) ];
  end
  planes = unique( tmp, 'rows' );
  for iz = 1:size( planes, 1 )
    zone = planes(iz,:);
    [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim );
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    ng = i2 - i1 + 1;
    if sum( ng > 1 ) == 2
      xg = x(j,k,l,:) + uscl * u(j,k,l,:); 
      if comp, vg =  v(j,k,l,comp); 
      else     vg = s1(j,k,l);
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      vg = .25 * ( ...
        vg(1:end-1,1:end-1) + vg(2:end,1:end-1) + ...
        vg(1:end-1,2:end)   + vg(2:end,2:end) ); 
      surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ), ...
        'EdgeColor', edgecolor, ...
        'FaceColor', facecolor, ...
        'LineWidth', linewidth / 4, ...
        'Tag', 'surface', ...
        'FaceLighting', 'none' );
      hold on
    end
  end
case 'w'
end

