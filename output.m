%------------------------------------------------------------------------------%
% OUTPUT

if initialize
  disp( 'Initialize output' )
  if checkpoint < 0, checkpoint = nt; end
  if ~readcheckpoint
    if exist( 'out', 'dir' ), rmdir( 'out', 's' ), end
    mkdir( 'out/stats/' )
  end
  [ tmp1, tmp2, endian ] = computer;
  fid = fopen( 'out/endian', 'w' );
  fprintf( fid, '%s', endian );
  fclose( fid );
  for iz = 1:size( out, 1 )
    outvar{iz} = out{iz,1};
    outint(iz) = out{iz,2};
    cells = 0;
    faultplane = 0;
    switch outvar{iz}
    case 'u',     c = { 'x' 'y' 'z' };
    case 'v',     c = { 'x' 'y' 'z' }; 
    case 'S',     c = { 'xx' 'yy' 'zz' 'yz' 'zx' 'xy' }; cells = 1;
    case 'T',     c = { 'xx' 'yy' 'zz' 'yz' 'zx' 'xy' }; faultplane = 1;
    case 'slipu', c = { 'm' }; faultplane = 1;
    case 'slipv', c = { 'm' }; faultplane = 1;
    otherwise, error( 'unknown out type' )
    end
    outc(iz) = length( c );
    if outint(iz) < 0, outint(iz) = outint(iz) + nt + 1; end
    [ i1, i2 ] = zoneselect( [ out{iz,3:8} ], 0, core, hypocenter, nrmdim );
    i2 = i2 - cells;
    if faultplane
      i1(nrmdim) = hypocenter(nrmdim);
      i2(nrmdim) = hypocenter(nrmdim);
    end
    for i = 1:outc(iz)
      file = sprintf( 'out/%02d/%1d/', iz, i );
      mkdir( file )
    end
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    file = sprintf( 'out/%02d/mesh', iz );
    fid = fopen( file, 'wl' );
    fwrite( fid, shiftdim( x(j,k,l,:), 3 ), 'float32' );
    fclose( fid );
    file = sprintf( 'out/%02d/hdr', iz );
    fid = fopen( file, 'wl' );
    fprintf( fid, '%g ', [ outc(iz) i1 i2 1 1 1 outint(iz) h h h dt ] );
    fprintf( fid, '\n%s %s\n', outvar{iz}, [ c{:} ] );
    fclose( fid );
    if faultplane
      i1(nrmdim) = 1;
      i2(nrmdim) = 1;
    end
    outi1(iz,:) = i1;
    outi2(iz,:) = i2;
  end
  return
end

if ~mod( it, checkpoint ), save checkpoint it slip u v vv trup, end
for iz = 1:size( out, 1 )
  if mod( it, outint(iz) ) == 0
    i1 = outi1(iz,:);
    i2 = outi2(iz,:);
    j = i1(1):i2(1);
    k = i1(2):i2(2);
    l = i1(3):i2(3);
    for i = 1:outc(iz)
      file = sprintf( 'out/%02d/%1d/%05d', iz, i, it );
      fid = fopen( file, 'wl' );
      switch outvar{iz}
      case 'u', fwrite( fid, u(j,k,l,i), 'float32' );
      case 'v', fwrite( fid, v(j,k,l,i), 'float32' );
      case 'S', fwrite( fid, S(j,k,l,i), 'float32' );
      case 'T', fwrite( fid, T(j,k,l,i), 'float32' );
      case 'slipu', fwrite( fid, slipu(j,k,l), 'float32' );
      case 'slipv', fwrite( fid, slipv(j,k,l), 'float32' );
      otherwise, error( 'unknown out type' )
      end
      fclose( fid );
    end
  end
end
fid = fopen( 'out/timestep', 'w' );
fprintf( fid, '%g ', it );
fclose( fid );
file = sprintf( 'out/stats/%05d', it );
fid = fopen( file, 'w' );
fwrite( fid, [ umax vmax Smax ] );
fclose( fid );

