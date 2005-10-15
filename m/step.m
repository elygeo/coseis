% Step

if itstep < 1, itstep = 1; end

while istep
  itstep = itstep - 1;
  pml
  stress
  momentsource
  pass = 'w';
  output
  acceleration
  fault
  locknodes
  pass = 'a';
  output
  timestep
end

