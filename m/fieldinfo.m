% Field information

isfault = 1;
cellfocus = 0;

switch field
case 'x'
  fmax  = 2 * rmax;
  fmaxi = nn;
  labels = { 'Position' '|X|' 'x' 'y' 'z' };
case 'a'
  fmax  = amax;
  fmaxi = amaxi;
  labels = { 'Acceleration' '|A|' 'Ax' 'Ay' 'Az' };
case 'v'
  fmax  = vmax;
  fmaxi = vmaxi;
  labels = { 'Velocity' '|V|' 'Vx' 'Vy' 'Vz' };
case 'u'
  fmax  = umax;
  fmaxi = umaxi;
  labels = { 'Displacement' '|U|' 'Ux' 'Uy' 'Uz' };
case 'w'
  cellfocus = 1;
  fmax  = wmax;
  fmaxi = wmaxi;
  labels = { 'Stress' '|W|' 'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
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
case 'sv'
  isfault = 1;
  fmax  = svmax;
  fmaxi = svmaxi;
  labels = { 'Slip Velocity' 'Vslip' };
case 'sl'
  isfault = 1;
  fmax  = slmax;
  fmaxi = slmaxi;
  labels = { 'Slip Length' 'lslip' };
case 'tn'
  isfault = 1;
  fmax  = tnmax;
  fmaxi = tnmaxi;
  labels = { 'Normal Stress' 'Tn' };
case 'ts'
  isfault = 1;
  fmax  = tsmax;
  fmaxi = tsmaxi;
  labels = { 'Shear Stress' 'Ts' };
otherwise, error 'field'
end

