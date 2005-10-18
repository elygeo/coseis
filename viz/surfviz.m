% Surface viz
% input: f, x, cellfocus, 

%lineviz
%set( hand, 'Tag', 'surfline' )
hsurf = [];

if domesh, edgecolor = get( 1, 'DefaultTextColor' );
else       edgecolor = 'none';
end
if dosurf, facecolor = 'flat';
else       facecolor = 'none';
end

ii = find( i1
for i = 1:3
  if isfault
    i1(ifn) = ihypo(ifn);
    i2(ifn) = ihypo(ifn);
  end
  i1(i) = i2(i);
  if isfault
    i1(ifn) = ihypo(ifn);
    i2(ifn) = ihypo(ifn);
  end
  i2(i) = i1(i);
  tmp = [ tmp; i0 i1 i2 ];
end

l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);
ng = i2 - i1 + 1;
if sum( ng > 1 ) == 2
  xg = x(j,k,l,:)
  if comp, vg = v(j,k,l,comp); 
  else     vg = s(j,k,l);
  end
  xg = squeeze( xg );
  vg = squeeze( vg );
  vg = .25 * ( ...
    vg(1:end-1,1:end-1) + vg(2:end,1:end-1) + ...
    vg(1:end-1,2:end)   + vg(2:end,2:end) ); 
  hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
  hold on
end

set( hsurf, ...
  'Tag', 'surf', ...
  'LineWidth', linewidth / 4, ...
  'EdgeColor', edgecolor, ...
  'FaceColor', facecolor, ...
  'FaceAlpha', 1, ...
  'FaceLighting', 'none' );

