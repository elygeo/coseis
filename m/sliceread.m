% Read final slice
function [ x, f ] = sliceread( field )

meta
currentstep
found = 0;
nout = length( out );
for i = 1:nout
  if strcmp( out{i}{2}, field ), found = 1; break, end
end
if ~found
  msg = 'No rupture time found';
  x = [];
  f = [];
  return
end
msg = '';
it = it - mod( it, out{i}{3} );
i1 = [ out{i}{4:6} it ];
i2 = [ out{i}{7:9} it ];
l = abs( faultnormal );
j = max( 1, 3 - l );
k = 6 - j - l;
i1(l) = ihypo(l);
i2(l) = ihypo(l);
[ msg, f ] = read4d( field, i1, i2 );
f = squeeze( f );
[ msg, x ] = read4d( 'x', i1, i2 );
x = squeeze( x(:,:,:,[j k]) );
n = size( f );
j2 = n(1);
k2 = n(2);
if ( abs( bc2(j) ) == 3 )
  f(j2+1:2*j2-1,:)   = f(j2-1:-1:1,:);
  x(j2+1:2*j2-1,:,2) = x(j2-1:-1:1,:,2);
  x(j2+1:2*j2-1,:,1) = 2 * x(j2,k2,1) - x(j2-1:-1:1,:,1);
end
if ( abs( bc2(k) ) == 3 )
  f(:,k2+1:2*k2-1)   = f(:,k2-1:-1:1);
  x(:,k2+1:2*k2-1,1) = x(:,k2-1:-1:1,1);
  x(:,k2+1:2*k2-1,2) = 2 * x(j2,k2,2) - x(:,k2-1:-1:1,2);
end

