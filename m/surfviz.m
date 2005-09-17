%------------------------------------------------------------------------------%
% SURFVIZ

if volviz
  planes = volumes;
elseif ~isfault
  planes = slices;
  lines  = slices;
  lineviz
  set( hand, 'Tag', 'surfline' )
end
hsurf = [];
if domesh, edgecolor = get( 1, 'DefaultTextColor' );
else       edgecolor = 'none';
end
if dosurf, facecolor = 'flat';
else       facecolor = 'none';
end
switch vizfield
case { 'vs', 'us', 'tn', 'ts' }
  i1 = i1node;
  i2 = i2node;
  i1(inrm) = i0(inrm);
  i2(inrm) = i0(inrm);
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  xg = x(j,k,l,:) + xscl * u(j,k,l,:); 
  i1(inrm) = 1;
  i2(inrm) = 1;
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  switch vizfield
  case 'vs', vg = vs(j,k,l);
  case 'us', vg = us(j,k,l);
  case 'tn', vg = tn(j,k,l);
  case 'ts', vg = ts(j,k,l);
  end
  xg = squeeze( xg );
  vg = squeeze( vg );
  vg = .25 * ( ...
    vg(1:end-1,1:end-1) + vg(2:end,1:end-1) + ...
    vg(1:end-1,2:end)   + vg(2:end,2:end) ); 
  hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
  hold on
case { 'a', 'v', 'u', 'mr' }
  i = [
    1 2 3  4 2 6
    1 5 3  4 5 6
    1 2 3  4 5 3
    1 2 6  4 5 6
    1 2 3  1 5 6
    4 2 3  4 5 6
  ];
  tmp = [];
  for iz = 1:size( planes, 1 )
    izone = planes(iz,:);
    tmp = [ tmp; izone( i ) ];
  end
  planes = unique( tmp, 'rows' );
  for iz = 1:size( planes, 1 )
    [ i1, i2 ] = zone( planes(iz,:), nn, noff, i0, inrm );
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    ng = i2 - i1 + 1;
    if sum( ng > 1 ) == 2
      xg = x(j,k,l,:) + xscl * u(j,k,l,:); 
      switch vizfield
      case 'mr',  vg = mr(j,k,l);
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
      otherwise error 'vizfield'
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      vg = .25 * ( ...
        vg(1:end-1,1:end-1) + vg(2:end,1:end-1) + ...
        vg(1:end-1,2:end)   + vg(2:end,2:end) ); 
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
      hold on
    end
  end
case 'w'
  for iz = 1:size( planes, 1 )
    [ i1, i2 ] = zone( planes(iz,:), nn, noff, i0, inrm );
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    ng = i2 - i1 + 1;
    if all( ng > 1 )
      xg = x(j(1),k,l,:) + xscl * u(j(1),k,l,:); 
      if     comp > 3, vg = w2(j(1),k,l,comp-3);
      elseif comp,     vg = w1(j(1),k,l,comp);
      else             vg = s2(j(1),k,l);
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
      hold on
      xg = x(j(end),k,l,:) + xscl * u(j(end),k,l,:); 
      if     comp > 3, vg = w2(j(end-1),k,l,comp-3);
      elseif comp,     vg = w1(j(end-1),k,l,comp);
      else             vg = s2(j(end-1),k,l);
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
      xg = x(j,k(1),l,:) + xscl * u(j,k(1),l,:); 
      if     comp > 3, vg = w2(j,k(1),l,comp-3);
      elseif comp,     vg = w1(j,k(1),l,comp);
      else             vg = s2(j,k(1),l);
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
      xg = x(j,k(end),l,:) + xscl * u(j,k(end),l,:); 
      if     comp > 3, vg = w2(j,k(end-1),l,comp-3);
      elseif comp,     vg = w1(j,k(end-1),l,comp);
      else             vg = s2(j,k(end-1),l);
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
      xg = x(j,k,l(1),:) + xscl * u(j,k,l(1),:); 
      if     comp > 3, vg = w2(j,k,l(1),comp-3);
      elseif comp,     vg = w1(j,k,l(1),comp);
      else             vg = s2(j,k,l(1));
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
      xg = x(j,k,l(end),:) + xscl * u(j,k,l(end),:); 
      if     comp > 3, vg = w2(j,k,l(end-1),comp-3);
      elseif comp,     vg = w1(j,k,l(end-1),comp);
      else             vg = s2(j,k,l(end-1));
      end
      xg = squeeze( xg );
      vg = squeeze( vg );
      hsurf(end+1) = surf( xg(:,:,1), xg(:,:,2), xg(:,:,3), double( vg ) );
    end
  end
otherwise return
end
set( hsurf, ...
  'Tag', 'surf', ...
  'LineWidth', linewidth / 4, ...
  'EdgeColor', edgecolor, ...
  'FaceColor', facecolor, ...
  'FaceAlpha', 1, ...
  'FaceLighting', 'none' );

