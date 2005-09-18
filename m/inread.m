%------------------------------------------------------------------------------%
% INPUT

plotstyle = '';
plotstyle = 'slice';
truptol = .001;
inkey   = {}; i1in    = []; i2in   = []; inval = [];
outkey  = {}; i1out   = []; i2out  = []; ditout = [];
lock    = []; i1lock  = []; i2lock = [];
grid    = '';

for file = { 'defaults' 'in' }

fprintf( 'Reading file: %s\n', file{1} )
in = textread( file{1}, '%s', 'delimiter', '\n', 'commentstyle', 'shell' );

for i = 1:length( in )
  %if in{i}, else continue, end
  str = strread( in{i}, '%[^#]' );
  [ key, str ] = strtok( str{1} );
  inzone = 0;
  switch key
  case ''
  case 'grid',         model        = strtok( str );
  case 'n',            n            = strread( str, '%u' )';
    nn = n(1:3);
    nt = n(4);
  case 'dx',           dx           = strread( str, '%f' )';
  case 'dt',           dt           = strread( str, '%f' )';
  case 'grid',         grid         = strtok( str );
  case 'rho',          inzone       = 1;
  case 'vp',           inzone       = 1;
  case 'vs',           inzone       = 1;
  case 'lock',         val          = strread( str, '%u' )';
    lock(end+1,:)   = val(1:3);
    i1lock(end+1,:) = val(4:6);
    i2lock(end+1,:) = val(7:9);
  case 'viscosity',    viscosity    = strread( str, '%f' )';
  case 'npml',         npml         = strread( str, '%u' )';
  case 'bc',           bc           = strread( str, '%u' )';
  case 'hypocenter',   x0           = strread( str, '%f' )';
  case 'moment',       moment       = strread( str, '%f' )';
  case 'sourcetimefn', sourcetimefn = strtok( str );
  case 'tsource',      tsource      = strread( str, '%f' )';
  case 'rsource',      rsource      = strread( str, '%f' )';
  case 'faultnormal',  ifn          = strread( str, '%u' )';
  case 'upvector',     upvector     = strread( str, '%f' )';
  case 'mus',          inzone       = 1;
  case 'mud',          inzone       = 1;
  case 'dc',           inzone       = 1;
  case 'cohesion',     inzone       = 1;
  case 'tnormal',      inzone       = 1;
  case 'tstrike',      inzone       = 1;
  case 'tdip',         inzone       = 1;
  case 'cohesion',     inzone       = 1;
  case 'sxx',          inzone       = 1;
  case 'syy',          inzone       = 1;
  case 'szz',          inzone       = 1;
  case 'syz',          inzone       = 1;
  case 'szx',          inzone       = 1;
  case 'sxy',          inzone       = 1;
  case 'vrup',         vrup         = strread( str, '%f' )';
  case 'rcrit',        rcrit        = strread( str, '%f' )';
  case 'trelax',       trelax       = strread( str, '%f' )';
  case 'truptol',      truptol      = strread( str, '%f' )';
  case 'np',           np           = strread( str, '%u' );
  case 'checkpoint',   itcheck      = strread( str, '%u' )';
  case 'out'
    [ key, str ] = strtok( str );
    val = strread( str, '%u' )';
    outkey{end+1}   = key;
    ditout(end+1,:) = val(1);
    i1out(end+1,:)  = val(2:4);
    i2out(end+1,:)  = val(5:7);
  otherwise error( in{i} )
  end
  if inzone
    [ key, str ]  = strtok( str );
    val = strread( str, '%u' )';
    inkey{end+1}  = key;
    inval(end+1)  = val(1);
    i1in(end+1,:) = val(2:4);
    i2in(end+1,:) = val(5:7);
  end
end

end
 
