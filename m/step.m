%------------------------------------------------------------------------------%
% STEP

if itstep < 1, itstep = 1; end

while 1
  itstep = itstep - 1;
  if pass ~= 'w'
    pass = 'w';
    it = it + 1;
    tic; wstep; wt(1) = toc;
    tic; viz; output; wt(2) = toc;
    if ~itstep & breakon == 'w', break, end
  end
  if pass ~= 'v'
    pass = 'v';
    tic; vstep; wt(3) = toc;
    tic; viz; output; wt(4) = toc;
    if ~itstep & breakon == 'v', break, end
  end
end

