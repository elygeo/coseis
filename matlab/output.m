%------------------------------------------------------------------------------%
% OUTPUT

if initialize
  fprintf( 'Initialize output\n' )
  if checkpoint < 0, checkpoint = nt + checkpoint + 1; end
  if ~readcheckpoint
    if exist( 'out', 'dir' ), rmdir( 'out', 's' ), end
    mkdir( 'out/stats/' )
  end
  [ tmp1, tmp2, endian ] = computer;
  fid = fopen( 'out/endian', 'w' );
  fprintf( fid, '%s\n', endian );
  fclose( fid );
  for iz = 1:size( out, 1 )
    outvar{iz} = out{iz,1};
    outint(iz) = out{iz,2};
    outnc(iz)    = 1;
    outcell(iz)  = 0;
    outfault(iz) = 0;
    pass(iz) = 'w';
    switch outvar{iz}
    case 'a',   outnc(iz) = 3; pass(iz) = 'v';
    case 'v',   outnc(iz) = 3; pass(iz) = 'v';
    case 'u',   outnc(iz) = 3;
    case 'w',   outnc(iz) = 6; outcell(iz) = 1;
    case '|a|', pass(iz) = 'v';
    case '|v|', pass(iz) = 'v';
    case '|u|'
    case '|w|', outcell(iz) = 1;
    case 'x',   outnc(iz) = 3;
    case 'rho'
    case 'yn'
    case 'lam', outcell(iz) = 1;
    case 'miu', outcell(iz) = 1;
    case 'yc',  outcell(iz) = 1;
    case 'vslip', outfault(iz) = 1;
    case 'uslip', outfault(iz) = 1;
    case 'trup',  outfault(iz) = 1;
    end
    if outfault(iz) & ~nrmdim; outint(iz) = 0; end
    if outint(iz) < 0, outint(iz) = outint(iz) + nt + 1; end
    if outint(iz)
      for i = 1:outnc(iz)
        file = sprintf( 'out/%02d/%1d/', iz, i );
        mkdir( file )
      end
    end
  end
  return
end

for iz = 1:size( out, 1 )
  if outint(iz) & ~mod( it, outint(iz) ) & pass(iz) == laststep
    [ i1, i2 ] = zoneselect( [out{iz,3:8}], halo, np, hypocenter, nrmdim );
    if outcell(iz); i2 = i2 - 1; end
    if outfault(iz)
      i1(nrmdim) = 1;
      i2(nrmdim) = 1;
    end
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    for i = 1:outnc(iz)
      static = 0;
      file = sprintf( 'out/%02d/%1d/%05d', iz, i, it );
      fid = fopen( file, 'wl' );
      switch outvar{iz}
      case 'a',     fwrite( fid, w1(j,k,l,i) / dt,  'float32' );
      case 'v',     fwrite( fid, v(j,k,l,i),        'float32' );
      case 'u',     fwrite( fid, u(j,k,l,i),        'float32' );            
      case 'w'
        if i < 4,   fwrite( fid, w1(j,k,l,i),       'float32' ); end
        if i > 3,   fwrite( fid, w2(j,k,l,i-3),     'float32' ); end
      case '|a|',   fwrite( fid, sqrt( s1(j,k,l) / dt ), 'float32' );
      case '|v|',   fwrite( fid, sqrt( s2(j,k,l) ), 'float32' );
      case '|u|',   fwrite( fid, sqrt( s1(j,k,l) ), 'float32' );
      case '|w|',   fwrite( fid, sqrt( s2(j,k,l) ), 'float32' );
      case 'vslip', fwrite( fid, vslip(j,k,l),      'float32' );
      case 'uslip', fwrite( fid, uslip(j,k,l),      'float32' );
      case 'trup',  fwrite( fid, trup(j,k,l),       'float32' );
      case 'x',     fwrite( fid, x(j,k,l,i),        'float32' ); static = 1;
      case 'rho',   fwrite( fid, rho(j,k,l),        'float32' ); static = 1;
      case 'yn',    fwrite( fid, yn(j,k,l),         'float32' ); static = 1;
      case 'lam',   fwrite( fid, lam(j,k,l),        'float32' ); static = 1;
      case 'miu',   fwrite( fid, miu(j,k,l),        'float32' ); static = 1;
      case 'yc',    fwrite( fid, yc(j,k,l),         'float32' ); static = 1;
      otherwise error outvar
      end
      fclose( fid );
      if static, outint(iz) = 0; end
    end
    file = sprintf( 'out/%02d/hdr', iz );
    fid = fopen( file, 'w' );
    fprintf( fid, '%g ', [ outnc(iz) i1 i2 outint(iz) it dt dx ] );
    fprintf( fid, '%s\n', outvar{iz} );
    fclose( fid );
  end
end

if laststep == 'v', return, end

if checkpoint & ~mod( it, checkpoint )
  if nrmdim, save checkpoint it u v uslip trup
  else       save checkpoint it u v
  end
end
dwt = wt(2:end) - wt(1:end-1);
timing = [ it  dwt wt(end) ];
file = sprintf( 'out/stats/%05d', it );
fid = fopen( file, 'w' );
fprintf( fid, '%5d   %g %g %g %g %.2e %.2e %.2e %.2e\n', [ it amax vmax umax wmax dwt ] );
fclose( fid );
fid = fopen( 'out/timestep', 'w' );
fprintf( fid, '%g\n', it );
fclose( fid );
if exist( './pause', 'file' )
  fprintf( 'pause file found\n' )
  delete pause
  save
  itstep = 0;
end
