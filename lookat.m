%------------------------------------------------------------------------------%
% LOOKAT

if camdist <= 0, camdist = 1.5 * xmax; end
a = -sign( look );
pos = [ 0 0 0 ];
upvec = [ 0 0 0 ];
upvec(dims(3)) = -1;
camproj( 'orthographic' );
camva( 22 )
switch abs( look )
case 1, pos(dims(1)) = a;
case 2, pos(dims(2)) = a;
case 3, pos(dims(3)) = a; upvec(dims(2)) = a;
case 4, pos = [ a a a ] / 2; pos(dims(2)) = a / sqrt( 2 );
  camproj( 'perspective' );
  camva( 1.25 * camva )
otherwise error look
end
camtarget( x0 )
campos( x0 + camdist * pos )
camup( upvec )
axis equal
axis vis3d
look = 0;

