% Field labels
function labels = fieldlabels( varargin )

field = varargin{1};
radial = 0;
if nargin > 1, radial = varargin{2}; end

labels = { field field };

switch field
case 'x',    labels = { 'Position'      '|X|' 'x' 'y' 'z' };
case 'rho',  labels = { 'Density'       '\rho' };
case 'vp',   labels = { 'P-wave velocity' 'V_p' };
case 'vs',   labels = { 'S-wave velocity' 'V_s' };
case 'mu',   labels = { '\mu'           '\mu' };
case 'lam',  labels = { '\lambda'       '\lambda' };
case 'v',    labels = { 'Velocity'      '|V|' 'V_x' 'V_y' 'V_z' };
case 'u',    labels = { 'Displacement'  '|U|' 'U_x' 'U_y' 'U_z' };
case 'w',    labels = { 'Stress'        '|W|' 'W_{xx}' 'W_{yy}' 'W_{zz}' 'W_{yz}' 'W_{zx}' 'W_{xy}' };
case 'a',    labels = { 'Acceleration'  '|A|' 'A_x' 'A_y' 'A_z' };
case 'vm2',  labels = { 'Velocity'      '|V|' };
case 'um2',  labels = { 'Displacement'  '|U|' };
case 'wm2',  labels = { 'Stress'        '|W|' };
case 'am2',  labels = { 'Acceleration'  '|A|' };
case 'pv2',  labels = { 'Peak velocity' '|V|_{peak}' };
case 'nhat', labels = { 'Fault surface normals' '|n|' 'n_x' 'n_y' 'n_z' };
case 'mus',  labels = { 'Static friction coefficient'  '\mu_s' };
case 'mud',  labels = { 'Dynamic friction coefficient' '\mu_d' };
case 'dc',   labels = { 'Slip weakening sistance'      'Dc' };
case 'co',   labels = { 'Cohesion'                     'co' };
case 'sv',   labels = { 'Slip velocity'     '|V_s|' 'V_s_x' 'V_s_y' 'V_s_z' };
case 'su',   labels = { 'Slip'              '|U_s|' 'U_s_x' 'U_s_y' 'U_s_z' };
case 'ts',   labels = { 'Shear traction'    '|T_s|' 'T_s_x' 'T_s_y' 'T_s_z' };
case 'sa',   labels = { 'Slip acceleration' '|A_s|' 'A_s_x' 'A_s_y' 'A_s_z' };
case 'svm',  labels = { 'Slip velocity'     '|V_s|' };
case 'sum',  labels = { 'Slip'              '|U_s|' };
case 'tsm',  labels = { 'Shear traction'    '|T_s|' };
case 'sam',  labels = { 'Slip acceleration' '|A_s|' };
case 'tn',   labels = { 'Normal traction'   'T_n' };
case 'fr',   labels = { 'Friction'          'f' };
case 'sl',   labels = { 'Slip path length'  'l' };
case 'psv',  labels = { 'Peak slip velocity' '|V_s|_{peak}' };
case 'trup', labels = { 'Rupture time'       't_{rupture}' };
case 'tarr', labels = { 'Arrest time'        't_{arrest}' };
end

if radial
  switch field
  case 'x',  labels = { 'Position'     '|X|' 'r' 'h' 'v' };
  case 'v',  labels = { 'Velocity'     '|V|' 'V_r' 'V_h' 'V_v' };
  case 'u',  labels = { 'Displacement' '|U|' 'U_r' 'U_h' 'U_v' };
  case 'w',  labels = { 'Stress'       '|W|' 'W_{rr}' 'W_{hh}' 'W_{vv}' 'W_{hv}' 'W_{vr}' 'W_{rh}' };
  case 'a',  labels = { 'Acceleration' '|A|' 'A_r' 'A_h' 'A_v' };
  end
end

