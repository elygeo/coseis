%------------------------------------------------------------------------------%
% MOMENTSRC

if initialize
  source = [];
  switch abs( srcgeom )
  case 0,  a = [  0 0 ];
  case 8,  a = [ -1 0 ];
  case 32, a = [ -2 1 ];
  case 1,  a = [  0 0 ];
  case 7,  a = [ -1 1 ];
  case 19, a = [ -1 1 ];
  otherwise, error( 'unknown source geometry' )
  end
  if hypocenter + a(1) >= 2 & hypocenter + a(2) <= n, else
    srcgeom, hypocenter, n
    error( 'source geometry extends out of domain' )
  end
  return
end

moment = moment(:);
if length( source ) < nt
  % FIXME source time func no longer integrated
  % time indexing goes Si vi Si+1 vi+1...
  T = 8 * dt;
  t = ( .5 : nt-.5 ) * dt;
  switch 'brune'
  case 'delta'
    source = 0 * t; source(1) = 1;
  case 'brune'
    source = t .* exp( -t / T ) ./ h ^ 3 ./ T ^ 2;
  case 'smoothbrune'
    source = t .^ 2 .* exp( - t / T ) / h ^ 3 / T ^ 2;
  case 'sin'
    snt    = min( [ nt 9 ] );
    source = zeros( 1, nt );
    source(1:snt) = sin( ( 0 : snt-1 ) / ( snt - 1 ) * pi * 2 );
  end
end
for i = 1:6
  j = hypocenter(1);
  k = hypocenter(2);
  l = hypocenter(3);
  a = [-1 1]; % S cell centered: 1,7,19,27
  b = [-1 0]; % v node centered: 8, 32
  c = [-2 1]; % v node centered: 32
  r = 1;
  if srcgeom < 0; % moment insead of moment rate?
    srcgeom = -srcgeom;
    r = 0;
  end
  switch srcgeom
  case 0
  case 8
    S(j+b,k+b,l+b,i) = r*S(j+b,k+b,l+b,i) + source(it)*moment(i)/6;
  case 32
    S(j+b,k+b,l+b,i) = r*S(j+b,k+b,l+b,i) + source(it)*moment(i)/12;
    S(j+c,k+b,l+b,i) = r*S(j+c,k+b,l+b,i) + source(it)*moment(i)/48;
    S(j+b,k+c,l+b,i) = r*S(j+b,k+c,l+b,i) + source(it)*moment(i)/48;
    S(j+b,k+b,l+c,i) = r*S(j+b,k+b,l+c,i) + source(it)*moment(i)/48;
  case 1
    S(j,k,l,i)       = r*S(j,k,l,i)       + source(it)*moment(i);
  case 7
    S(j,k,l,i)       = r*S(j,k,l,i)       + source(it)*moment(i)/2;
    S(j+a,k,l,i)     = r*S(j+a,k,l,i)     + source(it)*moment(i)/12;
    S(j,k+a,l,i)     = r*S(j,k+a,l,i)     + source(it)*moment(i)/12;
    S(j,k,l+a,i)     = r*S(j,k,l+a,i)     + source(it)*moment(i)/12;
  case 19
    S(j,k,l,i)       = r*S(j,k,l,i)       + source(it)*moment(i)/6;
    S(j+a,k,l,i)     = r*S(j+a,k,l,i)     + source(it)*moment(i)/18;
    S(j,k+a,l,i)     = r*S(j,k+a,l,i)     + source(it)*moment(i)/18;
    S(j,k,l+a,i)     = r*S(j,k,l+a,i)     + source(it)*moment(i)/18;
    S(j+a,k+a,l,i)   = r*S(j+a,k+a,l,i)   + source(it)*moment(i)/24;
    S(j,k+a,l+a,i)   = r*S(j,k+a,l+a,i)   + source(it)*moment(i)/24;
    S(j+a,k,l+a,i)   = r*S(j+a,k,l+a,i)   + source(it)*moment(i)/24;
  end
end

