tmp = x(:,:,:,:,1); [ min( tmp(:) ) max( tmp(:) ) ]
tmp = x(:,:,:,:,2); [ min( tmp(:) ) max( tmp(:) ) ]
tmp = x(:,:,:,:,3); [ min( tmp(:) ) max( tmp(:) ) ]
clf
outline( x )
xlabel( 'X' )
ylabel( 'Y' )
zlabel( 'Z' )
axis equal
axis vis3d
