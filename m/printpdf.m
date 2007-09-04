% Print file to EPS and convert to PDF
function printpdf( varargin )
crop = 1;
file = 'fig';
if nargin > 0, file = varargin{1}; end
if nargin > 1, crop = 0; end
print( '-depsc', file )
movefile( [ file '.eps' ], 'tmp.eps' )
if crop
  !sed '/% macros for lines/i/DA { [1 dpi2point mul] 0 setdash } bdef /DD { [.5 dpi2point mul 1 dpi2point mul 6 dpi2point mul 1 dpi2point mul] 0 setdash } bdef' tmp.eps | ps2pdf14 -dPDFSETTINGS=/prepress -dEPSCrop - tmp.pdf
else
  !sed 's|/DA { \[6|/DA { \[1|' tmp.eps | ps2pdf14 -dPDFSETTINGS=/prepress - tmp.pdf
end

movefile( 'tmp.pdf', [ file '.pdf' ] )
delete( 'tmp.eps' )

