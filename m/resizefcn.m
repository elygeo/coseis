% Set the axes size when the window is resized

hfig = gcf;
pos = get( hfig, 'Position' );
set( haxes, 'Units', 'pixels' );
set( haxes(1), 'Position', [        0 30 pos(3)    pos(4)-30 ] );
set( haxes(2), 'Position', [        8 38 pos(3)-16 pos(4)-46 ] );
set( haxes(3), 'Position', [         0 0 pos(3)           30 ] );
set( haxes(4), 'Position', [         0 6 pos(3)*.2        18 ] );
set( haxes(5), 'Position', [ pos(3)*.8 6 pos(3)*.2        18 ] );
set( haxes, 'Units', 'normalize' );

