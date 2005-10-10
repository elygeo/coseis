% Extract 4D slice from memory or disk
% input: iz i1s i2s fieldin it

% Array slice
i = i1s(1:3) < 0; i1s(i) = i1s(i) + nn(i) + 1;
i = i2s(1:3) < 0; i2s(i) = i2s(i) + nn(i) + 1;
n = i2s - i1s + 1;
if all( n ~= 1 ), error 'trying to read 5 dimensions', end
if prod(n) > 1e8, error 'too big', end
msg = '';

% Use in memory data if available
if exist( 'sordrunning', 'var' ) & i1s(4) == it
  l = i1s(3):i2s(3);
  k = i1s(2):i2s(2);
  j = i1s(1):i2s(1);
  i = i1s(5):i2s(5);
  switch vizfield
  case 'x',  vg = x(j,k,l,i);
  case 'a',  vg = w1(j,k,l,i);
  case 'v',  vg = v(j,k,l,i);
  case 'u',  vg = u(j,k,l,i);
  case 'w'
    i1 = find(i<4);
    i2 = find(i>3) - 3;
    vg = zeros( n(1:4) );
    vg(:,:,:,i1)   = w1(j,k,l,i1);
    vg(:,:,:,i2+3) = w2(j,k,l,i2);
  case 'am', vg = s1(j,k,l);
  case 'vm', vg = s2(j,k,l);
  case 'um', vg = s1(j,k,l);
  case 'wm', vg = s2(j,k,l);
  case 'sv', vg = sv(j,k,l);
  case 'sl', vg = sl(j,k,l);
  case 'tn', vg = tn(j,k,l);
  case 'ts', vg = ts(j,k,l);
  case 'trup', vg = trup(j,k,l);
  case 'trise', vg = trise(j,k,l);
  otherwise error 'fieldin'
  end
  return
end

% Look for file with desired data
cwd = pwd;
cd 'out'
meta
if ~iz, iz = 1:nout; end
found = 0;
for iz = iz
  cd( sprintf( '%02d', iz ) )
  meta
  i1g = [ i1 1 1 ];
  i2g = [ i2 it nc ];
  found = strcmp( vizfield, field ) && ...
          all( i1s >= i1g ) && ...
          all( i2s <= i2g ) && ...
          ( dit == 1 || ( n(4) == 1 && find( i1s(4) == dit:dit:it ) ) );
  if found, break, end
  cd ..
end
if ~found
  cd( cwd )
  msg = 'No data available for this location';
  return
end

% Read data
ng = i2g - i1g + 1;
i1s = i1s - i1g + 1;
i2s = i2s - i1g + 1;
vg = zeros( n );
block = sprintf( '%d*float32', n(1) );
skip = 4 * ( ng(1) - n(1) );
j = i1s(1);
k = i1s(2);
for i   = i1s(5):i2s(5)
for itg = i1s(4):i2s(4)
  file = sprintf( '%s%1d%06d', field, i, itg );
  fid = fopen( file, 'r', endian );
  for l = i1s(3):i2s(3)
    seek = 4 * ( j - 1 + ng(1) * ( k - 1 + ng(2) * ( l - 1 ) ) );
    fseek( fid, seek, 'bof' );
    vg(:,:,l,itg,i) = fread( fid, n(1)*n(2), block, skip, endian );
  end
  fclose( fid );
end
end
cd( cwd )

