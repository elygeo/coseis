%------------------------------------------------------------------------------%
% Look at

i = abs( look );
a = -sign( look );
upvec = [ 0 0 0 ];
upvec(crdsys(3)) = up;
switch i
case { 1, 2, 3 }
  camproj( 'orthographic' );
  camva( 22 )
  pos = [ 0 0 0 ];
  pos(i) = a;
  if ( i == crdsys(3) )
    upvec = [ 0 0 0 ];
    upvec(crdsys(2)) = a;
  end
case 4
  camproj( 'perspective' );
  camva( 1.25 * 22 )
  pos = [ a a a ] / 2;
  pos(crdsys(2)) = a / sqrt( 2 );
otherwise error 'look'
end
if camdist <= 0
  camdist = 1.5 * xmax;
end

camtarget( xcenter )
campos( xcenter + camdist * pos )
camup( upvec )
axis equal
axis vis3d
look = 0;
panviz = 0;

