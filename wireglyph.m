%------------------------------------------------------------------------------%
% WIREGLYPH

hglyph = [];
if ~length( mga ) || ~fscl, return, end
scl = .5 * h * ( 1 / fscl ) ^ glyphexp;
switch size( mga, 2 );
case 1
  mga = scl * mga .^ ( 0.5 * glyphexp - 0.5 );
  for i = 1:3
    vga(:,i) = vga(:,i) .* mga;
  end
  ng = size( mga, 1 );
  if glyphtype < 0
    clear xg
    xg        = xga - vga;
    xg(:,:,2) = xga + vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hglyph = plot3( xg(:,1), xg(:,2), xg(:,3) );
    hold on
  else
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
case 3
  mga = scl * sign( mga ) .* abs( mga ) .^ glyphexp;
  for i = 1:3
    vga(:,i:3:end) = vga(:,i:3:end) .* mga;
  end
  for ii = 1:3
    i = 3 * ii + ( -2 : 0 );
    if glyphtype < 0
      ng = size( mga, 1 );
      xg        = xga - vga(:,i);
      xg(:,:,2) = xga + vga(:,i);
      xg(:,:,3) = NaN;
      xg = permute( xg, [ 3 1 2 ] );
      xg = reshape( xg, [ 3 * ng 3 ] );
      hglyph(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3) );
      hold on
    else
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
otherwise
  error( 'size of mga' )
end
set( hglyph, 'Tag', 'glyph' );

