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
  mem = whos;
  mem = sum( [ mem.bytes ] );
  ram = mem / 1024 ^ 2;
  wt = mem / 7000000;
  fprintf( 'RAM usage: %.0fMb\n', ram )
  fprintf( 'Run time: at least %s\n', datestr( nt * wt / 3600 / 24, 13 ) )
  fprintf('Time      Amax        Vmax        Umax        Compute     I/O/Viz\n')
  tic
  return
end

% Magnitudes
if ( pass == 'w' ) then
  s1 = sqrt( sum( u .* u, 4 ) );
  s2 = sqrt( sum( w1 .* w1, 4 ) + 2 * sum( w2 .* w2, 4 ) );
  [ umax, iumax ] = max( s1(:) );
  [ wmax, iwmax ] = max( s2(:) );
  [ usmax, iusmax ] = max( abs( us(:) ) );
  if umax > dx / 10., fprintf( 'Warning: u !<< dx\n' ), end
else
  s1 = sqrt( sum( w1 .* w1, 4 ) );
  s2 = sqrt( sum( v .* v, 4 ) );
  [ amax, iamax ] = max( s1(:) );
  [ vmax, ivmax ] = max( s2(:) );
  [ vsmax, ivsmax ] = max( abs( vs(:) ) );
end

for iz = 1:size( ditout, 1 )

if ditout(iz) < 0, ditout(iz) = ditout(iz) + nt + 1; end
if ~ditout(iz) | mod( it, ditout(iz) ), continue, end
nc = 1;
onpass = 'v';
cell = 0;
isfault = 0;
static = 0;
switch outvar{iz}
case 'x',    static = 1; nc = 3;
case 'a',    nc = 3;
case 'v',    nc = 3;
case 'u',    onpass = 'w'; nc = 3;
case 'w',    onpass = 'w'; nc = 6; cell = 1;
case 'am'
case 'vm'
case 'um',   onpass = 'w';
case 'wm',   onpass = 'w'; cell = 1;
case 'vs',   isfault = 1;
case 'us',   isfault = 1;
case 'trup', isfault = 1;
otherwise error( [ 'outvar: ' outvar{iz} ] )
end
if isfault & ~ifn; ditout(iz) = 0; end
if onpass ~= pass, continue, end
[ i1, i2 ] = zone( i1out(iz,:), i2out(iz,:), nn, noff, i0, ifn );
if cell; i2 = i2 - 1; end

% Metadata
file = sprintf( 'out/%02d/meta', iz );
fid = fopen( file, 'w' );
fprintf( fid, ' field  %s\n',       outfield{iz} );
fprintf( fid, ' nc     %g\n',       nc           );
fprintf( fid, ' i1     %g %g %g\n', i1 - noff    );
fprintf( fid, ' i2     %g %g %g\n', i2 - noff    );
fprintf( fid, ' itout  %g\n',       it           );
fprintf( fid, ' dit    %g\n',       ditout(iz)   );
fprintf( fid, ' tout   %g\n',       t            );
fprintf( fid, ' endian %s\n',       endian       );
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
  file = sprintf( 'out/%02d/%s%1d%06d', iz, outvar{iz}, i, it );
  fid = fopen( file, 'w' );
  switch outvar{iz}
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
  case 'vs',   fwrite( fid, vs(j,k,l),     'float32' );
  case 'us',   fwrite( fid, us(j,k,l),     'float32' );
  case 'trup', fwrite( fid, trup(j,k,l),   'float32' );
  otherwise error( [ 'outvar: ' outvar{iz} ] )
  end
  fclose( fid );
  if static, ditout(iz) = 0; end
end

end

if pass == 'w', return, end

%------------------------------------------------------------------------------%

if itcheck & ~mod( it, itcheck )
  save 'out/ckp' it t u v p1 p2 p3 p4 p5 p6 g1 g2 g3 g4 g5 g6 vs us trup
end

fid = fopen( 'out/timestep', 'w' );
fprintf( fid, '%g\n', it );
fclose( fid );

wt(4) = toc;

file = sprintf( 'out/stats/%06d', it );
fid = fopen( file, 'w' );
fprintf( fid, '%15.7e', [ t amax vmax umax wmax vsmax usmax wt ] );
fprintf( fid, '\n' );
fclose( fid );

fprintf( '%12.4e', [ t amax vmax umax wt(1:2) + wt(3:4) ] )
fprintf( '\n' )

