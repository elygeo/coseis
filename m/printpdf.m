% Print file to EPS and convert to PDF
function printpdf( varargin )
file = 'fig';
if nargin > 0, file = varargin{1}; end
set( gcf, 'InvertHardCopy', 'off' )
print( '-depsc', file )
movefile( [ file '.eps' ], 'tmp.eps' )
!sed 's|/DA { \[6|/DA { \[1|' tmp.eps | ps2pdf14 -dPDFSETTINGS=/prepress -dEPSCrop - tmp.pdf
movefile( 'tmp.pdf', [ file '.pdf' ] )
delete( 'tmp.eps' )

