%------------------------------------------------------------------------------%
% LOOKAT

if look
  zoomed = 0;
  if camdist <= 0, camdist = 1.5 * xmax; end
  pos   = [ 0 0 0 ];
  upvec = [ 0 0 0 ];
  va = 23;
  a = sign( look );
  i = 1:3;
  i(downdim) = [];
  i = [ downdim i ];
  if nrmdim && nrmdim ~= downdim
    i(nrmdim) = [];
    i = [ i(1) nrmdim i(2) ];
  end
  camproj( 'orthographic' );
  viz3d = 0;
  switch abs( look )
  case 1, pos(i(1)) = a; upvec(i(2)) = -a;
  case 2, pos(i(2)) = a; upvec(i(1)) = -1;
  case 3, pos(i(3)) = a; upvec(i(1)) = -1;
  case 4,
    viz3d = 1;
    va = 30;
    %pos = -[ a a a ] / sqrt(3);
    pos = -[ a a a ] / 2; pos(i(2)) = -a / sqrt( 2 );
    upvec(i(1)) = -1;
    camproj( 'perspective' );
  otherwise
    v1 = camup;
    v2 = camtarget - campos;
    [ t, i1 ] = max( abs( v1 ) );
    [ t, i2 ] = max( abs( v2 ) );
    upvec(i1) = sign( v1(i1) );
    pos(i2) = -a * sign( v2(i2) );
  end
  campos( x0 + camdist * pos )
  camtarget( x0 )
  camup( upvec )
  if va, camva( va ), end
  camva( 'manual' );
  axis vis3d
  look = 0;
end

