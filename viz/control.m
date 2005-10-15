% GUI Control

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
case 'f1'
  if length( hhelp )
    delete( hhelp )
    hhelp = [];
  else
    set( gcf, 'CurrentAxes', haxes(2) )
    hhelp = text( .5, .54, ...
      { 'SORD - Support Operator Rupture Dynamics'
        ''
        'Help                F1    Acceleration      A    Zoom            < >'
        'Rotate            Drag    Velocity          V    Reset Zoom        /'
        'Explore         Arrows    Displacement      U    Perspective       P'
        'Hypocenter           H    Stress            W    Length Scale      X'
        'Extremum             E    Slip          Alt-U    Color Scale     [ ]'
        'Slice Direction  J K L    Slip rate     Alt-V    Round CS          \\'
        'Replot           Enter    Magnitude         0    Reset CS      Alt-\\'
        'Clean Up     Backspace    Component       1-6                       '
        'Time Series          T    Volumes/Slices    Z    Build Movie       B'
        'Filtered TS      Alt-T    Glyphs            G    Frame -1          -'
        '                          Isosurfaces       I    Frame +1          ='
        '                          Surfaces          S    Frame -10      PgUp'
        '                          Outline           O    Frame +10      PgDn'
        '                          Mesh              M    First Frame    Home'
        '                          U Distortion      D    Last Frame      End'
        '                                                 Delete Frame    Del'
      }, ...
      'Tag', 'help', ...
      'Vertical',   'middle', ...
      'Margin', 10, ...
      'EdgeColor', 0.5 * [ 1 1 1 ], ...
      'BackgroundColor', background );
    set( gcf, 'CurrentAxes', haxes(1) )
  end
case 'home',       anim = 1; showframe = 1; msg = 'First Frame';
case 'end',        anim = 1; showframe = nframe; msg = 'Last Frame';
case 'pageup',     anim = 1; dframe = -10; msg = 'Frame -10';
case 'pagedown',   anim = 1; dframe =  10; msg = 'Frame +10';
case 'hyphen',     anim = 1; dframe = -1;  msg = 'Frame -1';
case 'equal',      anim = 1; dframe =  1;  msg = 'Frame +1';
case { 'insert', 'return' }, viz
case 'backspace'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = []; msg = '';
case 'delete'
  msg = 'Delete Frame';
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if nframe > 1
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
    nframe = nframe - 1;
  end
  anim = 1;
case 'downarrow',  if km, cursormove = -3; else cursormove = -1; end, cursor
case 'uparrow',    if km, cursormove = 3;  else cursormove = 1;  end, cursor
case 'leftarrow',  if km, cursormove = -4; else cursormove = -2; end, cursor
case 'rightarrow', if km, cursormove = 4;  else cursormove = 2;  end, cursor
case 'j', cursormove = 0; islice = 1; cursor
case 'k', cursormove = 0; islice = 2; cursor
case 'l', cursormove = 0; islice = 3; cursor
case 'h', cursormove = 5; cursor; msg = 'Hypocenter';
case 'e', cursormove = 7; cursor; msg = 'Extreme value';
case '0', comp = 0; colorscale
case '1', comp = 1; colorscale
case '2', comp = 2; colorscale
case '3', comp = 3; colorscale
case '4', comp = 4; colorscale
case '5', comp = 5; colorscale
case '6', comp = 6; colorscale
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
    [ t, i1 ] = max( abs( v1 ) );
    [ t, i2 ] = max( abs( v2 ) );
    upvec(i1) = sign( v1(i1) );
    pos(i2) = sign( v2(i2) ) * norm( v2 );
    camup( upvec )
    campos( camtarget + pos )
  end
case 'slash'
  msg = 'Zoom Reset';
  if strcmp( camproj, 'orthographic' )
    v1 = camup;
    v2 = campos - camtarget;
    upvec = [ 0 0 0 ];
    pos = [ 0 0 0 ];
    [ t, i1 ] = max( abs( v1 ) );
    [ t, i2 ] = max( abs( v2 ) );
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
  panviz = 0;
case 'leftbracket'
  msg = 'Decrease Color Range';
  if ~km, tmp = .8 * get( gca, 'CLim' );
  else    tmp = .5 * get( gca, 'CLim' );
  end
  set( gca, 'CLim', tmp )
  if ~comp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'rightbracket'
  msg = 'Increase Color Range';
  if ~km, tmp = 1.25 * get( gca, 'CLim' );
  else    tmp = 2    * get( gca, 'CLim' );
  end
  set( gca, 'CLim', tmp )
  if ~comp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'backslash'
  if km
    msg = 'Round Color Scale';
    tmp = clim * [ -1 1 ];
    set( gca, 'CLim', tmp )
    if ~comp, tmp(1) = 0; end
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
    if ~comp, tmp(1) = 0; end
    set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
    set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
  end
case 'z'
  volviz = ~volviz;
  if volviz, msg = 'Plotting volumes';
  else       msg = 'Plotting slices';
  end
case 'd'
  xlim = -~xlim;
  if xlim, msg = 'Mesh distortion on';
  else     msg = 'Mesh distortion off';
  end
case 'u'
  if km, vizfield = 'sl'; else, vizfield = 'u'; end 
  colorscale
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'w'
  if km, vizfield = 't'; else, vizfield = 'w'; end 
  colorscale
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'a'
  vizfield = 'a';
  colorscale
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'v'
  if km, vizfield = 'sv'; else, vizfield = 'v'; end 
  colorscale
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'o'
  tmp = findobj( [ frame{ showframe } hhud ], 'Tag', 'outline' );
  if length( tmp ), dooutline = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  dooutline = ~dooutline;
  if dooutline, visible = 'on';  msg = 'Outline on';
  else          visible = 'off'; msg = 'Outline off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'g'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'glyph' );
  if length( tmp ), doglyph = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  doglyph = ~doglyph * ( 1 + km );
  if doglyph, visible = 'on';  msg = 'Glyphs on';
  else        visible = 'off'; msg = 'Glyphs off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'i'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'isosurf' );
  if length( tmp ), doisosurf = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  doisosurf = ~doisosurf;
  if doisosurf, visible = 'on';  msg = 'Isosurfaces on';
  else          visible = 'off'; msg = 'Isosurfaces off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'm'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), domesh = ~strcmp( get( tmp(1), 'EdgeColor' ), 'none' ); end
  domesh = ~domesh;
  foreground = get( 1, 'DefaultTextColor' );
  if domesh, edgecolor = foreground; msg = 'Mesh on';
  else       edgecolor = 'none';     msg = 'Mesh off';
  end
  msg = 'not turning on mesh because of Matlab bug';
  %if length( tmp ), set( tmp, 'EdgeColor', edgecolor ), end
case 's'
  tmp  = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), dosurf = strcmp( get( tmp(1), 'FaceColor' ), 'flat' ); end
  dosurf = ~dosurf;
  if dosurf, facecolor = 'flat'; visible = 'on';  msg = 'Surfaces on';
  else       facecolor = 'none'; visible = 'off'; msg = 'Surfaces off';
  end
  if length( tmp ), set( tmp, 'FaceColor', facecolor ), end
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surfline' );
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'x'
  if strcmp( get( gca, 'Visible' ), 'off' ), axis on, msg = 'Axis On';
  else axis off, msg = 'Axis Off';
  end
case 't', dofilter = km; sensor = icursor; tsviz
case 'b'
  if savemovie && ~holdmovie
    msg = 'Build Movie';
    delete( [ hhud hmsg hhelp ] )
    hhud = []; hmsg = []; hhelp = [];
    h0 = gca;
    delete( get( h0, 'Children' ) )
    for i = 1:count
      file = sprintf( 'out/viz/%06d', i );
      openfig( file, 'new', 'invisible' );
      frame{i} = copyobj( get( gca, 'Children' ), h0 )';
      delete( gcf )
    end
    holdmovie = 1;
    showframe = length( frame );
  else
    msg = 'Can''t Build Movie';
  end
  anim = 1;
otherwise, action = 0; msg = '';
end
keypress = '';

% Message
set( gcf, 'CurrentAxes', haxes(2) )
if action, delete( hmsg ), hmsg = []; end
if length( msg )
  hmsg = text( .02, .1, msg, 'Hor', 'left', 'Ver', 'bottom' );
  msg = '';
end
set( gcf, 'CurrentAxes', haxes(1) )
set( [ hhud hmsg hhelp ], 'HandleVisibility', 'off' )

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
end

drawnow

