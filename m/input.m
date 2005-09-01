%------------------------------------------------------------------------------%
% INPUT

plotstyle = 'slice';
plotstyle = '';
planewavedim = 0;
truptol = .001;
material  = []; imat    = [];
friction  = []; ifric   = [];
traction  = []; itrac   = [];
stress    = []; istress = [];
locknodes = []; ilock   = [];
outvar    = {}; iout    = []; outit = [];

for file = { 'in.defaults', 'in' }
in = textread( file{1}, '%s', 'delimiter', '\n', 'commentstyle', 'shell' );
caseswitch = '';
switchcase = '';
for i = 1:length( in )
  if in{i}, else continue, end
  key = strread( in{i}, '%s', 'commentstyle', 'shell' );
  s   = strread( in{i}, '%*s %[^#]' );
  s   = a{1};
  switch key{1}
  case 'switch', switchcase = key{2}; model = key{2};
  case 'case',   caseswitch = key{2};
  end
  if ~strcmp( caseswitch, switchcase ), continue, end
  switch key{1}
  case ''
  case 'switch'
  case 'case'
  case 'np'
  case 'grid',       grid       = key{2};
  case 'n',          n          = strread( s, '%n' )';
  case 'dx',         dx         = strread( s, '%n' )';
  case 'dt',         dt         = strread( s, '%n' )';
  case 'bc',         bc         = strread( s, '%n' )';
  case 'npml',       npml       = strread( s, '%n' )';
  case 'viscosity',  viscosity  = strread( s, '%n' )';
  case 'nrmdim',     nrmdim     = strread( s, '%n' )';
  case 'hypocenter', hypocenter = strread( s, '%n' )';
  case 'rcrit',      rcrit      = strread( s, '%n' )';
  case 'vrup',       vrup       = strread( s, '%n' )';
  case 'nclramp',    nclramp    = strread( s, '%n' )';
  case 'moment',     moment     = strread( s, '%n' )';
  case 'msrcradius', msrcradius = strread( s, '%n' )';
  case 'srctimefcn', srctimefcn = key{2};
  case 'domp',       domp       = strread( s, '%n' )';
  case 'checkpoint', checkpoint = strread( s, '%n' )';
  case 'verbose',    verb       = strread( s, '%n' )';
  case 'locknodes'
    a = strread( a, '%n' )';
    locknodes = [ locknodes; s(1:3)  ];
    ilock     = [ ilock;     s(4:9)  ];
  case 'material'
    a = strread( a, '%n' )';
    material  = [ material;  s(1:3)  ];
    imat      = [ imat;      s(4:9)  ];
  case 'friction'
    a = strread( a, '%n' )';
    friction   = [ friction; s(1:4)  ];
    ifric      = [ ifric;    s(5:10) ];
  case 'traction'
    a = strread( a, '%n' )';
    traction   = [ traction; s(1:3)  ];
    itrac      = [ itrac;    s(4:9)  ];
  case 'stress'
    a = strread( a, '%n' )';
    stress     = [ stress;   s(1:6)  ];
    istress    = [ istress;  s(7:12) ];
  case 'out'
    outvar = { outvar{:} key{2} }';
    a = strread( s, '%*s %[^#]' );
    a = strread( s{1}, '%n' )';
    outit  = [ outit; s(1) ];
    iout   = [ iout; s(2:7) ];
  otherwise error input
  end
end
end
 
