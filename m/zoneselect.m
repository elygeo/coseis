%------------------------------------------------------------------------------%
% ZONESELECT

function [ i1, i2 ] = zoneselect( zone, nhalo, n, hypocenter, nrmdim )

i1 = zone(1:3);
i2 = zone(4:6);
hypocenter = hypocenter - nhalo;
shift = [ 0 0 0 ];
if nrmdim, shift(nrmdim) = 1; end
i = i1 == 0 & i2 == 0;
i1(i) = hypocenter(i);
i2(i) = hypocenter(i) + shift(i);
i = i1 == 0; i1(i) = hypocenter(i) + shift(i);
i = i2 == 0; i2(i) = hypocenter(i);
i = i1 < 0;  i1(i) = i1(i) + n(i) + 1;
i = i2 < 0;  i2(i) = i2(i) + n(i) + 1;
i1 = max( i1, 1 );
i2 = min( i2, n );
i1 = i1 + nhalo;
i2 = i2 + nhalo;

