%------------------------------------------------------------------------------%
% ZONESELECT

function [ i1, i2 ] = zoneselect( zone, halo1, ncore, hypocenter, nrmdim )

i1 = zone(1:3);
i2 = zone(4:6);
hypocenter = hypocenter - halo1;
shift = [ 0 0 0 ];
if nrmdim, shift(nrmdim) = 1; end
i = i1 == 0; i1(i) = hypocenter(i) + shift(i);
i = i2 == 0; i2(i) = max( hypocenter(i), i1(i) );
i = i1 < 0;  i1(i) = i1(i) + ncore(i) + 1;
i = i2 < 0;  i2(i) = i2(i) + ncore(i) + 1;
i1 = max( i1, 0 );
i2 = min( i2, ncore + 1 );
i1 = i1 + halo1;
i2 = i2 + halo1;

