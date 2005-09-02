%------------------------------------------------------------------------------%
% INPUT

plotstyle = '';
plotstyle = 'slice';
planewavedim = 0;
truptol = .001;
material  = []; imat    = [];
friction  = []; ifric   = [];
traction  = []; itrac   = [];
stress    = []; istress = [];
locknodes = []; ilock   = [];
outvar    = {}; iout    = []; outit = [];

for file = { 'in.defaults', 'in' }
fprintf( 'Reading file: %s\n', file{1} )
in = textread( file{1}, '%s', 'delimiter', '\n', 'commentstyle', 'shell' );
caseswitch = '';
switchcase = '';
for i = 1:length( in )
  if in{i}, else continue, end
  key = strread( in{i}, '%s', 'commentstyle', 'shell' );
  str = strread( in{i}, '%*s %[^#]' );
  str = str{1};
  switch key{1}
  case 'switch', switchcase = key{2};
  case 'case',   caseswitch = key{2};
  end
  if ~strcmp( caseswitch, switchcase ), continue, end
  switch key{1}
  case ''
  case 'switch'
  case 'case'
  case 'np'
  case 'grid',       grid       = key{2};
  case 'n',          n          = strread( str, '%n' )';
  case 'dx',         dx         = strread( str, '%n' )';
  case 'dt',         dt         = strread( str, '%n' )';
  case 'bc',         bc         = strread( str, '%n' )';
  case 'npml',       npml       = strread( str, '%n' )';
  case 'viscosity',  viscosity  = strread( str, '%n' )';
  case 'nrmdim',     nrmdim     = strread( str, '%n' )';
  case 'hypocenter', hypocenter = strread( str, '%n' )';
  case 'rcrit',      rcrit      = strread( str, '%n' )';
  case 'vrup',       vrup       = strread( str, '%n' )';
  case 'nclramp',    nclramp    = strread( str, '%n' )';
  case 'moment',     moment     = strread( str, '%n' )';
  case 'msrcradius', msrcradius = strread( str, '%n' )';
  case 'srctimefcn', srctimefcn = key{2};
  case 'domp',       domp       = strread( str, '%n' )';
  case 'checkpoint', checkpoint = strread( str, '%n' )';
  case 'verbose',    verb       = strread( str, '%n' )';
  case 'locknodes'
    val = strread( str, '%n' )';
    locknodes = [ locknodes; val(1:3)  ];
    ilock     = [ ilock;     val(4:9)  ];
  case 'material'
    val = strread( str, '%n' )';
    material  = [ material;  val(1:3)  ];
    imat      = [ imat;      val(4:9)  ];
  case 'friction'
    val = strread( str, '%n' )';
    friction   = [ friction; val(1:4)  ];
    ifric      = [ ifric;    val(5:10) ];
  case 'traction'
    val = strread( str, '%n' )';
    traction   = [ traction; val(1:3)  ];
    itrac      = [ itrac;    val(4:9)  ];
  case 'stress'
    val = strread( str, '%n' )';
    stress     = [ stress;   val(1:6)  ];
    istress    = [ istress;  val(7:12) ];
  case 'out'
    outvar = { outvar{:} key{2} }';
    str = strread( str, '%*s %[^#]' );
    val = strread( str{1}, '%n' )';
    outit  = [ outit; val(1) ];
    iout   = [ iout; val(2:7) ];
  otherwise error input
  end
end
end
 
