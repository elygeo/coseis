% Set the axes size when the window is resized

hfig = gcf;
pos = get( hfig, 'Position' );
set( haxes, 'Units', 'pixels' );
set( haxes(1), 'Position', [  0 30 pos(3)    pos(4)-30 ] );
set( haxes(2), 'Position', [  8 38 pos(3)-16 pos(4)-46 ] );
set( haxes(3), 'Position', [  0  0 pos(3)           30 ] );
%set( haxes(4), 'Position', [  6  6 18 18 ] );
%set( haxes(5), 'Position', [ 30  6 27 18 ] );
set( haxes(4), 'Position', [ pos(3)-57 6 18 18 ] );
set( haxes(5), 'Position', [ pos(3)-33 6 27 18 ] );
set( haxes, 'Units', 'normalize' );

