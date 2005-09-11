%------------------------------------------------------------------------------%
% CONTROL

if ~gui, return, end

if ~length( keypress )
  keypress = get( gcf, 'CurrentKey' );
  keymod   = get( gcf, 'CurrentMod' );
end
km = length( keymod );
running = itstep;
nframe = length( frame );
dframe = 0;
itstep = 0;
set( 0, 'CurrentFigure', 1 )
msg = '';
action = 1;
anim = 0;

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
        'Help               F1    Acceleration      A    Zoom            < >'
        'Run                 R    Velocity          V    Reset Zoom        /'
        'Pause           Click    Displacement      U    3D/2D             D'
        'Step            Space    Stress            W    Length Scale      L'
        'Step 10    Ctrl-Space    Slip          Alt-U    Color Scale     [ ]'
        'Checkpoint          C    Slip rate     Alt-V    Round CS          \\'
        'Restart         Alt-Q    Magnitude         0    Reset CS      Alt-\\'
        '                         Component       1-6                       '
        'Rotate           Drag    Volumes/Slices    P    Build Movie       B'
        'Explore        Arrows    Glyphs            G    Frame -1          -'
        'Hypocenter          H    Isosurfaces       I    Frame +1          ='
        'Extremum            E    Surfaces          S    Frame -10      PgUp'
        'Replot          Enter    Outline           O    Frame +10      PgDn'
        'Clean Up    Backspace    Mesh              M    First Frame    Home'
        'Time Series         T    U Distortion      X    Last Frame      End'
        'Filtered TS     Alt-T    Fault Plane       F    Delete Frame    Del'
      }, ...
      'Tag', 'help', ...
      'Vertical',   'middle', ...
      'Margin', 10, ...
      'EdgeColor', 0.5 * [ 1 1 1 ], ...
      'BackgroundColor', background );
    set( gcf, 'CurrentAxes', haxes(1) )
  end
case 'home',       anim = 1; showframe = 1;
case 'end',        anim = 1; showframe = nframe;
case 'pageup',     anim = 1; dframe = -10;
case 'pagedown',   anim = 1; dframe =  10;
case 'hyphen',     anim = 1; dframe = -1;
case 'equal',      anim = 1; dframe =  1;
case { 'insert', 'return' }, viz
case 'backspace'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'delete'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if nframe > 1
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
    nframe = nframe - 1;
  end
  anim = 1;
case 'downarrow',  if km, xhairmove = -3; else xhairmove = -1; end, crosshairs
case 'uparrow',    if km, xhairmove = 3;  else xhairmove = 1;  end, crosshairs
case 'leftarrow',  xhairmove = -2; crosshairs
case 'rightarrow', xhairmove = 2;  crosshairs
case 'h',          xhairmove = 4;  crosshairs
case 'e',          xhairmove = 6;  crosshairs
case 'space', if km, itstep = 10; else itstep = 1; end, msg = 'Step';
case 'r', itstep = nt - it; msg = 'Run';
case 'q', if km, sord, return, end
case '0', comp = 0; colorscale; msg = titles( 1 );
case '1', comp = 1; colorscale; msg = titles( 2 );
case '2', comp = 2; colorscale; msg = titles( 3 );
case '3', comp = 3; colorscale; msg = titles( 4 );
case '4', comp = 4; colorscale; msg = titles( 5 );
case '5', comp = 5; colorscale; msg = titles( 6 );
case '6', comp = 6; colorscale; msg = titles( 7 );
case 'comma'
  if ~km, camva( 1.25 * camva )
  else    camva( 4 * camva )
  end
  panviz = 0;
case 'period'
  if ~km, camva( .8 * camva )
  else    camva( .25 * camva )
  end
  if length( hhud )
    campos( campos + xhairtarg - camtarget )
    camtarget( xhairtarg )
  end
  panviz = 1;
case 'd'
  if strcmp( camproj, 'orthographic' )
    camproj perspective
    camva( 1.25 * camva )
  else
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
  if ~km, tmp = .8 * get( gca, 'CLim' );
  else    tmp = .5 * get( gca, 'CLim' );
  end
  set( gca, 'CLim', tmp )
  if ~comp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'rightbracket'
  if ~km, tmp = 1.25 * get( gca, 'CLim' );
  else    tmp = 2    * get( gca, 'CLim' );
  end
  set( gca, 'CLim', tmp )
  if ~comp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'backslash'
  if km
    tmp = clim * [ -1 1 ];
    set( gca, 'CLim', tmp )
    if ~comp, tmp(1) = 0; end
    set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
    set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
  else
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
case 'p'
  volviz = ~volviz;
  if volviz, msg = 'Plotting volumes';
  else       msg = 'Plotting slices';
  end
case 'x'
  xlim = -~xlim;
  if xlim, msg = 'Mesh distortion on';
  else     msg = 'Mesh distortion off';
  end
case 'u', if km, field = 'uslip'; else, field = 'u'; end 
  colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if pass == 'v', msg = [ msg ' step code once for viz' ]; end
case 'w', if km, field = 't'; else, field = 'w'; end 
  colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if pass == 'v', msg = [ msg ' not in memory, step code once' ]; end
case 'a', field = 'a';
  colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if pass == 'w', msg = [ msg ' not in memory, step code once' ]; end
case 'v', if km, field = 'vslip'; else, field = 'v'; end 
  colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if pass == 'w', msg = [ msg ' step code once for viz' ]; end
case 'f'
  tmp = findobj( [ frame{ showframe } hhud ], 'Tag', 'fault' );
  if length( tmp ), dofault = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  dofault = ~dofault;
  if dofault, visible = 'on';  msg = 'Fault plane on';
  else        visible = 'off'; msg = 'Fault plane off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
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
case 'l'
  if strcmp( get( gca, 'Visible' ), 'off' ), axis on
  else axis off
  end
case 't', timeseriesviz
case 'c'
  if ~km
    save checkpoint it u v p1 p2 p3 p4 p5 p6 g1 g2 g3 g4 g5 g6 vslip uslip trup
    if exist( 'checkpoint.out', 'dir' )
      rmdir( 'checkpoint.out', 's' )
    end
    copyfile( 'out', 'checkpoint.out' )
    msg = 'Checkpoint Saved';
  else
    load checkpoint
    wstep
    if exist( 'out', 'dir' )
      rmdir( 'out', 's' )
    end
    copyfile( 'checkpoint.out', 'out' )
    msg = 'Checkpoint Loaded';
  end
case 'b'
  if savemovie && ~holdmovie
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
  end
  msg = 'Build Movie';
  anim = 1;
otherwise action = 0;
end
keypress = '';
keymod = '';

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

if itstep && ~running
  fprintf( '\b\b\b' )
  step
  fprintf( '>> ' )
end

