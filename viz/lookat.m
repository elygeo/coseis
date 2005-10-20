% Set projection
function lookat( look, upvector, xcenter, camdist )

upvec = upvector;
[ tmp, l ] = max( abs( upvector ) );
if l == 1, error, end
j = 1;
k = 6 - j - l;
i = abs( look );

switch i
case 0
  camproj( 'perspective' );
  camva( 27.5 )
  pos(j) = .5;
  pos(k) = -.5 * sqrt( 2 );
  pos(l) = .5 * sign( upvector(l) );
case { 1, 2, 3 }
  camproj( 'orthographic' );
  camva( 22 )
  pos = [ 0 0 0 ];
  pos(i) = -sign( look );
  if all( cross( pos, upvec ) == 0 )
    upvec = [ 0 0 0 ];
    upvec(k) = sign( look );
  end
otherwise error 'look'
end

camtarget( xcenter )
campos( xcenter + camdist * pos )
camup( upvec )
axis equal
axis vis3d

