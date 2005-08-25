%------------------------------------------------------------------------------%
% STEP

initialize = 0;
if itstep < 1, itstep = 1; end

while itstep
  itstep = itstep - 1;
  it = it + 1;
  wt(1) = toc; vstep
  wt(2) = toc; thispass = 1; output
  wt(3) = toc; wstep
  wt(4) = toc; viz
  wt(5) = toc; thispass = 2; output
end

