if 0
syms t T f F r
s = t / sqrt( t ^ 2 - r ^ 2 ) * heaviside( t - r )
s = t / sqrt( t ^ 2 - r ^ 2 )
%S = simple( int( s * exp( -i * 2 * pi * f * t ), t, r, inf ) )
%sinc = simple( int( exp( i * 2 * pi * f * t ), f, -F, F ) )
%s = subs( s, t, T - t )
sinc = sin( 2 * pi * F * t ) / ( pi * t )
sinc = subs( sinc, t, T - t )
%ss = int( s * sinc, t, -inf, inf )
ss = int( s * sinc, t, r, inf )
end

clear all

fc = 5
C = .81
miu = 3.2040e+10
vs  = 3464.1
vrup = .9 * vs
dT = 10e6
t = 0:.01:4;
r = 2000;

s = C * dT / miu * vs * t ./ sqrt( t .^ 2 - ( r / vrup ) .^ 2 ) .* heaviside( t - r / vrup );

figure(1)
clf
plot( t, s )

rr = 0:80:8000;
sbar = C * dT / miu * vs * ( 2 * rr * fc / vrup + 1 ) .^ .5;
figure(2)
clf
plot( rr, sbar )
