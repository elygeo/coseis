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
    offset = 4 * ( 1 + sum( i .* cumprod( [ 1 nn(1:2) ] ) ) );
    switch field
    case 'v', time = ( 0 : it ) * dt + dt / 2;
    otherwise time = ( 0 : it ) * dt
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
    clear xg
    for i = 1:ncomp
      for itt = 1:it
        file = sprintf( 'out/%02d/%1d/%05d', iz, i, itt );
        fid = fopen( file, 'rl' );
        fseek( fid, offset, -1 );
        xg(itt+1,i) = fread( fid, 1, 'float32' );
        fclose( fid );
      end
    end
    plot( time, xg )
    hold on
    for i = 1:ncomp
      [ tmp, ii ] = max( abs( xg(:,i) ) );
      ii = max( 1, ii - 1 );
      if xg(ii,i) > 0
        text( time(ii), xg(ii,i), titles(i+1), 'Hor', 'right', 'Ver', 'bottom' )
      else
        text( time(ii), xg(ii,i), titles(i+1), 'Hor', 'right', 'Ver', 'top' )
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
        xg(:,i) = xhairtarg(i) + scl * xg(:,i);
      end
      hglyph = plot3( xg(:,1), xg(:,2), xg(:,3) );
    end
    msg = '';
    return
  end
end
