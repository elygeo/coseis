% Field information

labels = fieldlabels( field, 0 );
cellfocus = any( strcmp( field, { 'w', 'wm' } ) );
isfault = any( strcmp( field, { 'nhat' 't0' 'mus' 'mud' 'dc' 'co' 'sa' 'sv' 'su' 'ts' 't' 'sam' 'svm' 'sum' 'tnm' 'tsm' 'sl' 'f' 'svp' 'trup' 'tarr' } ) );

fmaxi = [ 0 0 0 ];
fmax = max(s(:));

switch field
case 'x',            fmax = 2*rmax; fmaxi = nn;
case { 'a'  'am'  }, fmax = amax; fmaxi = amaxi;
case { 'v'  'vm'  }, fmax = vmax; fmaxi = vmaxi;
case { 'u'  'um'  }, fmax = umax; fmaxi = umaxi;
case { 'w'  'wm'  }, fmax = wmax; fmaxi = wmaxi;
case { 'sa' 'sam' }, fmax = samax; fmaxi = samaxi;
case { 'sv' 'svm' }, fmax = svmax; fmaxi = svmaxi;
case { 'su' 'sum' }, fmax = sumax; fmaxi = sumaxi;
case { 'ts' 'tsm' }, fmax = tsmax; fmaxi = tsmaxi;
case 'tnm',          fmax = tnmax; fmaxi = tnmaxi;
case 'sl',           fmax = slmax; fmaxi = slmaxi;
case 'tarr',         fmax = tarrmax; fmaxi = tarrmaxi;
case 'nhat',         fmax = 1;
end

