% Input

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
         'tn', 'th', 'td', ...
         'sxx', 'syy', 'szz', ...
         'syz', 'szx', 'sxy' }
    nin = nin + 1;
    fieldin{nin} = key;
    i1in(nin,:) =  [ 1 1 1 ];
    i2in(nin,:) = -[ 1 1 1 ];
    if strcmp( key(2), 'read' )
      readfile(iz) = 1;
    else
      readfile(iz) = 0;
      eval( [ 'key =' key ';' ] )
      inval(nin) = key(1);
      if length(key) > 3
        i1in(nin,:) = key(2:4);
        i2in(nin,:) = key(5:7);
      end
    end
  case 'lock'
    nlock = nlock + 1;
    ilock(nlock,:) = lock(1:3);
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

end
 
