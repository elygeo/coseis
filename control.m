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
      'BackgroundColor', bg );
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
  if nframe
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
  end
  anim = 1;
case 'downarrow',  if km, xhairmove = -3; else xhairmove = -1; end
case 'uparrow',    if km, xhairmove = 3;  else xhairmove = 1;  end
case 'leftarrow',  xhairmove = -2;
case 'rightarrow', xhairmove = 2;
case 'quote',      xhairmove = 4;
case 'semicolon',  xhairmove = 5;
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
case 'comma',  camva( 1.25 * camva )
case 'period', camva( .8 * camva )
case 'slash'
  zoomed = ~zoomed;
  if zoomed
    j = xhair(1) + halo1(1);
    k = xhair(2) + halo1(2);
    l = xhair(3) + halo1(3);
    switch field
    case 'v'
      xg = x(j,k,l,:) + xscl * u(j,k,l,:);
    case 'w'
      xg = 0.125 * ( ( ...
        x(j,k,l,:) + x(j+1,k+1,l+1,:) + ...
        x(j+1,k,l,:) + x(j,k+1,l+1,:) + ...
        x(j,k+1,l,:) + x(j+1,k,l+1,:) + ...
        x(j,k,l+1,:) + x(j+1,k+1,l,:) ) + ...
        xscl * ( ...
        u(j,k,l,:) + u(j+1,k+1,l+1,:) + ...
        u(j+1,k,l,:) + u(j,k+1,l+1,:) + ...
        u(j,k+1,l,:) + u(j+1,k,l+1,:) + ...
        u(j,k,l+1,:) + u(j+1,k+1,l,:) ) );
    end
    camva( camva * 2 * h / xmax );
    targ = double( xg(:)' );
  else
    camva( camva / 2 / h * xmax );
    targ = double( x0(:)' );
  end
  if ~viz3d, campos( campos + targ - camtarget ), end
  camtarget( targ );
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
  if i, msg = plotstyle;
  else  msg = 'Plotting Off';
  end
case 'x'
  xlim = -~xlim;
  if xlim, msg = 'Mesh distortion on';
  else     msg = 'Mesh distortion off';
  end
case 'u', field = 'u'; colorscale; msg = titles{ comp + 1};
case 'v', field = 'v'; colorscale; msg = titles{ comp + 1};
case 'w', field = 'w'; colorscale; msg = titles{ comp + 1};
case 'm'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), domesh = ~strcmp( get( tmp(1), 'EdgeColor' ), 'none' ); end
  domesh = ~domesh;
  fg = get( 1, 'DefaultTextColor' );
  if domesh, edgecolor = fg;     msg = 'Mesh On';
  else       edgecolor = 'none'; msg = 'Mesh Off';
  end
  if length( tmp ), set( tmp, 'EdgeColor', edgecolor ), end
case 's'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'surf' );
  if length( tmp ), dosurf = strcmp( get( tmp(1), 'FaceColor' ), 'flat' ); end
  dosurf = ~dosurf;
  if dosurf, facecolor = 'flat'; msg = 'Surfaces On';
  else       facecolor = 'none'; msg = 'Surfaces Off';
  end
  if length( tmp ), set( tmp, 'FaceColor', facecolor ), end
case 'g'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'glyph' );
  if length( tmp ), doglyph = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  doglyph = ~doglyph;
  if doglyph, visible = 'on';  msg = 'Glyphs On';
  else        visible = 'off'; msg = 'Glyphs Off';
  end
  if length( tmp ), set( tmp, 'Visible', visible ), end
case 'i'
  tmp = findobj( [ frame{ showframe } ], 'Tag', 'isosurf' );
  if length( tmp ), doisosurf = strcmp( get( tmp(1), 'Visible' ), 'on' ); end
  doisosurf = ~doisosurf;
  if doisosurf, visible = 'on';  msg = 'Isosurfaces On';
  else          visible = 'off'; msg = 'Isosurfaces Off';
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

if xhairmove
  way = sign( xhairmove );
  xhairmove = abs( xhairmove );
  nc = ncore - cellfocus;
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
    if length( hhud )
      xhair(i) = xhair(i) + way;
      if xhair(i) > nc(i), xhair(i) = nc(i);
      elseif xhair(i) < 1,  xhair(i) = 1;
      end
    end
    slicedim = i;
  end
  delete( [ hhud hhelp ] )
  hhelp = [];
  j = xhair(1) + halo1(1);
  k = xhair(2) + halo1(2);
  l = xhair(3) + halo1(3);
  clear xg xga mga vga
  if cellfocus
    for i = 1:3
      xg(i) = 0.125 * ( ...
        x(j,k,l,i) + x(j+1,k+1,l+1,i) + ...
        x(j+1,k,l,i) + x(j,k+1,l+1,i) + ...
        x(j,k+1,l,i) + x(j+1,k,l+1,i) + ...
        x(j,k,l+1,i) + x(j+1,k+1,l,i) );
      xga(i) = xg(i) + 0.125 * xscl * ( ...
        u(j,k,l,i) + u(j+1,k+1,l+1,i) + ...
        u(j+1,k,l,i) + u(j,k+1,l+1,i) + ...
        u(j,k+1,l,i) + u(j+1,k,l+1,i) + ...
        u(j,k,l+1,i) + u(j+1,k+1,l,i) );
    end
  else
    xg(1:3) = x(j,k,l,:);
    xga(1:3) = x(j,k,l,:) + xscl * u(j,k,l,:);
  end
  switch field
  case 'u'
    vga(1:3) = u(j,k,l,:);
    mga = sum( u(j,k,l,:) .* u(j,k,l,:), 4 );
    msg = sprintf( '|U|%9.2e\nUx %9.2e\nUy %9.2e\nUz %9.2e', mga, vga );
  case 'v'
    vga(1:3) = v(j,k,l,:);
    mga = s1(j,k,l);
    msg = sprintf( '|V|%9.2e\nVx %9.2e\nVy %9.2e\nVz %9.2e', mga, vga );
  case 'w'
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
    msg = sprintf( '|W| %9.2e\nWxx %9.2e\nWyy %9.2e\nWzz %9.2e\nWyz %9.2e\nWzx %9.2e\nWzy %9.2e', val(3), wg );
  end
  set( gcf, 'CurrentAxes', haxes(2) )
  hhud = text( .02, .98, msg, 'Hor', 'left', 'Ver', 'top' );
  tmp = [ it j k l; it * dt xg ];
  msg = sprintf( '%4d %8.3fs\n%4d %8.1fm\n%4d %8.1fm\n%4d %8.1fm', tmp );
  hhud(2) = text( .98, .98, msg, 'Hor', 'right', 'Ver', 'top' );
  msg = '';
  set( gcf, 'CurrentAxes', haxes(1) )
  if zoomed
    targ = double( xga(:)' );
    if ~viz3d, campos( campos + targ - camtarget ), end
    camtarget( targ )
  end
  if glyph, reynoldsglyph, else, wireglyph, end
  hhud = [ hhud hand ];
  lines = [ 1 1 1  -1 -1 -1 ];
  lines(slicedim)   = xhair(slicedim);
  lines(slicedim+3) = xhair(slicedim) + cellfocus;
  if nrmdim & slicedim ~= nrmdim
    lines = [ lines; lines ];
    i = nrmdim + [ 0 3 ];
    lines(1,i) = [ 1  0 ];
    lines(2,i) = [ 0 -1 ];
  end
  lineviz
  set( hand, 'LineStyle', ':' );
  hhud(end+1) = hand;
  j = xhair(1);
  k = xhair(2);
  l = xhair(3);
  if cellfocus
    lines = [ 
      j k l   j+1 k+1 l+1
    ];
  else
    lines = [ 
      j-1 k l   j+1 k l
      j k-1 l   j k+1 l
      j k l-1   j k l+1
    ];
  end
  lines( lines == 0 ) = 1;
  lineviz
  set( hand );
  hhud(end+1) = hand;
  showframe = nframe;
  anim = 1;
end

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

