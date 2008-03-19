% Plot a digital clock
function [ h ] = digitalclock( varargin )

xx = varargin{1};
yy = varargin{2};
s = 1;
c = 'g';
if nargin >= 3, s = varargin{3}; end
if nargin >= 4, c = varargin{4}; end

s = s / 200;
xx = xx + s * [ 0 200 350 ];
xdig = s * [ 11 20 nan; 111 120 nan; 0 9 nan; 100 109 nan; 30 110 nan; 20 100 nan; 10 90 nan ]';
ydig = s * [ 110 190 nan; 110 190 nan; 10 90 nan; 10 90 nan; 200 200 nan; 100 100 nan; 0 0 nan ]';
idig = { 6 [ 1 3 5 6 7 ] [ 1 4 ] [ 1 3 ] [ 3 5 7 ] [ 2 3 ] 2 [ 1 3 6 7 ] [] 3 };
for j = 1:3
for i = 1:10
  ii = 1:7;
  ii(idig{i}) = [];
  x = xx(j) + xdig(:,ii);
  y = yy + ydig(:,ii);
  h(j,i) = plot( x(:), y(:), '-', 'LineWidth', .75, 'Color', c );
  hold on
end
end
x = xx(1) + s * [ 155 165 ];
y = yy + s * [ 50 150 ];
h(:,11) = plot( x, y, 's', 'MarkerSize', 1, 'MarkerFaceColor', c, 'MarkerEdgeColor', 'none' );
set( h, 'Tag', c )

