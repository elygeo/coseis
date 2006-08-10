% Field labels
function labels = fieldlabels( field, radial )

labels = { field };

switch field
case 'x',    labels = { 'Position'     '|X|' 'x' 'y' 'z' };
case 'mr',   labels = { 'Mass Ration'  '1/m' };
case 'mu',   labels = { '\mu'          '\mu' };
case 'lam',  labels = { '\lambda'      '\lambda' };
case 'y',    labels = { 'Y'            'Y' };
case 'a',    labels = { 'Acceleration' '|A|' 'A_x' 'A_y' 'A_z' };
case 'v',    labels = { 'Velocity'     '|V|' 'V_x' 'V_y' 'V_z' };
case 'u',    labels = { 'Displacement' '|U|' 'U_x' 'U_y' 'U_z' };
case 'w',    labels = { 'Stress'       '|W|' 'W_{xx}' 'W_{yy}' 'W_{zz}' 'W_{yz}' 'W_{zx}' 'W_{xy}' };
case 'am',   labels = { 'Acceleration' '|A|' };
case 'vm',   labels = { 'Velocity'     '|V|' };
case 'um',   labels = { 'Displacement' '|U|' };
case 'wm',   labels = { 'Stress'       '|W|' };
case 'pv',   labels = { 'Peak Velocity' '|V|_peak' };
case 'nhat', labels = { 'Fault Surface Normals' '|n|' 'n_x' 'n_y' 'n_z' };
case 't0',   labels = { 'Pre-Traction'          '|T|' 'T_x' 'T_y' 'T_z' };
case 'mus',  labels = { 'Static Friction Coefficient'  '\mu_s' };
case 'mud',  labels = { 'Dynamic Friction Coefficient' '\mu_d' };
case 'dc',   labels = { 'Slip Weakening Distance'      'Dc' };
case 'co',   labels = { 'Cohesion'                     'co' };
case 'sa',   labels = { 'Slip Acceleration' '|A_s|' 'A_x' 'A_y' 'A_z' };
case 'sv',   labels = { 'Slip Velocity'     '|V_s|' 'V_x' 'V_y' 'V_z' };
case 'su',   labels = { 'Slip'              '|U_s|' 'U_x' 'U_y' 'U_z' };
case 'ts',   labels = { 'Shear Traction'    '|T|' 'T_x' 'T_y' 'T_z' };
case 't',    labels = { 'Traction'          '|T|' 'T_x' 'T_y' 'T_z' };
case 'sam',  labels = { 'Slip Acceleration' '|A_s|' };
case 'svm',  labels = { 'Slip Velocity'     '|V_s|' };
case 'sum',  labels = { 'Slip'              '|U_s|' };
case 'tnm',  labels = { 'Normal Traction'   'T_n' };
case 'tsm',  labels = { 'Shear Traction'    '|T_s|' };
case 'sl',   labels = { 'Slip Path Length'  'l' };
case 'f',    labels = { 'Friction'          'f' };
case 'psv',  labels = { 'Peak Slip Velocity' '|V_s|_{peak}' };
case 'trup', labels = { 'Rupture Time'       't_{rupture}' };
case 'tarr', labels = { 'Arrest Time'        't_{arrest}' };
end

if radial
  switch field
  case 'x',  labels = { 'Position'     '|X|' 'r' 'h' 'v' };
  case 'a',  labels = { 'Acceleration' '|A|' 'A_r' 'A_h' 'A_v' };
  case 'v',  labels = { 'Velocity'     '|V|' 'V_r' 'V_h' 'V_v' };
  case 'u',  labels = { 'Displacement' '|U|' 'U_r' 'U_h' 'U_v' };
  case 'w',  labels = { 'Stress'       '|W|' 'W_{rr}' 'W_{hh}' 'W_{vv}' 'W_{hv}' 'W_{vr}' 'W_{rh}' };
  end
end

