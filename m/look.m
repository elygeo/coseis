
clear all
meta

for i = 1 : nt

  i

  cd ../01; f1 = read4d( 'am2', [ 4 0 0 i ] );
  cd ../02; f2 = read4d( 'am2', [ 4 0 0 i ] );
  df = f2 - f1;

  figure(1)
  imagesc( df )
  axis equal tight
  colorbar

  waitforbuttonpress

end
