%------------------------------------------------------------------------------%
% LOOKAT

if look
  zoomed = 0;
  pos   = [ 0 0 0 ];
  targ  = [ 0 0 0 ];
  upvec = [ 0 0 0 ];
  va = 30;
  a = 3 * sign( look );
  i = 1:3;
  i(downdim) = [];
  i = [ downdim i ];
  camproj( 'orthographic' );
  switch look
  case -1, pos(i(1)) = a; upvec(i(2)) = 1;
  case  1, pos(i(1)) = a; upvec(i(2)) = -1;
  case -2, pos(i(2)) = a; upvec(i(1)) = -1;
  case  2, pos(i(2)) = a; upvec(i(1)) = -1;
  case -3, pos(i(3)) = a; upvec(i(1)) = -1;
  case  3, pos(i(3)) = a; upvec(i(1)) = -1;
  case  4, pos = -[ a a a ] / sqrt(3); upvec(i(1)) = -1;
    camproj( 'perspective' );
  otherwise
    v1 = camup;
    v2 = camtarget - campos;
    [ t, i1 ] = max( abs( v1 ) );
    [ t, i2 ] = max( abs( v2 ) );
    upvec(i1) = sign( v1(i1) );
    targ(i2) = a * sign( v2(i2) );
  end
  campos( double( x0 + xscl * pos ) )
  camtarget( double( x0 + xscl * targ ) )
  camup( upvec )
  if va, camva( va ), end
  camva( 'manual' );
  %axis equal
  look = 0;
end

