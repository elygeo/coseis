%------------------------------------------------------------------------------%
% CONTROL

running = itstep;
keypress = get( gcf, 'CurrentKey' );
if initialize, keypress = 'h'; end
km = length( get( gcf, 'CurrentMod' ) );
nframe = length( frame );
dframe = 0;
itstep = 0;
xhairmove = 0;
set( 0, 'CurrentFigure', 1 )
msg = '';
msg2 = '';
newplot = '';

switch keypress
case 'h'
  if length( hhelp )
    delete( hhelp )
    hhelp = [];
  else
    set( gcf, 'CurrentAxes', haxes(2) )
    hhelp = text( .5, .5, ...
      { 'SORD - Support-Operator Rupture Dynamics'
        ''
        'this help screen                       h'
        'step/run calulations             space r'
        'pause calulations            mouse-click'
        'rotate plot                   drag mouse'
        'crosshairs                arrow-keys ; '''
        'zoom                               z , .'
        'reset 3D/2D                          / ?'
        'color scale +/-/reset              [ ] \\'
        'plot style                             p'
        'mesh distortion                        x'
        'velocity/stress glyphs               v w'
        'glyph type                           g G'
        'mesh/surfaces                        m s'
        'component/magnitude                1-6 0'
        'plot V/W                             v w'
        'replot                             enter'
        'frame +/-                       - = page'
        'clear messages                 backspace'
        'first/last frame                home end'
        'delete frame                         del'
        'write/read checkpoint                c C'
        'build movie                            b' }, ...
      'Tag', 'help', ...
      'Horizontal', 'center', ...
      'Vertical',   'middle', ...
      'Margin', 10, ...
      'BackgroundColor', bg );
    set( gcf, 'CurrentAxes', haxes(1) )
  end
case 'home',       showframe = 1;
case 'end',        showframe = nframe;
case 'pageup',     dframe = -10;
case 'pagedown',   dframe =  10;
case 'hyphen',     dframe = -1;
case 'equal',      dframe =  1;
case 'insert',     newplot = plotstyle;
case 'backspace'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
case 'delete'
  delete( [ hhud hmsg hhelp ] )
  hhud = []; hmsg = []; hhelp = [];
  if nframe
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
  end
case 'downarrow',  if km, xhairmove = -3; else xhairmove = -1; end
case 'uparrow',    if km, xhairmove = 3;  else xhairmove = 1;  end
case 'leftarrow',  xhairmove = -2;
case 'rightarrow', xhairmove = 2;
case 'quote',      xhairmove = 4;
case 'semicolon',  xhairmove = 5;
case 'return',     newplot = plotstyle;
case 'space', itstep = 1;       msg = 'step';
case 'r',     itstep = nt - it; msg = 'run';
case '0', comp = 0; msg = titles( 1 );
case '1', comp = 1; msg = titles( 2 );
case '2', comp = 2; msg = titles( 3 );
case '3', comp = 3; msg = titles( 4 );
case '4', comp = 4; msg = titles( 5 );
case '5', comp = 5; msg = titles( 6 );
case '6', comp = 6; msg = titles( 7 );
case 'z'
  zoomed = ~zoomed;
  if zoomed
    j = xhair(1) + halo1(1);
    k = xhair(2) + halo1(2);
    l = xhair(3) + halo1(3);
    switch field
    case 'v'
      xp = x(j,k,l,:) + uscl * u(j,k,l,:);
    case 'w'
      xp = 0.125 * ( ( ...
        x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
        x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
        x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
        x(j,k,l+1,:) + x(j+1,k+1,l,:) ) + ...
        uscl * ( ...
        u(j,k,l,:) + u(j+1,k+1,l+1,:) + ...
        u(j+1,k,l,:) + u(j,k+1,l+1,:) + ...
        u(j,k+1,l,:) + u(j+1,k,l+1,:) + ...
        u(j,k,l+1,:) + u(j+1,k+1,l,:) ) );
    end
    camtarget( double( squeeze( xp ) ) );
    camva( camva * 2 * h / xscl );
  else
    camtarget( double( x0 ) );
    camva( camva / 2 / h * xscl );
  end
case 'comma',  camva( 1.25 * camva )
case 'period', camva( .8 * camva )
case 'slash', if km, look = 5; else look = 4; end, lookat
case 'leftbracket'
  tmp = 1.25 * get( gca, 'CLim' );
  set( haxes, 'CLim', tmp )
  msg = sprintf( 'clim = %g %g', tmp );
case 'rightbracket'
  tmp = 0.8 * get( gca, 'CLim' );
  set( haxes, 'CLim', tmp )
  msg = sprintf( 'clim = %g %g', tmp );
case 'backslash'
  set( haxes, 'CLim', [ -clim clim ] )
  msg = sprintf( 'clim = %g %g', clim );
case 'p'
  tmp = { '', 'outline', 'slice', 'cube' };
  for i = 1:length( tmp ), if strcmp( plotstyle, tmp{i} ), break, end, end
  i = mod( i, length( tmp ) );
  plotstyle = tmp{i+1};
  if i, msg = plotstyle;
  else  msg = 'plotting off';
  end
case 'x'
  ulim = -~ulim;
  if ulim, msg = 'mesh distortion on';
  else     msg = 'mesh distortion off';
  end
case 'v', field = 'v'; msg = 'V';
case 'w', field = 'w'; msg = 'W';
case 'g'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'glyph' );
  if length( tmp ), wglyph = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  glyph = ~glyph;
  if ~km
    glyphtype = ~glyphtype;
    if glyphtype,  msg = 'wire glyph';
    else           msg = 'Reynolds glyph';
    end
  else
    xglyphtype = ~xglyphtype;
    if xglyphtype, msg = 'wire crosshair';
    else           msg = 'Reynolds crosshair';
    end
  end
  if wglyph, visible = 'on';  msg = 'W glyphs on';
  else       visible = 'off'; msg = 'W glyphs off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'm'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), domesh = ~strcmp( get( tmp(1), 'EdgeColor' ), 'none' ); end
  domesh = ~domesh;
  fg = get( 1, 'DefaultTextColor' );
  if domesh, edgecolor = fg;     msg = 'mesh on';
  else       edgecolor = 'none'; msg = 'mesh off';
  end
  if length( tmp ), set( tmp, 'EdgeColor', color ), end
case 's'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), domesh = strcmp( get( tmp(1), 'FaceColor' ), 'flat' ); end
  dosurf = ~dosurf;
  if dosurf, facecolor = 'flat'; msg = 'surfaces on';
  else       facecolor = 'none'; msg = 'surfaces off';
  end
  if length( tmp ), set( tmp, 'FaceColor', facecolor ), end
case 'i'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'isosurf' );
  if length( tmp ), isosurf = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  isosurf = ~isosurf;
  if isosurf, visible = 'on';  msg = 'isosurfaces on';
  else        visible = 'off'; msg = 'isosurfaces off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'c'
  if ~km
    save checkpoint it slip u v vv trup
    delete( [ hhud hmsg hhelp ] )
    hhud = []; hmsg = []; hhelp = [];
    set( 1, 'UserData', nframe )
    for i = 1:nframe
      set( [ frame{i} ], 'UserData', i )
    end
    saveas( 1, 'checkpoint' )
    msg = 'checkpoint saved';
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
    msg = 'checkpoint loaded';
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
  msg = 'build movie';
end

if xhairmove
  delete( [ hhud hhelp ] )
  hhelp = [];
  xhaircell = strcmp( field, 'w' );
  way = sign( xhairmove );
  xhairmove = abs( xhairmove );
  nc = ncore - xhaircell;
  if xhairmove == 4
    xhair = hypocenter - halo1;
    if nrmdim, slicedim = nrmdim; end
  elseif xhairmove == 5
    xhair = hypocenter - halo1;
    xhair(downdim) = 1;
    slicedim = downdim;
  else
    v1 = camup;
    v3 = camtarget - campos;
    v2 = cross( v3, v1 );
    [ t, i1 ] = max( abs( v1 ) );
    [ t, i2 ] = max( abs( v2 ) );
    i3 = 1:3;
    i3( [ i1 i2 ] ) = [];
    i = [ i1 i2 i3 ];
    tmp = [ sign( v1(i1) ) sign( v2(i2) ) sign( v3(i3) ) ];
    way = way * tmp(xhairmove);
    xhairmove = i(xhairmove);
    i = abs( xhairmove );
    if i == slicedim
      xhair(i) = xhair(i) + way;
      if xhair(i) > nc(i), xhair(i) = nc(i);
      elseif xhair(i) < 1,  xhair(i) = 1;
      end
    end
    slicedim = i;
  end
  j = xhair(1) + halo1(1);
  k = xhair(2) + halo1(2);
  l = xhair(3) + halo1(3);
  switch field
  case 'v'
    xg  = x(j,k,l,:);
    xga = x(j,k,l,:) + uscl * u(j,k,l,:);
    mga = s1(j,k,l);
    vga = v(j,k,l,:);
    msg = sprintf( 'Vx %9.2e\nVy %9.2e\nVz %9.2e\n|V|%9.2e', vga, mga );
  case 'w'
    xg = 0.125 * ( ...
      x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
      x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
      x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
      x(j,k,l+1,:) + x(j+1,k+1,l,:) );
    xga = xg + 0.125 * uscl * ( ...
      u(j,k,l,:) + u(j+1,k+1,l+1,:) + ...
      u(j+1,k,l,:) + u(j,k+1,l+1,:) + ...
      u(j,k+1,l,:) + u(j+1,k,l+1,:) + ...
      u(j,k,l+1,:) + u(j+1,k+1,l,:) );
    c = [ 1 6 5; 6 2 4; 5 4 3 ];
    clear wg
    wg(1:3) = w1(j,k,l,:);
    wg(4:6) = w2(j,k,l,:);
    [ vec, val ] = eig( wg(c) );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i);
    vec = vec(:,i);
    mga = val';
    vga = vec(:)';
    msg = sprintf( 'Wxx %9.2e\nWyy %9.2e\nWzz %9.2e\nWyz %9.2e\nWzx %9.2e\nWzy %9.2e\n|W| %9.2e', wg, val(3) );
  end
  set( gcf, 'CurrentAxes', haxes(2) )
  hhud(1) = text( .02, .08, msg, 'Hor', 'left', 'Ver', 'bottom' );
  msg = sprintf( '%.3fs\n%.1fm\n%.1fm\n%.1fm', it * dt, xg );
  hhud(2) = text( .98, .98, msg, 'Hor', 'right', 'Ver', 'top' );
  msg = sprintf( '%g i\n%g j\n%g k\n%g l', it, j, k, l );
  set( gcf, 'CurrentAxes', haxes(1) )
  if zoomed, camtarget( double( squeeze( xg ) ) ), end
  lines = [ 1 1 1  -1 -1 -1 ];
  lines(slicedim)   = xhair(slicedim);
  lines(slicedim+3) = xhair(slicedim) + xhaircell;
  if nrmdim & slicedim ~= nrmdim
    lines = [ lines; lines ];
    i = nrmdim + [ 0 3 ];
    lines(1,i) = [ 1  0 ];
    lines(2,i) = [ 0 -1 ];
  end
  j = xhair(1);
  k = xhair(2);
  l = xhair(3);
  if xhaircell
    lines = [ lines
      j k l   j+1 k+1 l+1
    ];
  else
    lines = [ lines
      j-1 k l   j+1 k l
      j k-1 l   j k+1 l
      j k l-1   j k l+1
    ];
  end
  lineviz
  hhud(3) = hand;
  set( hand, 'Color', 'y' );
  showframe = nframe;
end

% Message
set( gcf, 'CurrentAxes', haxes(2) )
if length( msg )
  delete( hmsg )
  hmsg = text( .98, .02, msg, 'Hor', 'right', 'Ver', 'bottom' );
  msg = '';
end
set( gcf, 'CurrentAxes', haxes(1) )
set( [ hhud hmsg hhelp ], 'HandleVisibility', 'off' )

nframe = length( frame );
if nframe > 1
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

