%------------------------------------------------------------------------------%
% INPUT

planewavedim = 0;
plotstyle = '';
truptol = .001;
material  = []; imat    = [];
friction  = []; ifric   = [];
traction  = []; itrac   = [];
stress    = []; istress = [];
locknodes = []; ilock   = [];
outvar    = {}; iout    = []; outit = [];

for file = { 'defaults', 'in' }
in = textread( file{1}, '%s', 'delimiter', '\n', 'commentstyle', 'shell' );
caseswitch = '';
switchcase = '';
for i = 1:length( in )
  if in{i}, else continue, end
  key = strread( in{i}, '%s', 'commentstyle', 'shell' );
  a   = strread( in{i}, '%*s %[^#]' );
  a   = a{1};
  switch key{1}
  case 'switch', switchcase = key{2};
  case 'case',   caseswitch = key{2};
  end
  if ~strcmp( caseswitch, switchcase ), continue, end
  switch key{1}
  case ''
  case 'switch'
  case 'case'
  case 'nprocs'
  case 'grid',       grid       = key{2};
  case 'n',          n          = strread( a, '%n' )';
  case 'dx',         dx         = strread( a, '%n' )';
  case 'dt',         dt         = strread( a, '%n' )';
  case 'bc',         bc         = strread( a, '%n' )';
  case 'npml',       npml       = strread( a, '%n' )';
  case 'viscosity',  viscosity  = strread( a, '%n' )';
  case 'nrmdim',     nrmdim     = strread( a, '%n' )';
  case 'hypocenter', hypocenter = strread( a, '%n' )';
  case 'rcrit',      rcrit      = strread( a, '%n' )';
  case 'vrup',       vrup       = strread( a, '%n' )';
  case 'nclramp',    nclramp    = strread( a, '%n' )';
  case 'moment',     moment     = strread( a, '%n' )';
  case 'msrcradius', msrcradius = strread( a, '%n' )';
  case 'srctimefcn', srctimefcn = key{2};
  case 'checkpoint', checkpoint = strread( a, '%n' )';
  case 'verbose',    verb       = strread( a, '%n' )';
  case 'locknodes'
    a = strread( a, '%n' )';
    locknodes = [ locknodes; a(1:3)  ];
    ilock     = [ ilock;     a(4:9)  ];
  case 'material'
    a = strread( a, '%n' )';
    material  = [ material;  a(1:3)  ];
    imat      = [ imat;      a(4:9)  ];
  case 'friction'
    a = strread( a, '%n' )';
    friction   = [ friction; a(1:4)  ];
    ifric      = [ ifric;    a(5:10) ];
  case 'traction'
    a = strread( a, '%n' )';
    traction   = [ traction; a(1:3)  ];
    itrac      = [ itrac;    a(4:9)  ];
  case 'stress'
    a = strread( a, '%n' )';
    stress     = [ stress;   a(1:6)  ];
    istress    = [ istress;  a(7:12) ];
  case 'out'
    outvar = { outvar{:} key{2} };
    a = strread( a, '%*s %[^#]' );
    a = strread( a{1}, '%n' )';
    outit  = [ outit; a(1) ];
    iout   = [ iout; a(2:7) ];
  otherwise error input
  end
end
end
 
