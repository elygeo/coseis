%------------------------------------------------------------------------------%
% ZONESELECT

function [ i1, i2 ] = zoneselect( zone, skip, core, hypocenter, nrmdim )

zone = zone(skip+1:end);
i1 = zone(1:2:5);
i2 = zone(2:2:6);
oc = core(1:2:5) - 1;
nc = core(2:2:6) - oc;
hypocenter = hypocenter - oc;
shift = [ 0 0 0 ];
if nrmdim, shift(nrmdim) = 1; end
i = i1 == 0; i1(i) = hypocenter(i) + shift(i);
i = i2 == 0; i2(i) = max( hypocenter(i), i1(i) );
i = i1 < 0;  i1(i) = i1(i) + nc(i) + 1;
i = i2 < 0;  i2(i) = i2(i) + nc(i) + 1;
i1 = max( i1, 0 );
i2 = max( i2, 0 );
i1 = min( i1, nc + 1 );
i2 = min( i2, nc + 1 );
i1 = i1 + oc;
i2 = i2 + oc;

