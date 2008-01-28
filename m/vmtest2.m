% CVM test

clear all
meta
nn = nn(1:2);
clf
lon = readf32( 'rlon', nn );
lat = readf32( 'rlat', nn );
vs  = readf32( 'vs30', nn );
pcolor( lon, lat, vs )

