%------------------------------------------------------------------------------%
% LOOKAT

if look
  if camdist <= 0, camdist = 1.5 * xmax; end
  i = 1:3;
  i(downdim) = [];
  i = [ downdim i ];
  if nrmdim && nrmdim ~= downdim
    i(nrmdim) = [];
    i = [ i(1) nrmdim i(2) ];
  end
  a = -sign( look );
  pos = [ 0 0 0 ];
  upvec = [ 0 0 0 ];
  upvec(i(1)) = -1;
  camproj( 'orthographic' );
  camva( 22 )
  switch abs( look )
  case 1, pos(i(1)) = a; upvec(i(2)) = a;
  case 2, pos(i(2)) = a;
  case 3, pos(i(3)) = a;
  case 4, pos = [ a a a ] / 2; pos(i(2)) = a / sqrt( 2 );
    camproj( 'perspective' );
    camva( 1.25 * camva )
  end
  camtarget( x0 )
  campos( x0 + camdist * pos )
  camup( upvec )
  axis equal
  axis vis3d
  look = 0;
end

