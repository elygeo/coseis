%------------------------------------------------------------------------------%
% CONTROL

running = itstep;
keypress = get( gcf, 'CurrentKey' );
km = length( get( gcf, 'CurrentMod' ) );
nframe = length( frame );
dframe = 0;
itstep = 0;
xhairmove = 0;
set( 0, 'CurrentFigure', 1 )
delete( hud ), hud = [];
msg = '';

switch keypress
case 'h', msg = {
  'pause calulations         mouse-click'
  'step/run calulations          space r'
  'plot style                          p'
  'velocity/stress glyphs            v s'
  'mesh/surfaces                     m f'
  'component                     0 1 2 3'
  'zoom in/out                       , .'
  'reset 3D/2D                       / ?'
  'crosshair                   arrow ; '''
  'replot                          enter'
  'color scale +/-/reset          [ ] \\'
  'frame +/-                    - = page'
  'delelte frame               backspace'
  'first/last frame             home end'
  'delete figure                     del'
  'write/read checkpoint             w r'
  'build movie                         b'
  'help                                h'
};
case 'home',         showframe = 1;
case 'end',          showframe = nframe;
case 'pageup',       dframe = -10;
case 'pagedown',     dframe =  10;
case 'hyphen',       dframe = -1;
case 'equal',        dframe =  1;
case 'delete',       delete( [ frame{:} ] ), frame = {};
case 'insert',       newplot = plotstyle;
case 'backspace'
  if nframe
    delete( [ frame{showframe} ] )
    frame( showframe ) = [];
  end
case 'downarrow',    if km, xhairmove = -3; else xhairmove = -1; end
case 'uparrow',      if km, xhairmove = 3;  else xhairmove = 1;  end
case 'leftarrow',    xhairmove = -2;
case 'rightarrow',   xhairmove = 2;
case 'quote',        xhairmove = 4;
case 'semicolon',    xhairmove = 5;
case 'return',       newplot = plotstyle;
case 'space', itstep = 1;         msg = 'step';
case 'r',     itstep = nt - it;   msg = 'run';
case '0',     field = 0;          msg = '|v|';
case '1',     field = 1;          msg = 'v_1';
case '2',     field = 2;          msg = 'v_2';
case '3',     field = 3;          msg = 'v_3';
case 'comma',  camva( 1.25 * camva )
case 'period', camva( .8 * camva )
case 'slash', if km, look = 5; else look = 4; end, lookat
case 'leftbracket', tmp = 1.25 * get( gca, 'CLim' ); set( gca, 'CLim', tmp )
  msg = sprintf( 'clim = %g %g', tmp );
case 'rightbracket', tmp = 0.8 * get( gca, 'CLim' ); set( gca, 'CLim', tmp )
  msg = sprintf( 'clim = %g %g', tmp );
case 'backslash', set( gca, 'CLim', clim )
  msg = sprintf( 'clim = %g %g', clim );
case 'p'
  tmp = { '', 'outline', 'cube', 'isosurfaces', 'slice' };
  for i = 1:length( tmp )
    if strcmp( plotstyle, tmp{i} ), break, end
  end
  if i >= length( tmp )
    plotstyle = '';
    msg = 'plotting off';
  else
    plotstyle = tmp{i+1};
    msg = [ 'plotstyle: ' plotstyle ];
  end
case 'm'
  tmp = findobj( [ frame{ showframe } ], 'Type', 'surface' );
  if length( tmp ), edgecolor = get( tmp(1), 'EdgeColor' ); end
  if strcmp( edgecolor, 'none' ),
    edgecolor = get( 0, 'DefaultTextColor' );
  else
    edgecolor = 'none';
  end
  keyboard
  set( tmp, 'EdgeColor', edgecolor )
  msg = [ 'edgecolor = ' edgecolor ];
case 'f'
  tmp = findobj( [ frame{ showframe } ], 'Type', 'surface' );
  if length( tmp ), facecolor = get( tmp(1), 'FaceColor' ); end
  if strcmp( facecolor, 'none' ),
    facecolor = 'flat';
  else
    facecolor = 'none';
  end
  set( tmp, 'FaceColor', facecolor )
  msg = [ 'facecolor = ' facecolor ];
case 'v'
  if vglyph, vglyph = 0;      msg = 'vectors off';
  else       vglyph = 1 + km; msg = 'vectors on';
  end
case 's'
  switch Sglyph
  case '',          Sglyph = 'axes';      msg = 'stress axes';
  case 'axes',      Sglyph = 'ellipsoid'; msg = 'stress ellipsoids';
  case 'ellipsoid', Sglyph = 'reynolds';  msg = 'Reynolds stress glyphs';
  otherwise,        Sglyph = '';          msg = 'stress glyphs off';
  end
case 'w'
    save checkpoint it slip u v vv trup
    set( 1, 'UserData', nframe )
    for i = 1:nframe
      set( [ frame{i} ], 'UserData', i )
    end
    saveas( 1, 'checkpoint' )
    msg = 'checkpoint saved';
case 'r'
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
case 'b'
  if savemovie && ~holdmovie
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
  way = sign( xhairmove );
  xhairmove = abs( xhairmove );
  oc = core(1:2:5) - 1;
  nc = core(2:2:6) - oc;
  if xhairmove == 4
    xhair = hypocenter - oc;
    if nrmdim, slicedim = nrmdim; end
  elseif xhairmove == 5
    xhair = hypocenter - oc;
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
    slicedim = abs( xhairmove );
    i = slicedim;
    xhair(i) = xhair(i) + way;
    if xhair(i) > nc(i), xhair(i) = nc(i);
    elseif xhair(i) < 1,  xhair(i) = 1;
    end
  end
  j = xhair(1);
  k = xhair(2);
  l = xhair(3);
  tmp = [ j k l
          squeeze( x(j,k,l,:) )'
          squeeze( u(j,k,l,:) )'
          squeeze( v(j,k,l,:) )' ];
  msg = { '   i        x         u         v' };
  for i = 1:3
    msg{end+1} = sprintf( '%4d %8g %9.2e %9.2e', tmp(:,i) );
  end
  msg{end+1} = sprintf( '         peak %9.2e %9.2e', umax, vmax );
  lines = [ 1 -1   1 -1   1 -1 ];
  i = 2 * slicedim - [ 1 0 ];
  lines(i) = xhair(slicedim);
  if nrmdim & slicedim ~= nrmdim
    lines = [ lines; lines ];
    i = 2 * nrmdim - [ 1 0 ];
    lines(:,i) = [ 1 0; 0 -1 ];
  end
  lines = [ lines
    j-1 j+1  k k  l l
    j j  k-1 k+1  l l
    j j  k k  l-1 l+1
  ];
  tmp = [];
  for iz = 1:size( lines, 1 )
    zone = lines(iz,:);
    tmp = [ tmp; zone( linesi ) ];
  end
  lines  = unique( tmp, 'rows' );
  for i = 1:3
    xpa{i} = [];
  end
  for iz = 1:size( lines, 1 )
    [ i1, i2 ] = zoneselect( lines(iz,:), 0, core, hypocenter, nrmdim );
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    for i = 1:3
      tmp = squeeze( x(j,k,l,i) + uscl * u(j,k,l,i) );
      xpa{i} = [ xpa{i}; tmp(:); NaN ];
    end
  end
  hud(end+1) = plot3( xpa{1}, xpa{2}, xpa{3}, 'Color', 'y' );
  set( hud, 'Color', 'y' )
  showframe = nframe;
end

% Message
set( gcf, 'CurrentAxes', haxes(2) )
if ischar( msg ), msg = { msg }; end
if length( msg ) > 10;
  hud(end+1) = text( .5, .5, msg, 'Color', 'y', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'Margin', 10, ...
    'BackgroundColor', bg );
elseif length( msg ) > 0
  hud(end+1) = text( .03, .03, msg, 'Color', 'y', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', bg );
end
set( gcf, 'CurrentAxes', haxes(1) )
set( hud, 'HandleVisibility', 'off' )
msg = '';

nframe = length( frame );
if nframe
  showframe = showframe + dframe;
  showframe = max( showframe, 1 );
  showframe = min( showframe, nframe );
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{showframe} ], 'Visible', 'on' )
end

drawnow

if newplot, viz, end
if itstep && ~running, step, end

