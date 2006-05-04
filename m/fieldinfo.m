% Field information

isfault = 1;
cellfocus = 0;
fmaxi = [ 0 0 0 ];
fmax = max(s(:));

switch field
case 'x'
  fmax  = 2 * rmax;
  fmaxi = nn;
  labels = { 'Position' '|X|' 'x' 'y' 'z' };
case 'mr'
  labels = { 'Mass Ration' '1/m' };
case 'mu'
  labels = { '\mu' '\mu' };
case 'lam'
  labels = { '\lambda' '\lambda' };
case 'y'
  labels = { 'Y' 'Y' };
case 'a'
  fmax  = amax;
  fmaxi = amaxi;
  labels = { 'Acceleration' '|A|' 'A_x' 'A_y' 'A_z' };
case 'v'
  fmax  = vmax;
  fmaxi = vmaxi;
  labels = { 'Velocity' '|V|' 'V_x' 'V_y' 'V_z' };
case 'u'
  fmax  = umax;
  fmaxi = umaxi;
  labels = { 'Displacement' '|U|' 'U_x' 'U_y' 'U_z' };
case 'w'
  cellfocus = 1;
  fmax  = wmax;
  fmaxi = wmaxi;
  labels = { 'Stress' '|W|' 'W_{xx}' 'W_{yy}' 'W_{zz}' 'W_{yz}' 'W_{zx}' 'W_{xy}' };
case 'am'
  fmax  = amax;
  fmaxi = amaxi;
  labels = { 'Acceleration' '|A|' };
case 'vm'
  fmax  = vmax;
  fmaxi = vmaxi;
  labels = { 'Velocity' '|V|' };
case 'um'
  fmax  = umax;
  fmaxi = umaxi;
  labels = { 'Displacement' '|U|' };
case 'wm'
  cellfocus = 1;
  fmax  = wmax;
  fmaxi = wmaxi;
  labels = { 'Stress' '|W|' };
case 'nhat'
  isfault = 1;
  fmax  = 1;
  labels = { 'Fault Surface Normals' '|n|' 'n_x' 'n_y' 'n_z' };
case 't0'
  isfault = 1;
  labels = { 'Pre-Traction' '|T|' 'T_x' 'T_y' 'T_z' };
case 'mus'
  isfault = 1;
  labels = { 'Static Friction Coefficient' '\mu_s' };
case 'mud'
  isfault = 1;
  labels = { 'Dynamic Friction Coefficient' '\mu_d' };
case 'dc'
  isfault = 1;
  labels = { 'Slip Weakening Distance' 'Dc' };
case 'co'
  isfault = 1;
  labels = { 'Cohesion' 'co' };
case 'sa'
  isfault = 1;
  fmax  = samax;
  fmaxi = samaxi;
  labels = { 'Slip Acceleration' '|A|' 'A_x' 'A_y' 'A_z' };
case 'sv'
  isfault = 1;
  fmax  = svmax;
  fmaxi = svmaxi;
  labels = { 'Slip Velocity' '|V|' 'V_x' 'V_y' 'V_z' };
case 'su'
  isfault = 1;
  fmax  = sumax;
  fmaxi = sumaxi;
  labels = { 'Slip' '|U|' 'U_x' 'U_y' 'U_z' };
case 'ts'
  isfault = 1;
  fmax  = tsmax;
  fmaxi = tsmaxi;
  labels = { 'Shear Traction' '|T|' 'T_x' 'T_y' 'T_z' };
case 't'
  isfault = 1;
  labels = { 'Traction' '|T|' 'T_x' 'T_y' 'T_z' };
case 'sam'
  isfault = 1;
  fmax  = samax;
  fmaxi = samaxi;
  labels = { 'Slip Acceleration' '|A|' };
case 'svm'
  isfault = 1;
  fmax  = svmax;
  fmaxi = svmaxi;
  labels = { 'Slip Velocity' '|V|' };
case 'sum'
  isfault = 1;
  fmax  = sumax;
  fmaxi = sumaxi;
  labels = { 'Slip' '|U|' };
case 'tnm'
  isfault = 1;
  fmax  = tnmax;
  fmaxi = tnmaxi;
  labels = { 'Normal Traction' 'T_n' };
case 'tsm'
  isfault = 1;
  fmax  = tsmax;
  fmaxi = tsmaxi;
  labels = { 'Shear Traction' '|T_s|' };
case 'sl'
  isfault = 1;
  fmax  = slmax;
  fmaxi = slmaxi;
  labels = { 'Slip Path Length' '\el' };
case 'f'
  isfault = 1;
  labels = { 'Friction' 'f' };
case 'svp'
  isfault = 1;
  labels = { 'Peak Slip Velocity' '|V|_{peak}' };
case 'trup'
  isfault = 1;
  labels = { 'Rupture Time' 't_{rupture}' };
case 'tarr'
  isfault = 1;
  fmax  = tarrmax;
  fmaxi = tarrmaxi;
  labels = { 'Arrest Time' 't_{arrest}' };
otherwise, error 'field'
end

