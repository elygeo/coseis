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
        'Explore                       C E Arrows'
        'Color Scale                      [ ] \\ |'
        'Zoom                               < > /'
        'Rotate                              Drag'
        'Component                            0-6'
        'Field                              U V W'
        'Time Series                            T'
        'Mesh Distortion                        X'
        '3D/2D                                  D'
        'Plot Style                             P'
        'Glyphs                                 G'
        'Isosurfaces                            I'
        'Slices                                 S'
        'Mesh                                   M'
        'Outline                                O'
        'Axis                                   A'
        'Replot                             Enter'
        'Clean Up                       Backspace'
        'Frame +/-                       - = Page'
        'First/Last Frame                Home End'
        'Delete Frame                         Del'
        'Write/Read Checkpoint          Q Shift+Q'
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
case 'c',          xhairmove = 4;  crosshairs
case 'e',          xhairmove = 6;  crosshairs
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
  if ~km, camva( 1.25 * camva )
  else    camva( 4 * camva )
  end
case 'period'
  if ~km, camva( .8 * camva )
  else    camva( .25 * camva )
  end
  if length( hhud )
    campos( campos + xhairtarg - camtarget )
    camtarget( xhairtarg )
  end
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
    camtarget( x0 )
    campos( camtarget + pos )
    camva( 22 )
  else
    v2 = campos - camtarget;
    pos = camdist * v2 / norm( v2 );
    camtarget( x0 )
    campos( camtarget + pos )
    camva( 27.5 )
  end
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
  tmp  = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), dosurf = strcmp( get( tmp(1), 'FaceColor' ), 'flat' ); end
  dosurf = ~dosurf;
  if dosurf, facecolor = 'flat'; visible = 'on';  msg = 'Surfaces on';
  else       facecolor = 'none'; visible = 'off'; msg = 'Surfaces off';
  end
  if length( tmp ), set( tmp, 'FaceColor', facecolor ), end
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surfline' );
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'a'
  if strcmp( get( gca, 'Visible' ), 'off' ), axis on
  else axis off
  end
case 't'
  for iz = 1:size( out, 1 )
    i1 = outi1(:,iz)';
    i2 = outi2(:,iz)';
    if outint(iz) == 1 && strcmp( outvar{iz}, field ) ...
      && sum( xhair >= i1 & xhair <= i2 ) == 3
      nn = i2 - i1 + 1;
      i = xhair - i1;
      offset = 4 * ( 1 + i .* cumprod( [ 1 nn(1:2) ] ) );
      ts = zeros( it + 1, 1 );
      if comp
        for itt = 2:it+1
          file = sprintf( 'out/%02d/%1d/%05d', iz, comp, itt );
          fid = fopen( file, 'wl' );
          fseek( fid, offset, -1 )
          ts(itt) = fread( fid );
          close( fid )
        end
      else
        for itt = 2:it+1
          for i = 1:ncomp
            file = sprintf( 'out/%02d/%1d/%05d', iz, i, itt );
            fid = fopen( file, 'wl' );
            fseek( fid, offset, -1 )
            ts(itt) = ts(itt) + fread( fid ) ^ 2;
            close( fid )
          end
        end
        ts = sqrt( ts );
      end
      switch field
      case 'v', time = ( 0 : it ) * dt + dt / 2;
      otherwise time = ( 0 : it ) * dt
      end
      figure
      plot( time, ts )
    else
      msg = 'no time series data at this location';
    end
  end
case 'q'
  if ~km
    save checkpoint it u v uslip trup
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
    stepw
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
if itstep && ~running
  spacer = '';
  step
  fprintf( '>> ' )
end

