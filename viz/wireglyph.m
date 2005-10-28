% Wire glyph

FIXME

hglyph = [];
if ~length( mga ) || ~flim, return, end
scl = .5 * dx * ( 1 / flim ) ^ glyphexp;
switch size( vga, 2 );
case 3
  %mga = scl * mga .^ ( glyphexp - 1 ); % CHECK
  mga = scl * mga .^ glyphexp; % CHECK
  for i = 1:3
    vga(:,i) = vga(:,i) .* mga;
  end
  ng = size( mga, 1 );
  switch glyphtype
  case 'wire'
    xg        = xga - vga;
    xg(:,:,2) = xga + vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hglyph = plot3( xg(:,1), xg(:,2), xg(:,3) );
    hold on
  case 'colorwire'
    xg        = xga;
    xg(:,:,2) = xga - vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hglyph = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', negcolor );
    hold on
    xg        = xga;
    xg(:,:,2) = xga + vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hglyph(2) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', poscolor );
  end
case 6
  mga = [];
  vga = [];
FIXME
  for ig = size( vga, 1 )
    wg = vga(iii,:);
    [ vec, val ] = eig( wg(c) );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i);
    vec = vec(:,i);
    mga = [ mga; val' ];
    vga = [ vga; vec(:)' ];
  end
  mga = scl * sign( mga ) .* abs( mga ) .^ glyphexp;
  for i = 1:3
    vga(:,i:3:end) = vga(:,i:3:end) .* mga;
  end
  for ii = 1:3
    i = 3 * ii + ( -2 : 0 );
    switch glyphtype
    case 'wire'
      ng = size( mga, 1 );
      xg        = xga - vga(:,i);
      xg(:,:,2) = xga + vga(:,i);
      xg(:,:,3) = NaN;
      xg = permute( xg, [ 3 1 2 ] );
      xg = reshape( xg, [ 3 * ng 3 ] );
      hglyph(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3) );
      hold on
    case 'colorwire'
      ig = find( mga(:,ii) < 0 );
      if ig
        ng = size( ig, 1 );
        xg        = xga(ig,:) - vga(ig,i);
        xg(:,:,2) = xga(ig,:) + vga(ig,i);
        xg(:,:,3) = NaN;
        xg = permute( xg, [ 3 1 2 ] );
        xg = reshape( xg, [ 3 * ng 3 ] );
        hglyph(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', negcolor );
        hold on
      end
      ig = find( mga(:,ii) > 0 );
      if ig
        ng = size( ig, 1 );
        xg        = xga(ig,:) - vga(ig,i);
        xg(:,:,2) = xga(ig,:) + vga(ig,i);
        xg(:,:,3) = NaN;
        xg = permute( xg, [ 3 1 2 ] );
        xg = reshape( xg, [ 3 * ng 3 ] );
        hglyph(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', poscolor );
        hold on
      end
    end
  end
otherwise, error 'mga'
end

