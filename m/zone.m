function [ i1, i2 ] = zone( i1, i2, nn, noff, ihypo, ifn )

shift = [ 0 0 0 ];
if ifn, shift(ifn) = 1; end

m0 = i1 == 0 & i2 == 0;
m1 = i1 == 0 & i2 ~= 0;
m2 = i1 ~= 0 & i2 == 0;
m3 = i1 < 0;
m4 = i2 < 0;

i1(m0) = ihypo(m0) - noff(m0);
i2(m0) = ihypo(m0) - noff(m0) + shift(m0);
i1(m1) = ihypo(m1) - noff(m1) + shift(m1);
i2(m2) = ihypo(m2) - noff(m2);
i1(m3) = i1(m3) + nn(m3) + 1;
i2(m4) = i2(m4) + nn(m4) + 1;

i1 = max( i1, 1 );
i2 = min( i2, nn );

i1 = i1 + noff;
i2 = i2 + noff;

