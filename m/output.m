%------------------------------------------------------------------------------%
% OUTPUT

if init
  init = 0;
  fprintf( 'Initialize output\n' )
  s1(:) = 0.;
  s2(:) = 0.;
  w1(:) = 0.;
  w2(:) = 0.;
  if checkpoint < 0, checkpoint = nt + checkpoint + 1; end
  if exist( 'out/checkpoint.mat', 'file' )
    load out/checkpoint
    if size( rho ) == nm, else error 'Checkpoint', end
    fprintf( 'Checkpoint found, starting from step %g\n', it )
  else
    if exist( 'out', 'dir' ), error 'Previous run exists', end
    mkdir( 'out/stats/' )
    for iz = 1:size( outit, 1 )
      file = sprintf( 'out/%02d/', iz );
      mkdir( file )
    end
  end
  [ tmp1, tmp2, endian ] = computer;
  fid = fopen( 'out/endian', 'w' );
  fprintf( fid, '%s\n', endian );
  fclose( fid );
  fid = fopen( 'out/x0', 'w' );
  fprintf( fid, '%g %g %g\n', x0 );
  fclose( fid );
  mem = whos;
  mem = sum( [ mem.bytes ] );
  ram = mem / 1024 ^ 2;
  wt = mem / 7000000;
  fprintf( 'RAM usage: %.0fMb\n', ram )
  fprintf( 'Run time: at least %s\n', datestr( nt * wt / 3600 / 24, 13 ) )
  fprintf('  Step  Amax        Vmax        Umax        Compute     I/O/Viz\n')
  tic
  return
end

for iz = 1:size( outit, 1 )
  if outit(iz) < 0, outit(iz) = outit(iz) + nt + 1; end
  if ~outit(iz) | mod( it, outit(iz) ), continue, end
  nc = 1;
  onpass = 'v';
  cell = 0;
  isfault = 0;
  static = 0;
  switch outvar{iz}
  case 'rho',  static = 1;
  case 'lam',  static = 1; cell = 1;
  case 'mu',   static = 1; cell = 1;
  case 'y',    static = 1; cell = 1;
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
  if isfault & ~nrmdim; outit(iz) = 0; end
  if onpass ~= pass, continue, end
  [ i1, i2 ] = zone( iout(iz,:), nn, offset, hypocenter, nrmdim );
  if cell; i2 = i2 - 1; end
  if isfault
    i1(nrmdim) = 1;
    i2(nrmdim) = 1;
  end
  l = i1(3):i2(3);
  k = i1(2):i2(2);
  j = i1(1):i2(1);
  for i = 1:nc
    file = sprintf( 'out/%02d/%1d%06d', iz, i, it );
    fid = fopen( file, 'w' );
    switch outvar{iz}
    case 'rho',  fwrite( fid, rho(j,k,l),    'float32' );
    case 'lam',  fwrite( fid, lam(j,k,l),    'float32' );
    case 'mu',   fwrite( fid, mu(j,k,l),     'float32' );
    case 'y',    fwrite( fid, y(j,k,l),      'float32' );
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
    if static, outit(iz) = 0; end
  end
  file = sprintf( 'out/%02d/hdr', iz );
  fid = fopen( file, 'w' );
  fprintf( fid, '%g ', [ nc i1-offset i2-offset outit(iz) it dt dx ] );
  fprintf( fid, '%s\n', outvar{iz} );
  fclose( fid );
end

if pass == 'w', return, end

if checkpoint & ~mod( it, checkpoint )
  save out/checkpoint it u v p1 p2 p3 p4 p5 p6 g1 g2 g3 g4 g5 g6 vs us trup
end

fid = fopen( 'out/timestep', 'w' );
fprintf( fid, '%g\n', it );
fclose( fid );

wt(4) = toc;

file = sprintf( 'out/stats/%06d', it );
fid = fopen( file, 'w' );
fprintf( fid, '%16.7e', [ amax vmax umax wmax vsmax usmax wt ] );
fprintf( fid, '\n' );
fclose( fid );

fprintf( '%6d', it )
fprintf( '%12.4e', [ amax vmax umax wt(1:2) + wt(3:4) ] )
fprintf( '\n' )

