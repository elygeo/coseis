function xx = upsamp( x );

n = size( x );
n(1:2) = 2 * n(1:2) - 1;
xx = zeros( n );
xx(1:2:end,1:2:end,:) = x;
xx(1:2:end,2:2:end,:) = .50 * ( x(:,1:end-1,:) + x(:,2:end,:) );
xx(2:2:end,1:2:end,:) = .50 * ( x(1:end-1,:,:) + x(2:end,:,:) );
xx(2:2:end,2:2:end,:) = .25 * ( x(1:end-1,1:end-1,:) + x(2:end,2:end,:) + x(1:end-1,2:end,:) + x(2:end,1:end-1,:) );

