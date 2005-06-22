%------------------------------------------------------------------------------%
% TIMESERIESVIZ

msg = 'no time series data at this location';
for iz = 1:size( out, 1 )
  i1 = outi1(:,iz)';
  i2 = outi2(:,iz)';
  i = xhair + halo1;
  if outint(iz) == 1 && strcmp( outvar{iz}, field ) ...
    && sum( i >= i1 & i <= i2 ) == 3
    nn = i2 - i1 + 1;
    i = i - i1;
    offset = 4 * sum( i .* cumprod( [ 1 nn(1:2) ] ) );
    switch field
    case 'v', time = ( 0 : it ) * dt + dt / 2;
    otherwise time = ( 0 : it ) * dt;
    end
    figure( ...
     'Color', background, ...
     'KeyPressFcn', 'delete(gcbf)', ...
     'DefaultAxesColorOrder', foreground, ...
     'DefaultAxesColor', background, ...
     'DefaultAxesXColor', foreground, ...
     'DefaultAxesYColor', foreground, ...
     'DefaultAxesZColor', foreground, ...
     'DefaultLineColor', foreground, ...
     'DefaultLineLinewidth', linewidth, ...
     'DefaultTextHorizontalAlignment', 'center', ...
     'DefaultTextColor', foreground )
    clear vg
    for i = 1:ncomp
      for itt = 1:it
        file = sprintf( 'out/%02d/%1d/%05d', iz, i, itt );
        fid = fopen( file, 'rl' );
        fseek( fid, offset, -1 );
        vg(itt+1,i) = fread( fid, 1, 'float32' );
        fclose( fid );
      end
    end
    tg = time;
    newtitles = titles(2:end);
    if km
      fcorner = vp / ( 6 * h );
      nn = 2 * round( 1 / ( fcorner * dt ) );
      b = .5 * ( 1 - cos( 2 * pi * (1:nn-1) / nn ) );  % hanning
      %b = [ b b(end-1:-1:1) ];
      a  = sum( b );
      vg = filter( b, a, [ vg; zeros( nn - 1, size( vg, 2 ) ) ] );
      time = [ time time(end) + dt * ( 1 : nn - 1 ) ];
    end
    if strcmp( model, 'explosion' ) && strcmp( field, 'v' )
      j = xhair(1) + halo1(1);
      k = xhair(2) + halo1(2);
      l = xhair(3) + halo1(3);
      j1 = hypocenter(1);
      k1 = hypocenter(2);
      l1 = hypocenter(3);
      xg = squeeze( x(j,k,l,:) - x(j1,k1,l1,:) );
      rg = sum( xg .* xg );
      rg = sqrt( rg );
      tg = tg - rg / vp;
      if ( xg(1) || xg(2) )
        rot = [ xg(1)  xg(2) xg(1)*xg(3)
                xg(2) -xg(1) xg(2)*xg(3)
                xg(3)     0 -xg(1)*xg(1)-xg(2)*xg(2) ];
        tmp = sqrt( sum( rot .* rot, 1 ) );
        for i = 1:3
          rot(i,:) = rot(i,:) ./ tmp;
        end
        vg = vg * rot;
        newtitles = { 'Vr' 'Vh' 'Vv' };
      end
      vk = zeros( it+1, 1 );
      i = find( tg > 0 );
      switch srctimefcn
      case 'brune'
        vk(i,1) = moment(1) / 4 / pi / rho0 / vp ^ 2 / domp ^ 2 / rg / vp * ...
        exp( -tg(i) / domp ) .* ( tg(i) * vp / rg - tg(i) / domp + 1 );
      case 'sbrune'
        vk(i,1) = moment(1) / 8 / pi / rho0 / vp ^ 2 / domp ^ 3 / rg / vp * ...
        exp( -tg(i) / domp ) .* ( tg(i) * vp / rg - tg(i) / domp + 2 ) .* tg(i);
      otherwise error srctimefcn
      end
      if km
        vk = filter( b, a, [ vk; zeros( nn - 1, 1 ) ] );
      end
      plot( time, vk, ':' )
      hold on
    end
    plot( time, vg )
    hold on
    for i = 1 : length( newtitles )
      [ tmp, ii ] = max( abs( vg(:,i) ) );
      iii = max( 1, ii - 1 );
      xg1 = .5 * double( time(ii) + time(iii) );
      xg2 = .5 * double( vg(ii,i) + vg(iii,i) );
      if xg2 > 0
        text( xg1, xg2, newtitles(i), 'Hor', 'right', 'Ver', 'bottom' )
      else
        text( xg1, xg2, newtitles(i), 'Hor', 'right', 'Ver', 'top' )
      end
    end
    ylabel( field )
    xlabel( 'Time' )
    title( num2str( xhair + halo1 ) )
    set( 0, 'CurrentFigure', 1 )
    if ncomp == 3 && 0
      figure
      scl = .5 * h * ( 1 / fscl ) ^ glyphexp;
      for i = 1:3
        vg(:,i) = xhairtarg(i) + scl * vg(:,i);
      end
      hglyph = plot3( vg(:,1), vg(:,2), vg(:,3) );
    end
    msg = '';
    return
  end
end
