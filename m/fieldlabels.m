% Field labels
function labels = fieldlabels( field, radial )

labels = { field field };

switch field
case 'x',    labels = { 'Position'      '|X|' 'x' 'y' 'z' };
case 'mr',   labels = { 'Mass Ration'   '1/m' };
case 'mu',   labels = { '\mu'           '\mu' };
case 'lam',  labels = { '\lambda'       '\lambda' };
case 'y',    labels = { 'Y'             'Y' };
case 'v',    labels = { 'Velocity'      '|V|' 'V_x' 'V_y' 'V_z' };
case 'u',    labels = { 'Displacement'  '|U|' 'U_x' 'U_y' 'U_z' };
case 'w',    labels = { 'Stress'        '|W|' 'W_{xx}' 'W_{yy}' 'W_{zz}' 'W_{yz}' 'W_{zx}' 'W_{xy}' };
case 'a',    labels = { 'Acceleration'  '|A|' 'A_x' 'A_y' 'A_z' };
case 'vm',   labels = { 'Velocity'      '|V|' };
case 'um',   labels = { 'Displacement'  '|U|' };
case 'wm',   labels = { 'Stress'        '|W|' };
case 'am',   labels = { 'Acceleration'  '|A|' };
case 'pv',   labels = { 'Peak Velocity' '|V|_{peak}' };
case 'nhat', labels = { 'Fault Surface Normals' '|n|' 'n_x' 'n_y' 'n_z' };
case 'ts0',  labels = { 'Initial Shear Traction'       '|T_s|' 'T_x' 'T_y' 'T_z' };
case 'tsm0', labels = { 'Initial Shear Traction'       '|T_s|' };
case 'tn0',  labels = { 'Initial Normal Traction'      'T_n' };
case 'mus',  labels = { 'Static Friction Coefficient'  '\mu_s' };
case 'mud',  labels = { 'Dynamic Friction Coefficient' '\mu_d' };
case 'dc',   labels = { 'Slip Weakening Distance'      'Dc' };
case 'co',   labels = { 'Cohesion'                     'co' };
case 'sv',   labels = { 'Slip Velocity'     '|V_s|' 'V_s_x' 'V_s_y' 'V_s_z' };
case 'su',   labels = { 'Slip'              '|U_s|' 'U_s_x' 'U_s_y' 'U_s_z' };
case 'ts',   labels = { 'Shear Traction'    '|T_s|' 'T_s_x' 'T_s_y' 'T_s_z' };
case 'sa',   labels = { 'Slip Acceleration' '|A_s|' 'A_s_x' 'A_s_y' 'A_s_z' };
case 'svm',  labels = { 'Slip Velocity'     '|V_s|' };
case 'sum',  labels = { 'Slip'              '|U_s|' };
case 'tsm',  labels = { 'Shear Traction'    '|T_s|' };
case 'sam',  labels = { 'Slip Acceleration' '|A_s|' };
case 'tn',   labels = { 'Normal Traction'   'T_n' };
case 'fr',   labels = { 'Friction'          'f' };
case 'sl',   labels = { 'Slip Path Length'  'l' };
case 'psv',  labels = { 'Peak Slip Velocity' '|V_s|_{peak}' };
case 'trup', labels = { 'Rupture Time'       't_{rupture}' };
case 'tarr', labels = { 'Arrest Time'        't_{arrest}' };
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

