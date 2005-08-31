%------------------------------------------------------------------------------%
% ZONESELECT

function [ i1, i2 ] = zoneselect( zone, nn, offset, hypocenter, nrmdim )

i1 = zone(1:3);
i2 = zone(4:6);
shift = [ 0 0 0 ];
if nrmdim, shift(nrmdim) = 1; end
m0 = i1 == 0 & i2 == 0;
m1 = i1 == 0 & i2 ~= 0;
m2 = i1 ~= 0 & i2 == 0;
m3 = i1 < 0;
m4 = i2 < 0;
i1(m0) = hypocenter(m0) - offset(m0);
i2(m0) = hypocenter(m0) - offset(m0) + shift(m0);
i1(m1) = hypocenter(m1) - offset(m1) + shift(m1);
i2(m2) = hypocenter(m2) - offset(m2);
i1(m3) = i1(m3) + nn(m3) + 1;
i2(m4) = i2(m4) + nn(m4) + 1;
i1 = max( i1, 1 );
i2 = min( i2, nn );
i1 = i1 + offset;
i2 = i2 + offset;

