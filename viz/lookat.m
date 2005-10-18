% Set projection

function lookat( look, upvector, xcenter, rmax, camdist )

[ tmp, l ] = max( abs( upvector ) );
k = 6 - l - 1;
upvec = upvector;
up = sign( upvector(l) );
a = -sign( look );
i = abs( look );
switch i
case 0
  camproj( 'perspective' );
  camva( 1.25 * 22 )
  pos = [ a a a ] / 2;
  pos(k) = a / sqrt( 2 );
case { 1, 2, 3 }
  camproj( 'orthographic' );
  camva( 22 )
  pos = [ 0 0 0 ];
  pos(i) = a;
  if all( cross( pos, upvec ) == 0 )
    upvec = [ 0 0 0 ];
    upvec(k) = up;
  end
otherwise error 'look'
end
if camdist <= 0
  camdist = 1.5 * rmax;
end

camtarget( xcenter )
campos( xcenter + camdist * pos )
camup( upvec )
axis equal
axis vis3d

