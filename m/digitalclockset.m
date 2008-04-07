% Set time for digital clock
function [ h ] = digitalclockset( varargin )

t = 0;
hclk = varargin{1};
if nargin >= 2, t = varargin{2}; end

m = floor( t / 60 );
s10 = floor( mod( t, 60 ) / 10 );
s1 = floor( mod( t, 10 ) );
set( hclk, 'Visible', 'off' )
set( [ hclk(1,m+1) hclk(2,s10+1) hclk(3,s1+1) hclk(1,11) ], 'Visible', 'on' )

