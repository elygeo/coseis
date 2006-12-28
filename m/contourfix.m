function [ c ] = contourfix( c )

i = 1;
while i < size( c, 2 )
  n = c(2,i);
  c(:,i) = nan; 
  i = i + n + 1; 
end 

