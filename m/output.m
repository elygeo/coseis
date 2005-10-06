%------------------------------------------------------------------------------%
% Output

if init
  init = 0;
  fprintf( 'Initialize output\n' )
  s1(:) = 0.;
  s2(:) = 0.;
  w1(:) = 0.;
  w2(:) = 0.;
  if itcheck < 0, itcheck = nt + itcheck + 1; end
  if exist( 'out/ckp.mat', 'file' )
    load 'out/ckp'
    if any( size( mr ) ~= nm ), error 'Checkpoint', end
    fprintf( 'Checkpoint found, starting from step %g\n', it )
  else
    if exist( 'out', 'dir' ), error 'Previous run exists', end
    mkdir( 'out/stats/' )
    for iz = 1:size( ditout, 1 )
      file = sprintf( 'out/%02d/', iz );
      mkdir( file )
    end
  end
  [ tmp1, tmp2, endian ] = computer;
  fid = fopen( 'out/endian', 'w' );
  fprintf( fid, '%s\n', endian );
  fclose( fid );
  courant = dt * matmax(2) * sqrt( 3 ) / dx;
  fid = fopen( 'out/meta.m', 'w' );
  fprintf( fid, '  endian = ''%s''; % byte order\n',             endian );
  fprintf( fid, '  nout = %g; % number output zones\n',          nout );
  fprintf( fid, '  rho1 = %g; % minimum density\n',              rho1 );
  fprintf( fid, '  rho2 = %g; % maximum density\n',              rho2 );
  fprintf( fid, '  rho  = %g; % hypocenter density\n',           rho );
  fprintf( fid, '  vp1  = %g; % minimum Vp\n',                   vp1 );
  fprintf( fid, '  vp2  = %g; % maximum Vp\n',                   vp2 );
  fprintf( fid, '  vp   = %g; % hypocenter Vp\n',                vp );
  fprintf( fid, '  vs1  = %g; % minimum Vs\n',                   vs1 );
  fprintf( fid, '  vs2  = %g; % maximum Vs\n',                   vs2 );
  fprintf( fid, '  vs   = %g; % hypocenter Vs\n',                vs );
  fprintf( fid, '  courant = %g; % stability condition\n',       courant );
  fprintf( fid, '  ihypo = [%g %g %g]; % hypocenter node\n',     ihypo );
  fprintf( fid, '  xhypo = [%g %g %g]; % hypocenter location\n', xhypo );
  fclose( fid );
  mem = whos;
  mem = sum( [ mem.bytes ] );
  ram = mem / 1024 ^ 2;
  wt = mem / 7000000;
  fprintf( 'RAM usage: %.0fMb\n', ram )
  fprintf( 'Run time: at least %s\n', datestr( nt * wt / 3600 / 24, 13 ) )
  fprintf('   Step      Amax        Vmax        Umax        Wall Time\n')
  tic
  return
end

% Magnitudes
if ( pass == 'w' ) then
  s1 = sqrt( sum( u .* u, 4 ) );
  s2 = sqrt( sum( w1 .* w1, 4 ) + 2 * sum( w2 .* w2, 4 ) );
  [ umax, umaxi ] = max( s1(:) );
  [ wmax, wmaxi ] = max( s2(:) );
  if umax > dx / 10., fprintf( 'Warning: u !<< dx\n' ), end
else
  s1 = sqrt( sum( w1 .* w1, 4 ) );
  s2 = sqrt( sum( v .* v, 4 ) );
  [ amax, amaxi ] = max( s1(:) );
  [ vmax, vmaxi ] = max( s2(:) );
  [ slmax, slmaxi ] = max( abs( sl(:) ) );
  [ svmax, svmaxi ] = max( abs( sv(:) ) );
end

for iz = 1:size( ditout, 1 )

if ditout(iz) < 0, ditout(iz) = ditout(iz) + nt + 1; end
if ~ditout(iz) | mod( it, ditout(iz) ), continue, end
nc = 1;
onpass = 'v';
cell = 0;
isfault = 0;
static = 0;
switch fieldout{iz}
case 'x',    static = 1; nc = 3;
case 'a',    nc = 3;
case 'v',    nc = 3;
case 'u',    onpass = 'w'; nc = 3;
case 'w',    onpass = 'w'; nc = 6; cell = 1;
case 'am'
case 'vm'
case 'um',   onpass = 'w';
case 'wm',   onpass = 'w'; cell = 1;
case 'sl',   isfault = 1;
case 'sv',   isfault = 1;
case 'trup', isfault = 1;
otherwise error( [ 'fieldout: ' fieldout{iz} ] )
end
if isfault & ~ifn; ditout(iz) = 0; end
if onpass ~= pass, continue, end
[ i1, i2 ] = zone( i1out(iz,:), i2out(iz,:), nn, nnoff, ihypo, ifn );
if cell; i2 = i2 - 1; end

% Metadata
file = sprintf( 'out/%02d/meta.m', iz );
fid = fopen( file, 'w' );
fprintf( fid, '  field = ''%s''; % varial name\n',   outfield{iz} );
fprintf( fid, '  nc  = %g; % # of components\n',     nc );
fprintf( fid, '  dit = %g; % interval\n',            ditout(iz) );
fprintf( fid, '  i1  = [%g %g %g]; % start index\n', i1 - nnoff );
fprintf( fid, '  i2  = [%g %g %g]; % end index\n',   i2 - nnoff );
fclose( fid );

if isfault
  i1(ifn) = 1;
  i2(ifn) = 1;
end

% Binary output
l = i1(3):i2(3);
k = i1(2):i2(2);
j = i1(1):i2(1);
for i = 1:nc
  file = sprintf( 'out/%02d/%s%1d%06d', iz, fieldout{iz}, i, it );
  fid = fopen( file, 'w' );
  switch fieldout{iz}
  case 'x',    fwrite( fid, x(j,k,l,i),    'float32' );
  case 'a',    fwrite( fid, w1(j,k,l,i),   'float32' );
  case 'v',    fwrite( fid, v(j,k,l,i),    'float32' );
  case 'u',    fwrite( fid, u(j,k,l,i),    'float32' );            
  case 'w'
    if i < 4,  fwrite( fid, w1(j,k,l,i),   'float32' ); end
    if i > 3,  fwrite( fid, w2(j,k,l,i-3), 'float32' ); end
  case 'am',   fwrite( fid, s1(j,k,l),     'float32' );
  case 'vm',   fwrite( fid, s2(j,k,l),     'float32' );
  case 'um',   fwrite( fid, s1(j,k,l),     'float32' );
  case 'wm',   fwrite( fid, s2(j,k,l),     'float32' );
  case 'sv',   fwrite( fid, sv(j,k,l),     'float32' );
  case 'sl',   fwrite( fid, sl(j,k,l),     'float32' );
  case 'trup', fwrite( fid, trup(j,k,l),   'float32' );
  otherwise error( [ 'fieldout: ' fieldout{iz} ] )
  end
  fclose( fid );
  if static, ditout(iz) = 0; end
end

end

if pass == 'w', return, end

%------------------------------------------------------------------------------%

if itcheck & ~mod( it, itcheck )
  save 'out/ckp' it t u v p1 p2 p3 p4 p5 p6 g1 g2 g3 g4 g5 g6 sv sl trup
end

fid = fopen( 'out/timestep', 'w' );
fprintf( fid, '  it = %g;\n', it );
fclose( fid );

wt = toc; tic

file = sprintf( 'out/stats/%06d', it );
fid = fopen( file, 'w' );
fprintf( fid, '%15.7e', [ t amax vmax umax wmax wt ] );
fprintf( fid, '\n' );
fclose( fid );

fprintf( '%12.4e', [ t amax vmax umax wt(1:2) + wt(3:4) ] )
fprintf( '\n' )

