%------------------------------------------------------------------------------%
% WIREGLYPH

hand = [];
if ~length( mga ) || ~fscl, return, end
gscl = .5 * h * ( 1 / fscl ) ^ gexp;
switch size( mga, 2 );
case 1
  ng = size( mga, 1 );
  mga = gscl * mga .^ ( 0.5 * gexp - 0.5 );
  for i = 1:3
    vga(:,i) = vga(:,i) .* mga;
  end
  if glyphtype < 0
    clear xg
    xg        = xga - vga;
    xg(:,:,2) = xga + vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hand = plot3( xg(:,1), xg(:,2), xg(:,3) );
    hold on
  else
    xg        = xga;
    xg(:,:,2) = xga - vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hand = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', [0 .5 1] );
    hold on
    xg        = xga;
    xg(:,:,2) = xga + vga;
    xg(:,:,3) = NaN;
    xg = permute( xg, [ 3 1 2 ] );
    xg = reshape( xg, [ 3 * ng 3 ] );
    hand(2) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', [1 .5 0] );
  end
case 3
  mga = gscl * sign( mga ) .* abs( mga ) .^ gexp;
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
      hand(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3) );
      hold on
    else
      ig = find( mga(:,ii) < 0 );
      ng = size( ig, 1 );
      xg        = xga(ig,:) - vga(ig,i);
      xg(:,:,2) = xga(ig,:) + vga(ig,i);
      xg(:,:,3) = NaN;
      xg = permute( xg, [ 3 1 2 ] );
      xg = reshape( xg, [ 3 * ng 3 ] );
      hand(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', [ 0 .5 1 ] );
      hold on
      ig = find( mga(:,ii) > 0 );
      ng = size( ig, 1 );
      xg        = xga(ig,:) - vga(ig,i);
      xg(:,:,2) = xga(ig,:) + vga(ig,i);
      xg(:,:,3) = NaN;
      xg = permute( xg, [ 3 1 2 ] );
      xg = reshape( xg, [ 3 * ng 3 ] );
      hand(end+1) = plot3( xg(:,1), xg(:,2), xg(:,3), 'Color', [ 1 .5 0 ] );
    end
  end
otherwise
  error( 'size of mga' )
end
%lw = 2 * get( 1, 'DefaultLineLineWidth' );
set( hand, 'Tag', 'glyph' );

