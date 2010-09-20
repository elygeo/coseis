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
import os, sys, signal, re, gzip, time, cStringIO, shutil
import numpy as np
import web
from docutils.core import publish_parts
from . import conf, html, plot
from .. import util

port = '8081'
baseurl = '/websims'
cache_max_age = 86400
urls = (
    baseurl + '/app',			'main',
    baseurl + '/app/image/(.+)',	'image',
    baseurl + '/app/download/(.+)',	'download',
    baseurl + '/app/click1d/(.+)',	'click1d',
    baseurl + '/app/click2d/(.+)',	'click2d',
    baseurl + '(.*)',			'serve_static',
)


class wtf():
    def GET( self, url ):
        return url


class serve_static():
    def GET( self, url ):
        raise web.seeother( '/static' + url )


def start( debug=True ):
    print time.strftime( '%Y-%m-%d %H:%M:%S: WebSims started', time.localtime() )
    sys.argv = [sys.argv[0], port]
    web.config.debug = debug
    d = os.path.dirname( __file__ )
    for f in os.listdir( os.path.join( d, 'static' ) ):
        f1 = os.path.join( d, 'static', f )
        f2 = os.path.join( 'static', f )
        shutil.copy2( f1, f2 )
    about = publish_parts( __doc__, writer_name='html4css1' )['body']
    about = (
        html.main.head % dict( title='About WebSims', baseurl=baseurl, search='', style=html.style ) +
        html.main.section % dict( title='About WebSims', content=about ) +
        html.main.foot
    )
    open( os.path.join( 'static', 'about.html' ), 'w' ).write( about )
    index()
    app.run()
    return


class main:
    def GET( self ):
        w = web.input( ids=[], t='', decimate='', x='', lowpass='', search='' )
        w.ids = ','.join( w.ids )
        w.title = 'WebSims'
        w.baseurl = baseurl
        w.ext = '.png'
        web.header( 'Content-Type', 'text/html' )
        if w.ids == '':
            web.header( 'Cache-Control', 'max-age=%s' % 60 )
            return index( w )
        elif w.x != '':
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            return show1d( w )
        else:
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            return show2d( w )


class image:
    def GET( self, filename ):
        w = web.input( ids=[], t='', decimate='', x='', lowpass='' )
        ids = ','.join( w.ids ).split(',')
        web.header( 'Content-Type', 'image/png' )
        web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
        if w.x != '':
            return plot.plot1d( ids, filename, w.x, w.lowpass )
        else:
            return plot.plot2d( ids[0], filename, w.t, w.decimate )


class click2d:
    """
    Click 2d axes and load 1d plot.
    """
    def GET( self, id_ ):
        w = web.input()
        x = '0.0'
        if len( w ) > 0:
            ids = id_.split(',')
            f  = os.path.join( conf.repo[0], ids[0], conf.meta )
            m  = util.load( f )
            jj = w.keys()[0].split(',')
            ndim = len( m.x_shape )
            it = list( m.x_axes ).index( 'Time' )
            ix = [ i for i in range(ndim) if i != it and m.x_shape[i] > 1 ]
            nn = [ m.x_shape[i] for i in ix ]
            dx = [ m.x_delta[i] for i in ix ]
            aspect = abs( dx[1] / dx[0] ) * nn[1] / nn[0]
            if aspect < 1.:
                j0 = 100, 50 + int( aspect * 800 )
                j1 = 900, 50
            else:
                jj = jj[::-1]
                j0 = 50 + int( 1.0 / aspect * 800 ), 100
                j1 = 50, 900
            x = len(ix) * ['1']
            for i in 0, 1:
                j = int( jj[i] ) % (j0[i] + j1[i])
                j = (int( jj[i] ) - j0[i]) * (nn[i] - 1) // (j1[i] - j0[i]) + 1
                j = max( 1, min( nn[i], j ) )
                if dx[i] < 0.0:
                    j = nn[i] - j + 1
                x[i] = str( (j - 1) * abs( dx[i] ) )
            x = ','.join( x )
        raise web.seeother( '%s/app?ids=%s&x=%s' % (baseurl, id_, x) )


class click1d:
    """
    Click plot time axis and load time slice.
    """
    def GET( self, id_ ):
        w = web.input()
        t = '0.0'
        if len( w ) > 0:
            ids = id_.split(',')
            f  = os.path.join( conf.repo[0], ids[0], conf.meta )
            m  = util.load( f )
            j  = int( w.keys()[0].split(',')[0] )
            it = list( m.x_axes ).index( 'Time' )
            nt = m.x_shape[it]
            dt = m.x_delta[it]
            j0 = 100
            j1 = 900
            j  = (j - j0) * (nt - 1) // (j1 - j0) + 1
            j  = max( 1, min( nt, j ) )
            t  = str( (j - 1) * dt )
        raise web.seeother( '%s/app?ids=%s&t=%s' % (baseurl, id_, t) )


class download:
    def GET( self, filename ):
        w = web.input()
        f = os.path.join( conf.repo[0], w.ids, conf.meta )
        m = util.load( f )
        indices = [ int(i) for i in w.j.split( ',' ) ]
        root, ext = os.path.splitext( filename )
        found = True
        if root in [ f for pane in m.t_panes for f in pane[0] ]:
            shape = m.t_shape
        elif root in [ pane[0] for pane in m.x_panes ]:
            shape = m.x_shape
        elif root in [ pane[0] for pane in m.x_static_panes ]:
            shape = list( m.x_shape )
            it = list( m.x_axes ).index( 'Time' )
            shape[it] = 1
        else:
            found = False
        for d in conf.repo:
            f = os.path.join( d, w.ids, root )
            if os.path.exists( f ):
                break
        else:
            found = False
        if not found:
            web.header( 'Content-Type', 'text/html' )
            raise web.notfound()
        v = util.ndread( f, shape, indices, dtype=m.dtype )
        web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
        if ext == '.txt':
            out = cStringIO.StringIO()
            np.savetxt( out, v )
            web.header( 'Content-Type', 'text/plain' )
            return out.getvalue()
        elif ext == '.gz':
            out = cStringIO.StringIO()
            gz = gzip.GzipFile( root, 'wb', 9, out )
            np.savetxt( gz, v )
            gz.close()
            web.header( 'Content-Type', 'application/x-gzip' )
            return out.getvalue()
        elif ext == '.f32':
            web.header( 'Content-Type', 'application/octet-stream' )
            return v.tostring()
        else:
            print( 'Unknown file type: ' + filename )
            web.header( 'Content-Type', 'text/html' )
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            out = (
                html.main.head +
                '<h2>Error</h2>\n' +
                '<div>Unknown file type: %s</div>\n' % filename +
                html.main.foot
            )
            return out % dict( title='WebSims', baseurl=baseurl, search='', style=html.style )


def findmembers( top='.', path='', member='.member', group='.group', ignore='.ignore' ):
    """
    Walk thourgh directory tree looking for members and groups
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


def index( w=web.storage( search='' ) ):
    """
    Build list of simulations.
    """
    out = html.main.head + html.index.head
    include = True
    if w.search:
        grep = re.compile( w.search, re.IGNORECASE )
    list_ = findmembers( conf.repo[0], '', conf.meta, '.wsgroup', '.wsignore' )
    for ids in list_:
        if type( ids ) == str:
            f = os.path.join( conf.repo[0], ids, conf.meta )
            if w.search:
                include = grep.search( open( f, 'r' ).read() )
            if include:
                d = dict()
                try:
                    exec open( f ) in d
                except:
                    d.update( title='ERROR', author='', rundate='' )
                d.update( baseurl=baseurl, id=ids, index=conf.index, meta=conf.meta )
                out += html.index.item_solo % d
                if not w.search:
                    d = web.storage( ids=ids, t='', decimate='', x='', lowpass='',
                        search='', baseurl=baseurl, ext='.png', disk=True )
                    show2d( d )
        else:
            group = ''
            for id_ in sorted( ids ):
                f = os.path.join( conf.repo[0], id_, conf.meta )
                if w['search']:
                    include = grep.search( open( f, 'r' ).read() )
                if include:
                    d = dict()
                    try:
                        exec open( f ) in d
                    except:
                        d.update( title='ERROR', author='', rundate='' )
                    d.update( baseurl=baseurl, id=id_, index=conf.index, meta=conf.meta )
                    group += html.index.item_grouped % d
                    if not w.search:
                        d = web.storage( ids=id_, t='', decimate='', x='', lowpass='',
                            search='', baseurl=baseurl, ext='.png', disk=True )
                        show2d( d )
            if group:
                out += group + html.index.group_end
    out += html.index.foot + html.main.foot
    out = out % dict( baseurl=baseurl, search=w.search, title='WebSims', style=html.style )
    if not w.search:
        open( os.path.join( 'static', 'index.html' ), 'w' ).write( out )
    return out


def show2d( w ):
    """
    2D slice page.
    """
    time = w.t
    ids = w.ids.split( ',' )
    group = ids[0].split( '/' )[0]
    static = time == ''
    for id_ in ids[1:]:
        group0 = group
        group = id_.split( '/' )[0]
        if group != group0:
            out = (
               html.main.head +
               '<h2>Error</h2>\n' +
               '<div>Incompatible comparison pair: %s, %s</div>\n' %
               (group0, group) +
               html.main.foot
            )
            web.header( 'Content-Type', 'text/html' )
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            return out % dict( title='Error', baseurl=baseurl, search='', style=html.style )
    f = os.path.join( conf.repo[0], ids[0], conf.meta )
    m = util.load( f )
    outp = ''
    outd = ''
    w.style = html.style
    w.title = m.title
    if static:
        w.subtitle = m.x_static_title
        panes = m.x_static_panes
    else:
        w.subtitle = m.x_title
        panes = m.x_panes
    if hasattr( m, 'notes' ):
        w.notes = publish_parts( m.notes, writer_name='html4css1' )['body']
    else:
        w.notes = ''
    for ipane in range( len( panes ) ):
        for id_ in ids:
            f = os.path.join( conf.repo[0], id_, conf.meta )
            m = util.load( f )
            ndim = len( m.x_shape )
            it = list( m.x_axes ).index( 'Time' )
            ix = [ i for i in range(ndim) if i != it and m.x_shape[i] > 1 ]
            dt = m.x_delta[it]
            indices = ndim * [1]
            for i in ix[:2]:
                indices[i] = 0
            if static:
                panes = m.x_static_panes
            else:
                indices[it] = int( float( time ) / dt + 1.5 )
                panes = m.x_panes
            w.id = id_
            w.path = panes[ipane][0]
            w.root = os.path.basename( w.path )
            w.name = m.label + panes[ipane][1]
            w.j = ','.join( [ str( i ) for i in indices ] )
            w.n = ','.join( [ str( m.x_shape[i] ) for i in ix[:2] ] )
            if static:
                plot.plot2d( id_, w.path )
                if m.t_panes:
                    outp += html.plot.click2d_static % dict( w )
                else:
                    outp += html.plot.plot2d_static % dict( w )
            else:
                if m.t_panes:
                    outp += html.plot.click2d % dict( w )
                else:
                    outp += html.plot.plot2d % dict( w )
            if m.downloadable:
                outd += html.download.item % dict( w )
    out = html.main.head + html.form.head
    if m.x_panes:
        out += html.form.form2d
    if m.t_panes:
        out += html.form.form1d
    out += html.form.foot + html.plot.head + outp + html.plot.foot
    if m.downloadable:
        out += html.download.head + outd + html.download.foot
    out += html.main.foot
    w.tlim = '0-%s%s' % (m.x_delta[it] * m.x_shape[it], m.x_unit[it])
    it = list( m.t_axes ).index( 'Time' )
    ix = [ i for i in range(ndim) if i != it and m.t_shape[i] > 1 ]
    w.flim = '0-%s%s' % (0.5 / m.t_delta[it], 'Hz')
    w.axes = ','.join( [ m.t_axes[i] for i in ix ] )
    w.xlim = ', '.join(
        [ '0-%s%s' % ( abs( m.t_delta[i] * m.t_shape[i] ), m.t_unit[i] ) for i in ix ]
    )
    w.x = ''
    if w.decimate == '':
        w.decimate = m.x_decimate
    out = out % dict( w )
    if static and len( ids ) == 1:
        f = os.path.join( conf.repo[0], ids[0], conf.index )
        open( f, 'w' ).write( out )
    return out


def show1d( w ):
    """
    Time history page
    """
    ids = w.ids.split( ',' )
    x = w.x.split( ',' )
    download = ''
    for id_ in ids:
        w.id = id_
        f = os.path.join( conf.repo[0], id_, conf.meta )
        m = util.load( f )
        ndim = len( m.t_shape )
        it = list( m.t_axes ).index( 'Time' )
        ix = [ i for i in range(ndim) if i != it and m.t_shape[i] > 1 ]
        if m.downloadable:
            nn = [ m.t_shape[i] for i in ix ]
            dx = [ m.t_delta[i]  for i in ix ]
            ii = [ int( float( x[i] ) / abs( dx[i] ) + 1.5 )
                for i in range( len( x ) ) ]
            for i in range( len( ii ) ):
                if ii[i] < 1 or ii[i] > nn[i]:
                    web.header( 'Content-Type', 'text/html' )
                    out = (
                        html.main.head +
                        'Location (%(x)s) out of range' +
                        html.main.foot
                    )
                    return out % dict( w )
            indices = ndim * [1]
            indices[it] = 0
            for i in range( len( ix ) ):
                indices[ix[i]] = ii[i]
            w.j = ','.join( [ str(i) for i in indices ] )
            w.n = m.t_shape[it]
            for pane in m.t_panes:
                if len( pane ) <= 2 or pane[2] == None:
                    w.name = m.label + pane[1]
                    w.baseurl = baseurl
                    for filename in pane[0]:
                        w.path = filename
                        w.root = os.path.basename( filename )
                        download += html.download.item % dict( w )
    if hasattr( m, 'notes' ):
        w.notes = publish_parts( m.notes, writer_name='html4css1' )['body']
    else:
        w.notes = ''
    w.style = html.style
    w.title = m.title
    w.subtitle = m.t_title
    w.axes = ','.join( [ m.t_axes[i] for i in ix ] )
    w.flim = '0-%s%s' % (0.5 / m.t_delta[it], 'Hz')
    w.xlim = ', '.join(
        [ '0-%s%s' % ( abs( m.t_delta[i] * m.t_shape[i] ), m.t_unit[i] ) for i in ix ]
    )
    it = list( m.x_axes ).index( 'Time' )
    ix = [ i for i in range(ndim) if i != it and m.x_shape[i] > 1 ]
    w.tlim = '0-%s%s' % (m.x_delta[it] * m.x_shape[it], m.x_unit[it])
    out = html.main.head + html.form.head
    if m.x_panes:
        out += html.form.form2d + html.form.form1d + html.form.foot + html.plot.click1d
    else:
        out += html.form.form1d + html.form.foot + html.plot.plot1d
    if m.downloadable:
        out += html.download.head + download + html.download.foot
    out += html.main.foot
    web.header( 'Content-Type', 'text/html' )
    web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
    out = out % dict( w )
    return out


app = web.application( urls, globals() )

