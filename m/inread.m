%------------------------------------------------------------------------------%
% INPUT

plotstyle = '';
plotstyle = 'slice';
truptol = .001;
nin = 0;
nout = 0;
nlock = 0;

for file = { 'defaults.m' 'in.m' }

fprintf( 'Reading file: %s\n', file{1} )
in = textread( file{1}, '%s', 'delimiter', '\n' );

for i = 1:length( in )
  if in{i}, else continue, end
  eval( in{i} )
  key = strtok( in{i} );
  switch key
  case { 'rho', 'vp', 'vs', ...
         'mus', 'mud', 'dc', 'co', ...
         'tnrm', 'tstr', 'tdip', ...
         'sxx', 'syy', 'szz', ...
         'syz', 'szx', 'sxy' }
    eval( [ 'in =' key ';' ] )
    nin = nin + 1;
    fieldin{nin} = key;
    inval(nin)   = in(1);
    i1in(nin,:)  = in(2:4);
    i2in(nin,:)  = in(5:7);
  case 'lock'
    nlock = nlock + 1;
    locki0(nlock,:) = lock(1:3);
    i1lock(nlock,:) = lock(4:6);
    i2lock(nlock,:) = lock(7:9);
  case 'out'
    nout = nout + 1;
    fieldout{nout} = out{1};
    ditout(nout,:) = out{2};
    i1out(nout,:)  = [ out{3:5} ];
    i2out(nout,:)  = [ out{6:8} ];
  end
  end
end
lock = lock0;

end
 
