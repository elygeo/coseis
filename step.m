%------------------------------------------------------------------------------%
% STEP

if itstep < 1, itstep = 1; end

while itstep
  tic
  wt = 0;
  itstep = itstep - 1;
  it = it + 1;
  stepv, wt(2) = toc;
  stepu, wt(3) = toc;
  stepw, wt(4) = toc;
  if length( out ), output, end
  if plotstyle, viz, end
  if exist( './pause', 'file' )
    disp( 'pause file found' )
    delete pause
    save
    itstep = 0;
  end
  wt(5) = toc;
  dwt = wt(2:end) - wt(1:end-1);
  timing = [ it  dwt wt(end) ];
  fprintf( 1, '%5d   %.2e %.2e %.2e %.2e %.2e\n', timing );
end

disp( 'paused' )

