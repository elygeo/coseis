% Set the axes size when the window is resized

u = 12;
hfig = gcf;
pos = get( hfig, 'Position' );
set( haxes, 'Units', 'pixels' );
set( haxes(1), 'Position', [ 0 4*u  pos(3)     pos(4)-4*u ] );
set( haxes(2), 'Position', [ u 5*u  pos(3)-2*u pos(4)-6*u ] );
set( haxes(3), 'Position', [ 0 0    pos(3)     4*u        ] );
set( haxes(4), 'Position', [ u u .2*pos(3)-2*u 2*u        ] );
set( haxes, 'Units', 'normalize' );

