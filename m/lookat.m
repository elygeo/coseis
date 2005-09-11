%------------------------------------------------------------------------------%
% LOOKAT

if camdist <= 0, camdist = 1.5 * xmax; end
a = -sign( look );
pos = [ 0 0 0 ];
upvec = [ 0 0 0 ];
upvec(crdsys(3)) = -1;
camproj( 'orthographic' );
camva( 22 )
switch abs( look )
case 1, pos(crdsys(1)) = a;
case 2, pos(crdsys(2)) = a;
case 3, pos(crdsys(3)) = a; upvec(crdsys(2)) = a;
case 4, pos = [ a a a ] / 2; pos(crdsys(2)) = a / sqrt( 2 );
  camproj( 'perspective' );
  camva( 1.25 * camva )
otherwise error 'look'
end
camtarget( xcenter )
campos( xcenter + camdist * pos )
camup( upvec )
axis equal
axis vis3d
look = 0;
panviz = 0;

