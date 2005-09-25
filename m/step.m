%------------------------------------------------------------------------------%
% Step

if itstep < 1, itstep = 1; end

while 1
  itstep = itstep - 1;
  pml
  if pass ~= 'w'
    pass = 'w';
    stress
    momentsource
    output
    viz
    if ~itstep & breakon == 'w', break, end
  end
  if pass ~= 'a'
    pass = 'a';
    acceleration
    fault
    locknodes
    output
    viz
    timestep
    if ~itstep & breakon == 'a', break, end
  end
end

