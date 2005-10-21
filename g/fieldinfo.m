
switch field
case 'x',    labels = { 'Position'        'r' 'x' 'y' 'z' };
case 'a',    labels = { 'Acceleration'    '|A|' 'Ax' 'Ay' 'Az' };
case 'v',    labels = { 'Velocity'        '|V|' 'Vx' 'Vy' 'Vz' };
case 'u',    labels = { 'Displacement'    '|U|' 'Ux' 'Uy' 'Uz' };
case 'w',    labels = { 'Stress'          '|W|' 'Wxx' 'Wyy' 'Wzz' 'Wyz' 'Wzx' 'Wxy' };
case 'am',   labels = { 'Acceleration'    '|A|' };
case 'vm',   labels = { 'cceleration'     '|V|' };
case 'um',   labels = { 'Displacement'    '|U|' };
case 'wm',   labels = { 'Stress'          '|W|' };
case 'sv',   labels = { 'Slip Velocity'   'Vslip' };
case 'sl',   labels = { 'Slip Length'     'lslip' };
case 'tn',   labels = { 'Normal Traction' 'Tn' };
case 'ts',   labels = { 'Shear Traction'  'Ts' };
case 'trup', labels = { 'Rupture Time'    'trup' };
case 'tarr', labels = { 'Arrest Time'     'tarr' };
otherwise error 'vizfield'
end

cellfocus = 0;
switch field(1)
case 'a', fmax = amax; fmaxi = amaxi;
case 'v', fmax = vmax; fmaxi = vmaxi;
case 'u', fmax = umax; fmaxi = umaxi;
case 'w', fmax = wmax; fmaxi = wmaxi; cellfocus = 1;
end

