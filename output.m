%------------------------------------------------------------------------------%
% OUTPUT

if initialize
  fprintf( 'Initialize output\n' )
  if checkpoint < 0, checkpoint = nt; end
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
    cells = 0;
    faultplane = 0;
    switch outvar{iz}
    case 'u',     c = { 'x' 'y' 'z' };
    case 'v',     c = { 'x' 'y' 'z' }; 
    case 'm',     c = { 'x' 'y' 'z' }; 
    case 't',     c = { 'x' 'y' 'z' }; faultplane = 1;
    case 'w',     c = { 'xx' 'yy' 'zz' 'yz' 'zx' 'xy' }; cells = 1;
    case 'uslip', c = { 'm' }; faultplane = 1;
    case 'vslip', c = { 'm' }; faultplane = 1;
    otherwise error outvar
    end
    outnc(iz) = length( c );
    if outint(iz) < 0, outint(iz) = outint(iz) + nt + 1; end
    zone = [ out{iz,3:8} ];
    [ i1, i2 ] = zoneselect( zone, halo, np, hypocenter, nrmdim );
    i2 = i2 - cells;
    if faultplane
      i1(nrmdim) = hypocenter(nrmdim);
      i2(nrmdim) = hypocenter(nrmdim);
    end
    for i = 1:outnc(iz)
      file = sprintf( 'out/%02d/%1d/', iz, i );
      mkdir( file )
    end
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    if cells
      switch nrmdim
      case 1, j(j==hypocenter(1)) = [];
      case 2, k(k==hypocenter(2)) = [];
      case 3, l(l==hypocenter(3)) = [];
      end
    end
    for i = 1:3
      file = sprintf( 'out/%02d/mesh%1d', iz, i );
      fid = fopen( file, 'w' );
      if cells
        fwrite( fid, 0.125 * ( ...
          x(j,k,l,i) + x(j+1,k+1,l+1,i) + ...
          x(j+1,k,l,i) + x(j,k+1,l+1,i) + ...
          x(j,k+1,l,i) + x(j+1,k,l+1,i) + ...
          x(j,k,l+1,i) + x(j+1,k+1,l,i) ), ...
        'float32' );
      else
        fwrite( fid, x(j,k,l,i), 'float32' );
      end
      fclose( fid );
    end
    file = sprintf( 'out/%02d/hdr', iz );
    fid = fopen( file, 'w' );
    fprintf( fid, '%g %g %g %g %g %g %g %s %s\n', ...
      [ outnc(iz) i2-i1+1 outint(iz) nt dt ], outvar{iz}, [ c{:} ] );
    fclose( fid );
    if faultplane
      i1(nrmdim) = 1;
      i2(nrmdim) = 1;
    end
    outi1(:,iz) = i1;
    outi2(:,iz) = i2;
  end
  return
end

if ~mod( it, checkpoint )
  if nrmdim, save checkpoint it u v uslip trup
  else       save checkpoint it u v
  end
end
for iz = 1:size( out, 1 )
  if mod( it, outint(iz) ) == 0
    i1 = outi1(:,iz);
    i2 = outi2(:,iz);
    l = i1(3):i2(3);
    k = i1(2):i2(2);
    j = i1(1):i2(1);
    for i = 1:outnc(iz)
      file = sprintf( 'out/%02d/%1d/%05d', iz, i, it );
      fid = fopen( file, 'wl' );
      switch outvar{iz}
      case 'u', fwrite( fid, u(j,k,l,i), 'float32' );
      case 'v', fwrite( fid, v(j,k,l,i), 'float32' );
      case 'm', fwrite( fid, s1(j,k,l),  'float32' );
      case 't', fwrite( fid, t(j,k,l,i), 'float32' );
      case 'w'
        switch nrmdim
        case 1, j(j==hypocenter(1)) = [];
        case 2, k(k==hypocenter(2)) = [];
        case 3, l(l==hypocenter(3)) = [];
        end
        if i <= 3, fwrite( fid, w1(j,k,l,i),   'float32' );
        else       fwrite( fid, w2(j,k,l,i-3), 'float32' );
        end
      case 'uslip', fwrite( fid, uslip(j,k,l), 'float32' );
      case 'vslip', fwrite( fid, vslip(j,k,l), 'float32' );
      otherwise error outvar
      end
      fclose( fid );
    end
  end
end
fid = fopen( 'out/timestep', 'w' );
fprintf( fid, '%g\n', it );
fclose( fid );
file = sprintf( 'out/stats/%05d', it );
fid = fopen( file, 'w' );
fprintf( fid, '%g %g %g\n', [ umax vmax wmax ] );
fclose( fid );

