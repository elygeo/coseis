%------------------------------------------------------------------------------%
% VIZ
% TODO
% restart capable
% deleting out of sync w/ file out
% cell selector
% backward time
% rearange frames, insert anywhere.
% initial plot: mesh, prestress, hypo
%'keypress = get( gcf, ''CurrentKey'' );, keypressmod = length( get( gcf, ''CurrentMod'' ) );', ...

if initialize
  disp( 'Initialize viz' )
  dark = 1;
  if dark, fg = [ 1 1 1 ]; bg = [ 0 0 0 ]; linewidth = 1;
  else     fg = [ 0 0 0 ]; bg = [ 1 1 1 ]; linewidth = 2;
  end
  set( 0, ...
    'DefaultFigureKeyPressFcn', ...
    'control', ...
    'DefaultFigureColor', bg, ...
    'DefaultAxesColor', bg, ...
    'DefaultAxesColorOrder', fg, ...
    'DefaultLineColor', fg, ...
    'DefaultAxesXColor', fg, ...
    'DefaultAxesYColor', fg, ...
    'DefaultAxesZColor', fg, ...
    'DefaultTextColor', fg, ...
    'DefaultLineLinewidth', linewidth, ...
    'DefaultTextFontName', 'FixedWidth', ...
    'DefaultTextFontSize', 14 )
  if ~ishandle(1), figure(1), end
  set( 0, 'CurrentFigure', 1 )
  clf
  %set( 1, 'InvertHardCopy', 'off' )
  haxes(1) = axes; axis off
  haxes(2) = axes; axis off
  set( haxes(2), 'DefaultTextVerticalAlignment', 'cap' )
  set( 1, 'CurrentAxes', haxes(1) )
  cameramenu
  cameratoolbar
  cameratoolbar( 'SetMode', 'orbit' )
  cameratoolbar( 'SetCoordSys', 'x' )
  cameratoolbar( 'ToggleSceneLight' );
  if ~exist( 'out/viz', 'dir' ), mkdir out/viz, end
  hud = [];
  look = -4;
  % Saved data
  if nrmdim, slicedim = nrmdim; else slicedim = 3; end
  xhair = hypocenter - halo;
  stereoangle = 4; % > 0 wall-eyed, < 0 cross-eyed
  stereoangle = 0; % > 0 wall-eyed, < 0 cross-eyed
  right = [];
  ftcam = [];
  itpause = nt;
  count = 0;
  frame = {};
  showframe = 0;
  loopmovie = 0;
  vglyph = 0;
  Sglyph = '';
  facecolor = 'flat';
  edgecolor = 'none';
  return
end

set( 0, 'CurrentFigure', 1 )
plotinterval = 1;
savemovie = 1;
holdmovie = 1;
vlim = -1;
ulim = -1;
ulim = 0;
Slim = -1;
Lscl = 0;

if ~newplot
  if ~mod( it, plotinterval )
    newplot = plotstyle;
  else
    return
  end
end

play    = 0;
vcut    = .3;
Scut    = .3;
vexp    = 1;
Sexp    = .5;
visoval = [ .1 .5 ];
cmap = [];

linesi = [
  1 2  3 3  5 5
  1 2  3 3  6 6
  1 2  4 4  5 5
  1 2  4 4  6 6
  1 1  3 4  5 5
  2 2  3 4  5 5
  1 1  3 4  6 6
  2 2  3 4  6 6
  1 1  3 3  5 6
  1 1  4 4  5 6
  2 2  3 3  5 6
  2 2  4 4  5 6
];
planesi = [
  1 1  3 4  5 6
  2 2  3 4  5 6
  1 2  3 3  5 6
  1 2  4 4  5 6
  1 2  3 4  5 5
  1 2  3 4  6 6
];

i = xhair;
c = hypocenter;
visosurfs = [];
lines = [ 1 -1   1 -1   1 -1 ];
if nrmdim
  lines = [ lines; lines ];
  i = 2 * nrmdim - [ 1 0 ];
  lines(:,i) = [ 1 0; 0 -1 ]
end
Sglyphs = lines;
vglyphs = lines;
vplanes = [];

switch newplot
case 'initial'
case 'outline'
case 'cube', vplanes = lines;
case 'isosurfaces', visosurfs = lines;
case 'slice'
  vcut = .001;
  vplanes = [ 1 -1   1 -1   1 -1 ];
  i = 2 * slicedim - [ 1 0 ];
  vplanes(i) = xhair(slicedim);
  if nrmdim & slicedim ~= nrmdim
    vplanes = [ vplanes; vplanes ];
    i = 2 * nrmdim - [ 1 0 ];
    lines(:,i) = [ 1 0; 0 -1 ];
  else
  end
  lines = [ lines; vplanes ];
  vglyphs = vplanes;
  Sglyphs = vplanes;
end
if strcmp( Sglyph, 'ellipsoid' ) | strcmp( Sglyph, 'reynolds' )
  vplanes = [];
end
tmp = [];
for iz = 1:size( lines, 1 )
  zone = lines(iz,:);
  tmp = [ tmp; zone( linesi ) ];
end
lines  = unique( tmp,  'rows' );
tmp = [];
for iz = 1:size( vplanes, 1 )
  zone = vplanes(iz,:);
  tmp = [ tmp; zone( planesi ) ];
end
vplanes = unique( tmp, 'rows' );

% One time stuff
delete( hud )
hud = [];
if holdmovie
  set( [ frame{:} ], 'Visible', 'off' )
  set( [ frame{:} ], 'HandleVisibility', 'off' )
else
  delete( [ frame{:} ] )
  frame = { [] };
end
vscl = vlim;
uscl = ulim;
Sscl = Slim;
if vlim < 0, vscl = vmax; end
if ulim < 0, uscl = umax; end
if Slim < 0, Sscl = Smax; end
visoval = vscl * visoval;
vcut    = vscl * vcut;
Scut    = Sscl * Scut;
if uscl, uscl = h / 2 / uscl; end
if vscl, vscl = 1 / vscl; end
if Sscl, Sscl = 1 / Sscl; end
if ~Lscl, Lscl = L; end

% V planes
xpa = [];
vpa = [];
mpa = [];
for iz = 1:size( vplanes, 1 )
  [ i1, i2 ] = zoneselect( vplanes(iz,:), 0, n, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  np = i2 - i1 + 1;
  if sum( np > 1 ) == 2
    for i = 1:3
      xp{i} = squeeze( x(j,k,l,i) + uscl * u(j,k,l,i) ); 
    end
    if field
      vp = squeeze( v(j,k,l,field) ); 
      clim = [ -1 1 ];
      if dark
        cmap = [
        -8 -4 -2  0  2  4  8
         0  0  0  0  8  8  8
         8  4  0  0  0  4  8
         8  8  8  0  0  0  0 ]' / 8;
      else
        cmap = [
        -8 -6 -4 -2  0  2  4  6  8
         0  2  2  2  8  8  8  8  4
         4  8  8  2  8  2  6  8  2
         0  2  8  8  8  2  2  2  0 ]' / 8;
      end
    else
      mp = sum( v(j,k,l,:) .* v(j,k,l,:), 4 );
      vp = squeeze( sqrt( mp ) );
      clim = [ 0 1 ];
      if dark
        cmap = [
         0 .5  2  4  6  8
         0  0  0  8  8  8
         0  0  8  8  0  0
         0  8  8  0  0  8]' / 8;
      else
        cmap = [
         0 .5  2  4  6  8
         8  2  2  8  8  4
         8  2  8  8  2  0
         8  8  8  2  2  0]' / 8;
      end
    end
    if vscl, clim = clim ./ vscl; end
    np = size( vp );
    vpc = .25 * ( ...
      vp(1:end-1,1:end-1) + vp(2:end,1:end-1) + ...
      vp(1:end-1,2:end)   + vp(2:end,2:end) ); 
    surf( xp{1}, xp{2}, xp{3}, double( vpc ), ...
      'FaceColor', facecolor, ...
      'EdgeColor', edgecolor, ...
      'LineWidth', linewidth / 4, ...
      'FaceLighting', 'none' );
    hold on
  end
  clear i j k l ii jj kk ll mp xp vp np
end

% V isosurfs
for iz = 1:size( visosurfs, 1 )
  [ i1, i2 ] = zoneselect( visosurfs(iz,:), 0, n, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  np = i2 - i1 + 1;
  if sum( np > 1 ) < 3, error( 'bad volume' ), end
  for i = 1:3
    xp{i} = x(j,k,l,i) + uscl * u(j,k,l,i); 
    xp{i} = permute( xp{i}, [2 1 3] );
  end
  if field
    vp = v(j,k,l,field); 
  else
    vp = sum( v(j,k,l,:) .* v(j,k,l,:), 4 );
    vp = sqrt( vp );
  end
  vp = permute( vp, [2 1 3] );
  color  = [  0  1  1  1
              0  1  1  0
              1  1  1  0 ];
  isoval = [ -visoval( [ 2 1 ] ) visoval ];
  alpha  = [  8  1  1  8 ] / 8;
  for i = 1:length( isoval );
    fv = isosurface( xp{1}, xp{2}, xp{3}, ...
      sign( isoval(i) ) * vp, abs( isoval(i) ) );
    if ~isempty( fv.vertices )
      patch( fv, ...
        'FaceColor', color(:,i), ...
        'FaceAlpha', alpha(i), ...
        'FaceLighting', 'phong', ...
        'AmbientStrength',  .3, ...
        'DiffuseStrength',  .6, ...
        'SpecularStrength', .9, ...
        'BackFaceLighting', 'unlit', ...
        'EdgeColor', 'none' )
    end
  end
  clear ii i j k l o np xp vp color isoval alpha fv
end

% V glyphs
if vglyph
for iz = 1:size( vglyphs, 1 )
  [ i1, i2 ] = zoneselect( vglyphs(iz,:), 0, n, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  o = i1 - 1;
  mp = sum( v(j,k,l,:) .* v(j,k,l,:), 4 );
  ii = find( mp > vcut * vcut );
  if ii
    [ jj, kk, ll ] = ind2sub( size( mp ), ii );
    jj = repmat( jj, [ 1 3 ] ) + o(1);
    kk = repmat( kk, [ 1 3 ] ) + o(2);
    ll = repmat( ll, [ 1 3 ] ) + o(3);
    c = repmat( 1:3, size( ii ) );
    i = sub2ind( size( x ), jj, kk, ll, c );
    xpa = [ xpa; x(i) + uscl * u(i) ];
    vpa = [ vpa; v(i) ];
    mpa = [ mpa; mp(ii) ];
  end
end
ni = size( vpa, 1 );
if ni
  scl = 0.5 * h * vscl ^ vexp;
  for i = 1:3
    vpa(:,i) = scl * vpa(:,i) .* mpa .^ ( vexp - 1 );
    xp{i} = [ xpa(:,i) - vpa(:,i) xpa(:,i) + vpa(:,i) ...
              repmat( NaN, ni, 1 ) ]';
  end
  plot3( xp{1}(:), xp{2}(:), xp{3}(:) );
  hold on
  for i = 1:3
    xp{i} = [ xpa(:,i) + .5 * vpa(:,i) xpa(:,i) + .75 * vpa(:,i) ...
              repmat( NaN, ni, 1 ) ]';
  end
  linewidth = get( 0, 'DefaultLineLineWidth' );
  plot3( xp{1}(:), xp{2}(:), xp{3}(:), 'LineWidth', 2 * linewidth );
end
clear ni scl i xpa vpa xp
end

% S glyphs
if Sglyph
xpa = [];
mpa = [];
vpa = [];
m = 16;
[ xp{1}, xp{2}, xp{3} ] = sphere( m );
sphr = [ xp{1}(:) xp{2}(:) xp{3}(:) ]';
for iz = 1:size( Sglyphs, 1 )
  [ i1, i2 ] = zoneselect( Sglyphs(iz,:), 0, n, hypocenter, nrmdim );
  i2 = i2 - 1;
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  o = i1 - 1;
  mp = S(j,k,l,:) .* S(j,k,l,:);
  mp(:,:,:,4:6) = mp(:,:,:,4:6) + mp(:,:,:,4:6);
  mp = sum( mp, 4 );
  ii = find( mp > Scut * Scut );
  for ii = ii(:)'
    [ j, k, l ] = ind2sub( size( mp ), ii );
    jj = j + o(1) + zeros( 3 );
    kk = k + o(2) + zeros( 3 );
    ll = l + o(3) + zeros( 3 );
    c = [ 1 6 5; 6 2 4; 5 4 3 ];
    i = sub2ind( size( S ), jj, kk, ll, c );
    Sp = S(i);
    jj = j + o(1) + repmat( [ 0 1 0 1 0 1 0 1 ]', [ 1 3 ] );
    kk = k + o(2) + repmat( [ 0 0 1 1 0 0 1 1 ]', [ 1 3 ] );
    ll = l + o(3) + repmat( [ 0 0 0 0 1 1 1 1 ]', [ 1 3 ] );
    c = repmat( 1:3, [ 8 1 ] );
    i = sub2ind( size( x ), jj, kk, ll, c );
    xp = x(i) + uscl * u(i);
    xp = 0.125 * sum( xp, 1 );
    [ vec, val ] = eig( Sp );
    val = diag( val );
    [ tmp, i ] = sort( abs( val ) );
    val = val(i)';
    vec = vec(:,i);
    xpa = [ xpa; xp ];
    mpa = [ mpa; val ];
    vpa = [ vpa; vec(:)' ];
  end
end
clear o i j k l ii jj kk ll xp mp Sp vec val
switch Sglyph
case 'axes'
  if ~isempty( vpa )
    scl = 0.5 * h * Sscl ^ Sexp;
    for ii = 1:3
      ig = find( mpa(:,ii) > 0 );
      ng = size( ig, 1 );
      for i = 1:3
	vp = scl * vpa(ig,(i-1)*3+ii) .* abs( mpa(ig,i) ) .^ Sexp;
	xp{i} = [ xpa(ig,i) - vp xpa(a,i) + vp repmat( NaN, ng, 1 ) ]';
      end
      plot3( xp{1}(:), xp{2}(:), xp{3}(:), 'm' );
      hold on
      a = find( mpa(:,ii) < 0 );
      ng = size( a, 1 );
      for i = 1:3
	vp = scl * vpa(ig,(i-1)*3+ii) .* abs( mpa(ig,i) ) .^ Sexp;
	xp{i} = [ xpa(ig,i) - vp xpa(ig,i) + vp repmat( NaN, ng, 1 ) ]';
      end
      plot3( xp{1}(:), xp{2}(:), xp{3}(:), 'c' );
    end
    clear scl ii ig ng vp xp
  end
case { 'ellipsoid', 'reynolds' }
  for ig = 1:size( vpa, 1 )
    cmap = [ -1 0 0 1; 0 1 0 1; 1 1 0 0 ];
    clim = .5 / Sscl * [-1 1];
    val = mpa(ig,:);
    vec = reshape( vpa(ig,:), [3 3] );
    vec(:,1) = cross( vec(:,2), vec(:,3) );
    scl = 0.5 * h * Sscl ^ Sexp * abs( val(3) ) ^ (Sexp-1);
    rr = val * ( sphr .* sphr );
    if strcmp( Sglyph, 'ellipsoid' )
      glyph = scl * vec * diag( abs( val ) ) * sphr;
    else
      glyph = scl * vec * ( repmat( rr, [ 3 1 ] ) .* sphr );
    end
    glyph = reshape( glyph, [ 3 m+1 m+1 ] );
    color = reshape( rr, [ m+1 m+1 ] );
    i = 1:m;
    color(i,i) = 0.25 * ( color(i,i)   + color(i+1,i) ...
                        + color(i,i+1) + color(i+1,i+1) );
    for i = 1:3
      xp{i} = glyph(i,:,:) + xpa(ig,i);
      xp{i} = shiftdim( xp{i}, 1 );
    end
    j0 = [ m 1:m ];
    j1 =   1:m+1;
    j2 = [ 2:m+1 2 ];
    vec1 = glyph(:,:,j0) - glyph(:,:,j2);
    vec2 = glyph(:,j0,:) - glyph(:,j2,:);
    m4 = floor( m / 4 );
    for i = 1:3
      vec1(i,1,:)   = glyph(i,2,m4+1)     - glyph(i,2,3*m4+1);
      vec2(i,1,:)   = glyph(i,2,1)        - glyph(i,2,2*m4+1);
      vec2(i,end,:) = glyph(i,end-1,m4+1) - glyph(i,end-1,3*m4+1);
      vec1(i,end,:) = glyph(i,end-1,1)    - glyph(i,end-1,2*m4+1);
    end
    vn(1,j1,j1) = vec1(2,:,:) .* vec2(3,:,:) - vec1(3,:,:) .* vec2(2,:,:);
    vn(2,j1,j1) = vec1(3,:,:) .* vec2(1,:,:) - vec1(1,:,:) .* vec2(3,:,:);
    vn(3,j1,j1) = vec1(1,:,:) .* vec2(2,:,:) - vec1(2,:,:) .* vec2(1,:,:);
    surf( xp{1}, xp{2}, xp{3}, double( color ), ...
      'VertexNormals', shiftdim( vn, 1 ), ...
      'BackFaceLighting', 'reverselit', ...
      'AmbientStrength', .6, ...
      'DiffuseStrength', .6, ...
      'SpecularStrength', .9, ...
      'SpecularExponent', 10, ...
      'FaceLighting', 'gouraud', ...
      'EdgeColor', 'none', ...
      'FaceColor', 'flat' )
    hold on
  end
end
end

% Lines
xpa = { [] [] [] };
for iz = 1:size( lines, 1 )
  [ i1, i2 ] = zoneselect( lines(iz,:), 0, n, hypocenter, nrmdim );
  j = i1(1):i2(1);
  k = i1(2):i2(2);
  l = i1(3):i2(3);
  np = i2 - i1 + 1;
  if sum( np > 1 ) == 1
    for i = 1:3
      tmp = squeeze( x(j,k,l,i) + uscl * u(j,k,l,i) );
      xpa{i} = [ xpa{i}; tmp(:); NaN ];
    end
  end
end
if ~isempty( xpa{1} )
  plot3( xpa{1}, xpa{2}, xpa{3} )
  hold on
end
xp = { [] [] [] };
if nrmdim
  j = 2:n(1)-1;
  k = 2:n(2)-1;
  l = hypocenter(3)+1;
  clear xp vp
  for i = 1:3
    xp{i} = squeeze( x(j,k,l,i) + uscl * u(j,k,l,i) ); 
  end
  if rcrit
    hh = scontour( xp{1}, xp{2}, xp{3}, r(j,k), min( rcrit, it * dt * vrup ) );
    set( hh, 'LineStyle', ':' );
    if nclramp
      hh = scontour( xp{1}, xp{2}, xp{3}, r(j,k), min( rcrit, ( it - nclramp ) * dt * vrup ) );
      set( hh, 'LineStyle', ':' );
    end
  end
  scontour( xp{1}, xp{2}, xp{3}, slip(j,k), Dc0 );
  scontour( xp{1}, xp{2}, xp{3}, slip(j,k), .01 * Dc0 );
  switch model
  case { 'the2', 'the3' }
    scontour( xp{1}, xp{2}, xp{3}, fd(j,k), 10 );
  end
  clear xp
end

if length( cmap );
  colormap( interp1( cmap(:,1), cmap(:,2:4), cmap(1,1) : ( cmap(end,1) - cmap(1,1) ) / 1000 : cmap(end,1) ) );
  set( gca, 'CLim', clim );
end
axis off
set( gca, 'Position', [ 0 0 1 1 ] )

% Title
set( gcf, 'CurrentAxes', haxes(2) )
set( gca, 'Position', [ 0 0 1 1 ] );
text( .03, .97, sprintf( '%.3fs', it * dt ) )
hold on
axis off;
if ~isempty( vplanes ) && ~strcmp( facecolor, 'none' ) && false
  titles = { '|v|' 'v_x' 'v_y' 'v_z' };
  xp = [ 0 .2 .8  1 ];
  yp = [ .03 .06 .09 .12 ];
  patch( [ 0 0 1 1 ], [ 0 yp(4) yp(4) 0 ], bg )
  imagesc( xp, yp(2:3), [ 1:1000; 1:1000 ] )
  text( xp(1), yp(1), sprintf( '%g', clim(1) ) )
  text( xp(2), yp(1), sprintf( '%gm/s', clim(2) ) )
  text( ( xp(1) + xp(2) ) / 2, yp(1), titles( field + 1 ) )
end
set( gcf, 'CurrentAxes', haxes(1) )

% Save frame
kids = get( haxes, 'Children' );
kids = [ kids{1}; kids{2} ]';
frame{end+1} = kids;
showframe = length( frame );
newplot = '';
clear xp vp xpa vpa

% hardcopy
if ~holdmovie && savemovie
  count = count + 1;
  file = sprintf( 'out/viz/%05d', count );
  saveas( gcf, file )
end

drawnow

%------------------------------------------------------------------------------%

% Misc plots
if it >= 0;
  switch model
  case 'kostrov'
    [ i1, i2 ] = zoneselect( [ 0 0   0 -1   0 0 ], 0, n, hypocenter, nrmdim );
    j  = i1(1):i2(1);
    k  = i1(2):i2(2);
    l  = i1(3):i2(3);
    np = max( [ length(j) length(k) length(l) ] );
    xp = squeeze( x(j,k,l,:) );
    xp = ( xp(2:end,:) - xp(1:end-1,:) ) .^ 2;
    xp = [ 0; cumsum( sqrt( sum( xp, 2 ) ) ) ];
    l  = 1;
    sliputs(nt,np) = 0;
    sliputs(it,:) = squeeze( slip(j,k,l) );
    slipvts(nt,np) = 0;
    slipvts(it,:) = squeeze( slipv(j,k,l) );
    C  = .81;
    dT = Ts0 - fd0 * Tn0;
    vp = sqrt( ( lam0 + 2 * miu0 ) / rho );
    fcorner = vp / ( 6 * h );
    nn = 2 * round( 1 / ( fcorner * dt ) );
    b = hanning( nn );
    a = sum( b );
    vp = filter( b, a, slipvts );

    if ~ishandle(3), figure(3), end
    set( 0, 'CurrentFigure', 3 )
    clf
    t = ( 1 : nt )' * dt;
    di = max( 1, round( np / 6 ) );
    for i = di:di:np
      kostrov = C * dT / miu0 * vs * t ./ sqrt( t .^ 2 - ( xp(i) / vrup ) .^ 2 ) .* heaviside( t - xp(i) / vrup );
      kostrov = filter( b, a, kostrov );
      plot( t, vp(:,i) )
      hold on
      plot( t, kostrov, ':' )
    end
    xlabel( 'Time (s)' )
    ylabel( 'Slip Velocity (m/s)' )

    if ~ishandle(4), figure(4), end
    set( 0, 'CurrentFigure', 4 )
    clf
    imagesc( t, xp, double( vp' ) );
    hold on
    plot( [ 0 rcrit/vrup t(end) ], [ 0 rcrit rcrit ], ':' );
    if nclramp
    plot( [ 0 rcrit/vrup t(end) ] + nclramp * dt, [ 0 rcrit rcrit ], ':' );
    end
    contour( t, xp, sliputs', Dc0 * [ 1 1 ], fg );
    contour( t, xp, sliputs', .01 * Dc0 * [ 1 1 ], fg );
    title( 'Slip Velocity (m/s)' )
    xlabel( 'Time (s)' )
    ylabel( 'Distance (m)' )
    axis xy
    shading flat
    if dark
      cmap = [
       0 .5  2  4  6  8
       0  0  0  8  8  8
       0  0  8  8  0  0
       0  8  8  0  0  8]' / 8;
    else
      cmap = [
       0 .5  2  4  6  8
       8  2  2  8  8  4
       8  2  8  8  2  0
       8  8  8  2  2  0]' / 8;
    end
    clim = [ 0 1 ] * max( vp(:) );
    colormap( interp1( cmap(:,1), cmap(:,2:4), cmap(1,1) : ( cmap(end,1) - cmap(1,1) ) / 1000 : cmap(end,1) ) );
    set( gca, 'CLim', clim );
  end
  if srcgeom
    if ~ishandle(3), figure(3), end
    set( 0, 'CurrentFigure', 3 )
    clf
    t = ( 0 : nt-1 ) * dt;
    plot( t, source, ':k' )
    hold on
    plot( t(1:it), source(1:it), 'r', 'LineWidth', 2 );
    title('Source time function')
  end
end

return
%------------------------------------------------------------------------------%

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
ppi = 80;
filtersize = 3;
file = sprintf( 'out/viz/%05d', count );
print( '-dpng', sprintf( '-r%g', ppi * filtersize ), file )
if filtersize ~= 1
  img = imread( file, 'png' );
  nn  = floor( size( img ) / filtersize )
  img = imresize( img, nn(1:2), 'bilinear' );
  imwrite( img, file, 'png' )
end

