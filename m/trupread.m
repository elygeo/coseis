% Read rupture time
function [ x, t ] = trupread

meta
currentstep
found = 0;
nout = length( out );
for i = 1:nout
  if strcmp( out{i}{2}, 'trup' ), found = 1; break, end
end
if ~found
  msg = 'No rupture time found';
  x = [];
  t = [];
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
[ msg, t ] = read4d( 'trup', i1, i2 );
t = squeeze( t );
i1(4) = 1;
i2(4) = 1;
[ msg, x ] = read4d( 'x', i1, i2 );
x = squeeze( x(:,:,:,[j k]) );
n = size( t );
j2 = n(1);
k2 = n(2);
if ( abs( bc2(j) ) == 3 )
  t(j2+1:2*j2-1,:)   = t(j2-1:-1:1,:);
  x(j2+1:2*j2-1,:,2) = x(j2-1:-1:1,:,2);
  x(j2+1:2*j2-1,:,1) = 2 * x(j2,k2,1) - x(j2-1:-1:1,:,1);
end
if ( abs( bc2(k) ) == 3 )
  t(:,k2+1:2*k2-1)   = t(:,k2-1:-1:1);
  x(:,k2+1:2*k2-1,1) = x(:,k2-1:-1:1,1);
  x(:,k2+1:2*k2-1,2) = 2 * x(j2,k2,2) - x(:,k2-1:-1:1,2);
end

