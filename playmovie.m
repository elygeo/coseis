%------------------------------------------------------------------------------%
% PLAYMOVIE

nframe = length( frame )
if play && nframe
  tmp = showframe;
  showframe = showframe + play;
  if showframe < 1
    if loopmovie, showframe = nframe;
    else          showframe = 1;
    end
  elseif showframe > nframe
    if loopmovie, showframe = 1;
    else          showframe = nframe;
    end
  end
  if tmp == showframe
    play = 0;
    msg = '';
  end
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
end

return

% Stereo
if stereoangle
  if 0
    delete( right )
    left  = gca;
    right = copyobj( left, gcf );
    set( left,  'Position', [ .05 .05 .4 .9 ] )
    set( right, 'Position', [ .55 .05 .4 .9 ] )
    axes( right )
    camorbit( stereoangle, 0, 'camera', 'x' )
    axes( left )
  else
    right = 2;
    if ~ishandle( right )
      figure( right )
      cameramenu
      cameratoolbar
      cameratoolbar( 'SetMode', 'orbit' )
      cameratoolbar( 'SetCoordSys', 'x' )
      cameratoolbar( 'ToggleSceneLight' );
    end
    left = get( 1, 'Children' );
    pos  = get( 1, 'Position' );
    set( 0, 'CurrentFigure', right )
    clf
    copyobj( left, right );
    camorbit( stereoangle, 0, 'camera', 'x' )
    pos(1) = 10 + pos(1) + pos(3);
    set( right, 'Position', pos )
  end
end

% Flythrough
if it <= ftcam(end,1);
  cam = interp1( ftcam(:,1), ftcam(:,2:end), it );
  pos   = cam(1:3);
  targ  = cam(4:6);
  upvec = cam(7:9);
  va    = cam(10);
  campos( rc + L * pos )
  camtarget( rc + L * targ )
  camup( upvec )
  if va, camva( va ), end
end

% Rasterize
ppi = 80;
filtersize = 3;
print( '-dpng', sprintf( '-r%g', ppi * filtersize ), file )
if filtersize ~= 1
  img = imread( file, 'png' );
  nn  = floor( size( img ) / filtersize )
  img = imresize( img, nn(1:2), 'bilinear' );
  imwrite( img, file, 'png' )
end

