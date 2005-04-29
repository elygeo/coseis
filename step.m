%------------------------------------------------------------------------------%
% STEP

if itstep < 1, itstep = 1; end

while itstep
  tic
  wt = 0;
  itstep = itstep - 1;
  it = it + 1;
  stepv
  wt(2) = toc;
  u = u + dt * v;
  if nrmdim, uslip = uslip + dt * vslip; end
  wt(3) = toc;
  stepw
  wt(4) = toc;
  s1 = sum( u .* u, 4 ); [ umax, umaxi ] = max( s1(:) );
  s1 = sum( v .* v, 4 ); [ vmax, vmaxi ] = max( s1(:) );
  s2 = sum( w1 .* w1, 4 ) + 2 * sum( w2 .* w2, 4 );
  [ wmax, wmaxi ] = max( s2(:) );
  umax = sqrt( umax );
  vmax = sqrt( vmax );
  wmax = sqrt( wmax );
  if umax > h / 10
    fprintf( 'Warning: u !<< h\n' )
  end
  if length( out ), output, end
  if plotstyle, viz, end
  if exist( './pause', 'file' )
    fprintf( 'pause file found\n' )
    delete pause
    save
    itstep = 0;
  end
  wt(5) = toc;
  dwt = wt(2:end) - wt(1:end-1);
  timing = [ it  dwt wt(end) ];
  fprintf( '%s%5d   %.2e %.2e %.2e %.2e %.2e\n', spacer, timing );
  spacer = '>> ';
end

