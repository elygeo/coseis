%------------------------------------------------------------------------------%
% CONTROL

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
newplot = '';
action = 1;
anim = 0;

switch keypress
case 'h'
  if length( hhelp )
    delete( hhelp )
    hhelp = [];
  else
    set( gcf, 'CurrentAxes', haxes(2) )
    hhelp = text( .5, .54, ...
      { 'SORD - Support-Operator Rupture Dynamics'
        ''
        'Run/Pause/Step             R Click Space'
        'Explore                       ; '' Arrows'
        'Color Scale                      [ ] \\ |'
        'Zoom                               , . /'
        'Rotate                              Drag'
        'Component                            0-6'
        'Field                              U V W'
        'Mesh Distortion                        X'
        '3D/2D                                  D'
        'Plot Style                             P'
        'Glyphs                                 G'
        'Isosurfaces                            I'
        'Surfaces                               S'
        'Mesh                                   M'
        'Replot                             Enter'
        'Clean Up                       Backspace'
        'Frame +/-                       - = Page'
        'First/Last Frame                Home End'
        'Delete Frame                         Del'
        'Write/Read Checkpoint          C Shift+C'
        'Build Movie                            B'
        'Help                                   H'
      }, ...
      'Tag', 'help', ...
      'Vertical',   'middle', ...
      'Margin', 10, ...
      'EdgeColor', 0.25 * [ 1 1 1 ], ...
      'BackgroundColor', background );
    set( gcf, 'CurrentAxes', haxes(1) )
  end
case 'home',       anim = 1; showframe = 1;
case 'end',        anim = 1; showframe = nframe;
case 'pageup',     anim = 1; dframe = -10;
case 'pagedown',   anim = 1; dframe =  10;
case 'hyphen',     anim = 1; dframe = -1;
case 'equal',      anim = 1; dframe =  1;
case 'insert',     newplot = plotstyle;
case 'backspace'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'delete'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if nframe > 1
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
  end
  anim = 1;
case 'downarrow',  if km, xhairmove = -3; else xhairmove = -1; end, crosshairs
case 'uparrow',    if km, xhairmove = 3;  else xhairmove = 1;  end, crosshairs
case 'leftarrow',  xhairmove = -2; crosshairs
case 'rightarrow', xhairmove = 2;  crosshairs
case 'quote',      xhairmove = 4;  crosshairs
case 'semicolon',  xhairmove = 5;  crosshairs
case 'return',     newplot = plotstyle;
case 'space', itstep = 1;       msg = 'Step';
case 'r',     itstep = nt - it; msg = 'Run';
case '0', comp = 0; colorscale; msg = titles( 1 );
case '1', comp = 1; colorscale; msg = titles( 2 );
case '2', comp = 2; colorscale; msg = titles( 3 );
case '3', comp = 3; colorscale; msg = titles( 4 );
case '4', comp = 4; colorscale; msg = titles( 5 );
case '5', comp = 5; colorscale; msg = titles( 6 );
case '6', comp = 6; colorscale; msg = titles( 7 );
case 'comma'
  camva( 1.25 * camva )
case 'period'
  camva( .8 * camva )
  if length( hhud )
    if ~viz3d, campos( campos + xhairtarg - camtarget ), end
    camtarget( xhairtarg )
  end
case 'slash'
  if ~km
    if viz3d
      camtarget( x0 )
      camva( 30 );
    else
      look = 5;
      lookat
    end
  else
    camva( 180 * h / xmax )
    if length( hhud )
      if ~viz3d, campos( campos + xhairtarg - camtarget ), end
      camtarget( xhairtarg )
    end
  end
case 'd', viz3d = ~viz3d; if viz3d, look = 4; else look = 5; end, lookat
case 'leftbracket'
  tmp = .8 * get( gca, 'CLim' );
  set( gca, 'CLim', tmp )
  if ~comp, tmp(1) = 0; end
  set( hlegend(1), 'String', sprintf( '%g', tmp(1) ) )
  set( hlegend(2), 'String', sprintf( '%g', tmp(2) ) )
case 'rightbracket'
  tmp = 1.25 * get( gca, 'CLim' );
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
  tmp = { '', 'outline', 'slice', 'cube' };
  for i = 1:length( tmp ), if strcmp( plotstyle, tmp{i} ), break, end, end
  i = mod( i, length( tmp ) );
  plotstyle = tmp{i+1};
  if i, msg = [ 'Plotstyle: ' plotstyle ];
  else  msg = 'Plotting off';
  end
case 'x'
  xlim = -~xlim;
  if xlim, msg = 'Mesh distortion on';
  else     msg = 'Mesh distortion off';
  end
case 'u', field = 'u'; colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'v', field = 'v'; colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'w', field = 'w'; colorscale; msg = titles{ comp + 1};
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'g'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'glyph' );
  if length( tmp ), doglyph = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  doglyph = ~doglyph;
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
  if length( tmp ), set( tmp, 'EdgeColor', edgecolor ), end
case 's'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), dosurf = strcmp( get( tmp(1), 'FaceColor' ), 'flat' ); end
  dosurf = ~dosurf;
  if dosurf, facecolor = 'flat'; msg = 'Surfaces on';
  else       facecolor = 'none'; msg = 'Surfaces off';
  end
  if length( tmp ), set( tmp, 'FaceColor', facecolor ), end
case 'c'
  if ~km
    save checkpoint it slip u v vv trup
    delete( [ hhud hmsg hhelp ] )
    hhud = []; hmsg = []; hhelp = [];
    set( 1, 'UserData', nframe )
    for i = 1:nframe
      set( [ frame{i} ], 'UserData', i )
    end
    saveas( 1, 'Checkpoint' )
    msg = 'Checkpoint Saved';
  else
    load checkpoint
    delete(1)
    openfig( 'checkpoint' );
    haxes = get( 1, 'Children' );
    nframe = get( 1, 'UserData' );
    for i = 1:nframe
      frame{i} = findobj( 1, 'UserData', i )';
    end
    showframe = nframe;
    msg = 'Checkpoint Loaded';
  end
case 'b'
  if savemovie && ~holdmovie
    delete( [ hhud hmsg hhelp ] )
    hhud = []; hmsg = []; hhelp = [];
    h0 = gca;
    delete( get( h0, 'Children' ) )
    for i = 1:count
      file = sprintf( 'out/viz/%05d', i );
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
if anim > 0 && nframe > 1
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

if newplot, viz, end
if itstep && ~running, step, end

