% Set the axes size when the window is resized

u = 5;
hfig = gcf;
pos = get( hfig, 'Position' );
set( haxes, 'Units', 'pixels' );
set( haxes(1), 'Position', [ 0 6*u  pos(3)     pos(4)-6*u ] );
set( haxes(2), 'Position', [ u 7*u  pos(3)-2*u pos(4)-8*u ] );
set( haxes(3), 'Position', [ 0 0    pos(3)     6*u        ] );
set( haxes(4), 'Position', [ u u .2*pos(3)-2*u 4*u        ] );
set( haxes, 'Units', 'normalize' );

