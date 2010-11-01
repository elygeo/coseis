"""
WebSims: Web-based Earthquake Simulation Data Management
--------------------------------------------------------

WebSims is a web application for cataloging, exploring, comparing and
disseminating four-dimensional results of large numerical simulations.  Time
histories and two-dimensional slices can be plotted or extracted and downloaded
via a clickable interface or by specifying exact coordinates.  Time histories
may be low-pass filtered, and multiple simulations may be overlayed for
comparison.  A well defined URL scheme for specifying extractions allows the
web interface to be bypassed, allowing for batch scripting of jobs.  This
version of WebSims replaces a previous PHP implementation.  It is written in
Python_ using the NumPy_, SciPy_, and Matplotlib_ modules for processing and
visualization.  Metadata is stored with each simulation in the form of a Python
module.  The web pages are served by web.py_, a minimalist web application
framework.  WebSims is license under under the GPLv3 and is available as part
of the Computational Siesmology Tools (Coseis_).

.. _Python:     http://www.python.org/
.. _NumPy:      http://numpy.scipy.org/
.. _SciPy:      http://www.scipy.org/
.. _Matplotlib: http://matplotlib.sourceforge.net/
.. _web.py:     http://webpy.org/
.. _Coseis:     http://earth.usc.edu/~gely/coseis/www/
"""
import os, sys, re, gzip, time, cStringIO, shutil, itertools
import numpy as np
import web, jinja2, docutils.core
from . import conf, plot
from .. import util

port = '8081'
cache_max_age = 86400
cache_max_age = 0
urls = (
    '/websims/app',			'main',
    '/websims/app/image/(.+)',		'image',
    '/websims/app/download/(.+)',	'download',
    '/websims/app/click1d/(.+)',	'click1d',
    '/websims/app/click2d/(.+)',	'click2d',
    '/websims/(.*)',			'serve_static',
)

templates = os.path.join( os.path.dirname( __file__ ), 'templates' )
loader = jinja2.FileSystemLoader( templates )
jinja_env = jinja2.Environment( loader=loader )


def prep():
    """
    Prepare static files.
    """
    d = os.path.dirname( __file__ )
    for f in os.listdir( os.path.join( d, 'static' ) ):
        f1 = os.path.join( d, 'static', f )
        shutil.copy2( f1, f )
    content = docutils.core.publish_parts( __doc__, writer_name='html4css1' )['body']
    html = jinja_env.get_template( 'base.html' )
    html = html.render( title='About WebSims', content=content )
    open( os.path.join( 'about.html' ), 'w' ).write( html )
    index()
    return


def start( debug=True ):
    """
    Start server.
    """
    print time.strftime( '%Y-%m-%d %H:%M:%S: WebSims started', time.localtime() )
    sys.argv = [sys.argv[0], port]
    web.config.debug = debug
    app.run()
    return


class serve_static():
    """
    Serve static files with built-in CherryPy server.
    """
    def GET( self, url ):
        raise web.seeother( '/static/' + url )


def findmembers( top='.', path='', member='.member', group='.group', ignore='.ignore' ):
    """
    Walk thourgh directory tree looking for members and groups.
    """
    if os.path.exists( os.path.join( top, path, ignore ) ):
        return []
    if os.path.exists( os.path.join( top, path, member ) ):
        return [path]
    grouping = group and os.path.exists( os.path.join( top, path, group ) )
    if grouping:
        group = False
    list_ = []
    for f in os.listdir( os.path.join( top, path ) ):
        f = os.path.join( path, f )
        if os.path.isdir( os.path.join( top, f ) ):
            list_ += findmembers( top, f, member, group, ignore )
    if grouping:
        list_ = [ sorted( list_ ) ]
    return sorted( list_ )


def index( query={} ):
    """
    Build list of simulations.
    """
    if 'search' in query:
        grep = re.compile( query.search, re.IGNORECASE )
    items = []
    include = True
    for ids in findmembers( conf.repo[0], '', conf.meta, '.wsgroup', '.wsignore' ):
        grouped = False
        if type( ids ) == str:
            ids = [ids]
        elif len( ids ) > 1:
            grouped = True
        for id_ in sorted( ids ):
            path = os.path.join( conf.repo[0], id_, conf.meta )
            code = open( path, 'r' ).read()
            if 'search' in query:
                include = grep.search( code )
            if include:
                meta = dict()
                try:
                    exec code in meta
                except:
                    meta = dict( title='ERROR', author='', rundate='' )
                meta.update(
                    id = id_,
                    grouped = grouped,
                    meta  = 'repo/' + id_ + '/' + conf.meta,
                    index = 'repo/' + id_ + '/' + conf.index,
                    files = 'repo/' + id_ + '/',
                )
                items += [meta]

                # cache to disk if not static
                if 'search' not in query:
                    show2d( web.storage( ids=id_ ) )

        # mark last member of a group for submit button
        if len( items ) and items[-1]['grouped']:
            items[-1].update( endgroup=True )

    # process template
    html = jinja_env.get_template( 'index.html' )
    html = html.render( title='WebSims', items=items, **query )

    # cache to disk if not static
    if 'search' not in query:
        open( os.path.join( 'index.html' ), 'w' ).write( html )

    return html


def error( message ):
    """
    Error page.
    """
    content = '<h2>Error</h2>\n<div>%s</div>\n' % message
    html = jinja_env.get_template( 'base.html' )
    html = html.render( title='Error', base='/websims/', content=content )
    web.header( 'Content-Type', 'text/html' )
    web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
    return html


def show2d( query ):
    """
    2D slice page.
    """

    # parameters
    img_ext = '.png'
    ids = query.ids.split( ',' )
    compare = len( ids ) > 1
    snapshot = 't' in query
    cache = not snapshot and 'decimate' not in query
    cache_html = not snapshot and 'decimate' not in query and not compare
    groups = set( i.split( '/' )[0] for i in ids )
    if len( groups ) > 1:
        return error( 'Incompatible comparison: %s' % list( groups ) )

    # lists
    x_ids = []
    t_ids = []
    plots = []
    downloads = []

    # loop over ids
    for id_ in ids:

        # metadata
        meta = os.path.join( conf.repo[0], id_, conf.meta )
        meta = util.load( meta )
        delta = meta.x_delta
        shape = meta.x_shape
        panes = meta.x_static_panes
        #dtype = np.dtype( meta.dtype )
        #ext = '.%s%s' % (dtype.kind, 8 * dtype.itemsize)
        ext = '.bin'
        indices = [0, 0] + [1] * (len( shape ) - 2)
        if snapshot:
            panes = meta.x_panes
            indices[-1] = int( float( query.t ) / delta[-1] + 1.5 )
        indices = ','.join( [ str(i) for i in indices ] )
        if meta.x_panes:
            x_ids += [id_]
        if meta.t_panes:
            t_ids += [id_]
        plots += [[]]
        downloads += [[]]

        # loop over panes
        for pane in panes:

            # plots
            path = root = pane[0]
            if path.endswith( ext ):
                root = os.path.splitext( path )[0]
            img_path = root + img_ext
            if cache:
                plot.plot2d( id_, img_path )
                if cache_html:
                    url = img_path
                else:
                    url = 'repo/%s/%s' % (id_, img_path)
            else:
                url = '/websims/app/image/%s?ids=%s' % (img_path, id_)
                for k in 't', 'decimate':
                    if k in query:
                        url += '&%s=%s' % (k, query[k])
            plots[-1] += [url]

            # downloads
            if cache:
                if cache_html:
                    url = path
                else:
                    url = 'repo/%s/%s' % (id_, path)
            else:
                url = '/websims/app/download/%s?ids=%s&j=%s' % (path, id_, indices)
            downloads[-1] += [ dict(
                label = '%s%s, shape=%s' % (meta.label, pane[1], shape[:2]),
                root = os.path.basename( path ),
                url = url,
            ) ]

    # metadata
    plots = list( itertools.chain( *itertools.izip_longest( *plots ) ) )
    downloads = list( itertools.chain( *itertools.izip_longest( *downloads ) ) )
    x_ids = ','.join( x_ids )
    t_ids = ','.join( t_ids )
    click = '/websims/app/click2d/' + t_ids
    axes = ','.join( meta.t_axes[1:] )
    xlim = [ abs(n * d) for n, d in zip( meta.t_shape[1:], meta.t_delta[1:] ) ]
    xlim = ', '.join( [ '0-%g%s' % (l, u) for l, u in zip( xlim, meta.t_unit[1:] ) ] )
    flim = '0-%g%s' % (0.5 / meta.t_delta[0], 'Hz')
    tlim = '0-%g%s' % (meta.x_delta[-1] * meta.x_shape[-1], meta.x_unit[-1])
    title = meta.title
    if snapshot:
        subtitle = meta.x_title
    else:
        subtitle = meta.x_static_title
    if cache_html:
        home = conf.index
        base = '../' * (len( ids[0].split( '/' ) ) + 1)
    elif compare:
        home = '/websims/app?ids=' + query.ids
        base = ''
    else:
        home = 'repo/' + query.ids + '/' + conf.index
        base = ''
    if hasattr( meta, 'notes' ):
        notes = docutils.core.publish_parts( meta.notes, writer_name='html4css1' )['body']
    else:
        notes = ''
    tooltip = 'Click axes location for time history plot.'

    # process template
    html = jinja_env.get_template( 'show.html' )
    html = html.render(
        base=base, home=home, title=title, subtitle=subtitle, notes=notes,
        axes=axes, xlim=xlim, flim=flim, tlim=tlim, x_ids=x_ids, t_ids=t_ids,
        tooltip=tooltip, click=click, plots=plots, downloads=downloads, **query
    )

    # cache to disk if static
    if cache_html:
        f = os.path.join( conf.repo[0], ids[0], conf.index )
        open( f, 'w' ).write( html )

    return html


def show1d( query ):
    """
    Time history page
    """

    # parameters
    img_ext = '.png'
    xx = query.x.split( ',' )
    ids = query.ids.split( ',' )
    compare = len( ids ) > 1

    # lists
    x_ids = []
    t_ids = []
    plots = []
    downloads = []

    # loop over ids
    for id_ in ids:

        # metadata
        meta = os.path.join( conf.repo[0], id_, conf.meta )
        meta = util.load( meta )
        if meta.x_panes:
            x_ids += [id_]
        if meta.t_panes:
            t_ids += [id_]

        # downloads
        if meta.downloadable:
            downloads += [[]]
            shape = meta.t_shape[1:]
            delta = meta.t_delta[1:]
            indices = ['0']
            for x, d, n in zip( xx, delta, shape ):
                i = int( float( x ) / abs( d ) + 1.5 )
                indices += [str(i)]
                if i < 1 or i > n:
                    return error( 'Location (%(x)s) out of range' % query.x )
            indices = ','.join( [ str(i) for i in indices ] )
            for pane in meta.t_panes:
                if len( pane ) <= 2 or pane[2] == None:
                    for path in pane[0]:
                        url = '/websims/app/download/%s?ids=%s&j=%s' % (path, id_, indices)
                        downloads[-1] += [ dict(
                            url = url,
                            root = os.path.basename( path ),
                            label = '%s%s' % (meta.label, pane[1]),
                        ) ]

    # metadata
    downloads = list( itertools.chain( *itertools.izip_longest( *downloads ) ) )
    title = meta.title
    subtitle = meta.t_title
    x_ids = ','.join( x_ids )
    t_ids = ','.join( t_ids )
    axes = ','.join( meta.t_axes[1:] )
    xlim = [ abs(n * d) for n, d in zip( meta.t_shape[1:], meta.t_delta[1:] ) ]
    xlim = ', '.join( [ '0-%g%s' % (l, u) for l, u in zip( xlim, meta.t_unit[1:] ) ] )
    flim = '0-%g%s' % (0.5 / meta.t_delta[0], 'Hz')
    tlim = '0-%g%s' % (meta.x_delta[-1] * meta.x_shape[-1], meta.x_unit[-1])
    if compare:
        home = '/websims/app?ids=' + query.ids
    else:
        home = 'repo/' + query.ids + '/' + conf.index
    if hasattr( meta, 'notes' ):
        notes = docutils.core.publish_parts( meta.notes, writer_name='html4css1' )['body']
    else:
        notes = ''
    tooltip = 'Click time axis for snapshot plot.'

    # urls
    click = '/websims/app/click1d/' + x_ids
    img = '/websims/app/image/plot' + img_ext + '?ids=' + query.ids
    for k in 'x', 'lowpass':
        if k in query:
            img += '&%s=%s' % (k, query[k])
    plots = [img]

    # process template
    html = jinja_env.get_template( 'show.html' )
    html = html.render(
        home=home, title=title, subtitle=subtitle, notes=notes,
        axes=axes, xlim=xlim, flim=flim, tlim=tlim, x_ids=x_ids, t_ids=t_ids,
        tooltip=tooltip, click=click, plots=plots, downloads=downloads, **query
    )

    return html


class main:
    """
    Main dispatch page.
    """
    def GET( self ):
        web.header( 'Content-Type', 'text/html' )
        query = web.input( ids=[] )
        query.ids = ','.join( query.ids )
        if not query.ids:
            web.header( 'Cache-Control', 'max-age=%s' % 60 )
            return index( query )
        elif 'x' in query:
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            return show1d( query )
        else:
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            return show2d( query )


class image:
    def GET( self, filename ):
        web.header( 'Content-Type', 'image/png' )
        web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
        query = web.input( ids=[], decimate='', lowpass='' )
        query.ids = ','.join( query.ids )
        if 'x' in query:
            return plot.plot1d( query.ids, query.x, query.lowpass )
        else:
            return plot.plot2d( query.ids, filename, query.t, query.decimate )


class click2d:
    """
    Click 2d axes and load 1d plot.
    """
    def GET( self, id_ ):
        query = web.input()
        x = '0.0'
        if len( query ) > 0:
            ids = id_.split(',')
            path = os.path.join( conf.repo[0], ids[0], conf.meta )
            meta = util.load( path )
            jj = query.keys()[0].split(',')
            ndim = len( meta.x_shape )
            shape = meta.x_shape[:-1]
            delta = meta.x_delta[:-1]
            aspect = abs( delta[1] / delta[0] ) * shape[1] / shape[0]
            if aspect < 1.:
                j0 = 100, 50 + int( aspect * 800 )
                j1 = 900, 50
            else:
                jj = jj[::-1]
                j0 = 50 + int( 1.0 / aspect * 800 ), 100
                j1 = 50, 900
            x = (ndim - 1) * ['1']
            for i in 0, 1:
                j = int( jj[i] ) % (j0[i] + j1[i])
                j = (int( jj[i] ) - j0[i]) * (shape[i] - 1) // (j1[i] - j0[i]) + 1
                j = max( 1, min( shape[i], j ) )
                if delta[i] < 0.0:
                    j = shape[i] - j + 1
                x[i] = str( (j - 1) * abs( delta[i] ) )
            x = ','.join( x )
        raise web.seeother( '/websims/app?ids=%s&x=%s' % (id_, x) )


class click1d:
    """
    Click plot time axis and load time slice.
    """
    def GET( self, id_ ):
        query = web.input()
        t = '0.0'
        if len( query ) > 0:
            ids = id_.split(',')
            path = os.path.join( conf.repo[0], ids[0], conf.meta )
            meta = util.load( path )
            j  = int( query.keys()[0].split(',')[0] )
            nt = meta.x_shape[-1]
            dt = meta.x_delta[-1]
            j0 = 100
            j1 = 900
            j  = (j - j0) * (nt - 1) // (j1 - j0) + 1
            j  = max( 1, min( nt, j ) )
            t  = str( (j - 1) * dt )
        raise web.seeother( '/websims/app?ids=%s&t=%s' % (id_, t) )


class download:
    def GET( self, filename ):
        query = web.input()
        path = os.path.join( conf.repo[0], query.ids, conf.meta )
        meta = util.load( path )
        indices = [ int(i) for i in query.j.split( ',' ) ]
        found = True
        if filename in [ f for pane in meta.t_panes for f in pane[0] ]:
            shape = meta.t_shape
        elif filename in [ pane[0] for pane in meta.x_panes ]:
            shape = meta.x_shape
        elif filename in [ pane[0] for pane in meta.x_static_panes ]:
            shape = list( meta.x_shape[:-1] ) + [1]
        else:
            found = False
        for d in conf.repo:
            path = os.path.join( d, query.ids, filename )
            if os.path.exists( path ):
                break
        else:
            found = False
        if not found:
            web.header( 'Content-Type', 'text/html' )
            raise web.notfound()
        v = util.ndread( path, shape, indices, dtype=meta.dtype )
        web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
        web.header( 'Content-Type', 'application/octet-stream' )
        return v.tostring()


app = web.application( urls, globals() )

