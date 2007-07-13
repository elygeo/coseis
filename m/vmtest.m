%SCEVM test

meta
clf
subplot(3,1,1), f = readf32( 'rho', nn ); imagesc( f ), axis equal tight; title( '\rho' ); colorbar
subplot(3,1,2), f = readf32( 'vp',  nn ); imagesc( f ), axis equal tight; title( 'V_p' ); colorbar
subplot(3,1,3), f = readf32( 'vs',  nn ); imagesc( f ), axis equal tight; title( 'V_s' ); colorbar
colormap( flipud( jet ) )

