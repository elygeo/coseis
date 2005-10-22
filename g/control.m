% GUI Control

set( haxes(2), 'HandleVisibility', 'on' )
if ~length( keypress )
  keypress = get( gcf, 'CurrentKey' );
  keymod   = get( gcf, 'CurrentMod' );
end
km = length( keymod );
keymod = '';
nframe = length( frame );
dframe = 0;
itstep = 0;
set( 0, 'CurrentFigure', 1 )
msg = '';
action = 1;
anim = 0;
ditviz = 0;

switch keypress
case 'message'
  msg = message;
case 'f1'
  if length( hhelp )
    delete( hhelp )
    hhelp = [];
  else
    set( gcf, 'CurrentAxes', haxes(2) )
    hhelp = text( .5, .54, ...
      { 'Acceleration      A   Zoom            < >   Time Series       T'
        'Velocity          V   Zoom Out          /   Filtered TS   Alt-T'
        'Displacement      U   Reset View    Alt-/   Space-Time        Y'
        'Stress            W   Perspective       P   Filtered ST   Alt-Y'
        'Magnitude         0   Explore      Arrows   Step time     Space'
        'Component       1-6   Hypocenter        H   Render movie      R'
        'Volumes/Slices    Z   Extremum          E   Frame -1          -'
        'Slice         J K L   Length Scale      X   Frame +1          ='
        'Glyphs            G   Color Scale     [ ]   Frame -10      PgUp'
        'Isosurfaces       I   Round CS          \\   Frame +10      PgDn'
        'Surfaces          S   Reset CS      Alt-\\   First Frame    Home'
        'Outline           O   Render        Enter   Last Frame      End'
        'Mesh              M   Clean     Backspace   Delete Frame    Del'
      }, ...
      'Vertical',   'middle', ...
      'Margin', 10, ...
      'EdgeColor', 0.5 * [ 1 1 1 ], ...
      'BackgroundColor', background );
    set( gcf, 'CurrentAxes', haxes(1) )
  end
case 'a', if km, field = 'am'; else, field = 'a'; end, msg = field;
case 'v', if km, field = 'vm'; else, field = 'v'; end, msg = field;
case 'u', if km, field = 'um'; else, field = 'u'; end, msg = field;
case 'w', if km, field = 'wm'; else, field = 'w'; end, msg = field;
case '0', icomp = 0; colorscale
case '1', icomp = 1; colorscale
case '2', icomp = 2; colorscale
case '3', icomp = 3; colorscale
case '4', icomp = 4; colorscale
case '5', icomp = 5; colorscale
case '6', icomp = 6; colorscale
case 'home',     anim = 1; showframe = 1;
case 'end',      anim = 1; showframe = nframe;
case 'pageup',   anim = 1; dframe = -10;
case 'pagedown', anim = 1; dframe =  10;
case 'hyphen',   anim = 1; dframe = -1;
case 'equal',    anim = 1; dframe =  1;
case 'return',   render
case 'q',        viz
case 'space'
  ditmul = 1;
  if km, ditmul = 10; end
  icursor(4) = icursor(4) + ditmul * dit;
  render
case 'r'
  cd 'out'
  currentstep
  cd '..'
  ditmul = 1;
  if km, ditmul = 10; end
  while icursor(4) + ditmul * dit <= it;
    icursor(4) = icursor(4) + ditmul * dit;
    render
  end
case 'backspace'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = []; msg = '';
case 'delete'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if nframe > 1
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
    nframe = nframe - 1;
    msg = 'Delete ';
  end
  anim = 1;
case 'downarrow',  if km, cursormove = -3; else cursormove = -1; end, cursor
case 'uparrow',    if km, cursormove = 3;  else cursormove = 1;  end, cursor
case 'leftarrow',  if km, cursormove = -4; else cursormove = -2; end, cursor
case 'rightarrow', if km, cursormove = 4;  else cursormove = 2;  end, cursor
case 'h', cursormove = 5; cursor; msg = 'Hypocenter';
case 'e', cursormove = 6; cursor; msg = 'Extreme value';
case 'j', islice = 1; msg = 'j slice';
case 'k', islice = 2; msg = 'k slice';
case 'l', islice = 3; msg = 'l slice';
case 'comma'
  msg = 'Zoom out';
  if ~km, camva( 1.25 * camva )
  else    camva( 4 * camva )
  end
  panviz = 0;
case 'period'
  msg = 'Zoom In';
  if ~km, camva( .8 * camva )
  else    camva( .25 * camva )
  end
  if length( hhud )
    campos( campos + xcursor - camtarget )
    camtarget( xcursor )
  end
  panviz = 1;
case 'p'
  if strcmp( camproj, 'orthographic' )
    msg  = 'Perspective';
    camproj perspective
    camva( 1.25 * camva )
  else
    msg  = 'Orthographic';
    camproj orthographic
    camva( .8 * camva )
    v1 = camup;
    v2 = campos - camtarget;
    upvec = [ 0 0 0 ];
    pos = [ 0 0 0 ];
    [ tmp, i1 ] = max( abs( v1 ) );
    [ tmp, i2 ] = max( abs( v2 ) );
    upvec(i1) = sign( v1(i1) );
    pos(i2) = sign( v2(i2) ) * norm( v2 );
    camup( upvec )
    campos( camtarget + pos )
  end
case 'slash'
  panviz = 0;
  if km
    msg = 'Reset View';
    if strcmp( camproj, 'orthographic' )
      lookat( islice, upvector, xcenter, camdist )
    else
      lookat( 0, upvector, xcenter, camdist )
    end
    [ tmp, l ] = max( abs( upvector ) );
    tmp = 'xyz';
    cameratoolbar( 'SetMode', 'orbit' )
    cameratoolbar( 'SetCoordSys', tmp(l) )
    set( 1, 'KeyPressFcn', 'control' )
  else
    msg = 'Zoom Out';
    if strcmp( camproj, 'orthographic' )
      v1 = camup;
      v2 = campos - camtarget;
      upvec = [ 0 0 0 ];
      pos = [ 0 0 0 ];
      [ tmp, i1 ] = max( abs( v1 ) );
      [ tmp, i2 ] = max( abs( v2 ) );
      upvec(i1) = sign( v1(i1) );
      pos(i2) = sign( v2(i2) ) * camdist;
      camup( upvec )
      camtarget( xcenter )
      campos( camtarget + pos )
      camva( 22 )
    else
      v2 = campos - camtarget;
      pos = camdist * v2 / norm( v2 );
      camtarget( xcenter )
      campos( camtarget + pos )
      camva( 27.5 )
    end
  end
case 'leftbracket'
  msg = 'Decrease Color Range';
  if ~km, tmp = .8 * get( gca, 'CLim' );
  else    tmp = .5 * get( gca, 'CLim' );
  end
  set( gca, 'CLim', tmp )
  if ~icomp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'rightbracket'
  msg = 'Increase Color Range';
  if ~km, tmp = 1.25 * get( gca, 'CLim' );
  else    tmp = 2    * get( gca, 'CLim' );
  end
  set( gca, 'CLim', tmp )
  if ~icomp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'backslash'
  if km
    msg = 'Round Color Scale';
    tmp = clim * [ -1 1 ];
    set( gca, 'CLim', tmp )
    if ~icomp, tmp(1) = 0; end
    set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
    set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
  else
    msg = 'Reset Color Scale';
    tmp = get( gca, 'CLim' );
    tmp = tmp(2);
    exp10 = floor( log10( tmp ) );
    tmp = tmp / 10 ^ exp10;
    exp2 = ceil( log2( tmp ) );
    if exp2 > 2
      exp2 = 0;
      exp10 = exp10 + 1;
    end
    tmp = 2 ^ exp2 * 10 ^ exp10 * [ -1 1 ];
    set( gca, 'CLim', tmp )
    if ~icomp, tmp(1) = 0; end
    set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
    set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
  end
case 'z'
  volviz = ~volviz;
  if volviz, msg = 'Plotting volumes';
  else       msg = 'Plotting slices';
  end
case 'o'
  dooutline = ~dooutline;
  if dooutline, set( houtline, 'Visible', 'on' ),  msg = 'Outline on';
  else          set( houtline, 'Visible', 'off' ), msg = 'Outline off';
  end
case 'g'
  doglyph = ~doglyph * ( 1 + km );
  if doglyph, msg = 'Glyphs on';
  else        msg = 'Glyphs off';
  end
case 'i'
  doisosurf = ~doisosurf;
  if doisosurf, msg = 'Isosurfaces on';
  else          msg = 'Isosurfaces off';
  end
case 'm'
  domesh = ~domesh;
  if domesh, msg = 'Mesh on';
  else       msg = 'Mesh off';
  end
case 's'
  dosurf = ~dosurf;
  if dosurf, msg = 'Surfaces on';
  else       msg = 'Surfaces off';
  end
case 'x'
  if strcmp( get( gca, 'Visible' ), 'off' ), axis on, msg = 'Axis On';
  else axis off, msg = 'Axis Off';
  end
case 't'
  sensor = icursor(1:3);
  [ tt, vt, tta, vta, labels, msg ] = timeseries( field, sensor, km );
  if length( vt )
    fig
    tsplot
    pan xon
    zoom xon
    set( gcf, 'KeyPressFcn', 'delete(gcbf)' )
  end
case 'y', msg = 'Space-time not implemented yet';
otherwise, action = 0; msg = '';
end
keypress = '';

% Frames
nframe = length( frame );
if anim > 0
  showframe = showframe + dframe;
  showframe = max( showframe, 1 );
  showframe = min( showframe, nframe );
  if showframe == nframe
    set( hhud, 'Visible', 'on' )
  else
    set( hhud, 'Visible', 'off' )
  end
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
  msg = [ msg 'Frame ' num2str( showframe ) ];
end

% Message
set( 0, 'CurrentFigure', 1 )
set( gcf, 'CurrentAxes', haxes(2) )
if action, delete( hmsg ), hmsg = []; end
if length( msg )
  hmsg = text( .02, .1, msg, 'Hor', 'left', 'Ver', 'bottom' );
  msg = '';
end
set( gcf, 'CurrentAxes', haxes(1) )
set( [ hhud hmsg hhelp haxes(2) ], 'HandleVisibility', 'off' )

