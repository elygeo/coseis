"""
WebSims: Web-based Earthquake Simulation Data Management
--------------------------------------------------------

WebSims is a Python web application for cataloging, exploring, comparing and
disseminating four-dimensional results of large numerical simulations.  Users
may extract time histories or two-dimensional slices via a clickable interface
or by specifying coordinates.  Extractions are plotted to the screen and may be
downloaded to local disk.  Time histories can be low-pass filtered, and
multiple simulations can be overlayed for comparison.  Metadata is stored with
each simulation in the form of a Python module.  A well defined URL scheme for
specifying extractions allows the web interface to be bypassed, allowing for
batch scripting of both plotting and downloading tasks.  This version of
WebSims replaces a previous PHP implementation.  It is written in Python_ using
the NumPy_, SciPy_, and Matplotlib_ modules for processing and visualization.
The web pages are served by web.py_, a simple web application framework.
WebSims is license under under the GPLv3 and is available as part of the
Computational Siesmology Tools (Coseis_).

.. _Python:     http://www.python.org/
.. _NumPy:      http://numpy.scipy.org/
.. _SciPy:      http://www.scipy.org/
.. _Matplotlib: http://matplotlib.sourceforge.net/
.. _web.py:     http://webpy.org/
.. _Coseis:     http://earth.usc.edu/~gely/coseis/www/
"""
import os, sys, signal, re, gzip, time, cStringIO, urllib, mimetypes
import numpy as np
import web
from docutils.core import publish_parts
from . import conf, util, html, plot

baseurl = '/websims'
cache_max_age = 86400
port = '8081'


def start( repo='.', daemon=False, debug=True, logfile='websims.log' ):
    """
    Start server
    """
    os.chdir( repo )
    if daemon:
        if os.fork():
            sys.exit()
        os.setsid()
        if os.fork():
            sys.exit()
        fd = open( logfile, 'a' )
        sys.stdout.flush()
        sys.stderr.flush()
        os.dup2( fd.fileno(), sys.stdout.fileno() )
        os.dup2( fd.fileno(), sys.stderr.fileno() )
    print '%s: Starting WebSims with PID: %s' % (time.ctime(), os.getpid())
    urls = (
        baseurl,			'main',
        baseurl + '/',			'redirect_main',
        baseurl + '/pid',		'pid',
        baseurl + '/list',		'list_',
        baseurl + '/about',		'about',
        baseurl + '/image/(.+)',	'image',
        baseurl + '/download/(.+)',	'download',
        baseurl + '/click1d/(.+)',	'click1d',
        baseurl + '/click2d/(.+)',	'click2d',
        baseurl + '/static(/repo/.*)',	'redirect_repo',
        baseurl + '(/static/)(.*)',	'staticfile',
        baseurl + '(/repo/)(.*)',	'staticfile',
    )
    sys.argv = [sys.argv[0], port]
    web.config.debug = debug
    app = web.application( urls, globals() )
    app.run()
    return app


class redirect_main():
    def GET( self ):
        raise web.redirect( baseurl )


class redirect_repo():
    def GET( self, url ):
        raise web.redirect( baseurl + url )


def stop():
    """
    Stop server
    """
    url = 'http://localhost:%s%s/pid' % (port, baseurl)
    try:
        pid = int( urllib.urlopen( url ).read() )
    except( IOError ):
        return
    print '%s: Stopping WebSims with PID: %s' % (time.ctime(), pid)
    os.kill( pid, signal.SIGTERM )
    return


class pid:
    """
    Process ID
    """
    def GET( self ):
        web.header( 'Content-Type', 'text/plain' )
        return str( os.getpid() )


class main:
    """
    Main page.
    """
    def GET( self ):
        w = web.input( ids=[], t='', decimate='', x='', lowpass='', search='' )
        w.ids = ','.join( w.ids )
        w.title = 'WebSims'
        w.baseurl = baseurl
        #w.ext = '.svg'
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
    """
    Plot image
    """
    def GET( self, filename ):
        w = web.input( ids=[], t='', decimate='', x='', lowpass='' )
        ids = ','.join( w.ids ).split(',')
        #web.header( 'Content-Type', 'image/svg+xml' )
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
            f  = os.path.join( ids[0], conf.cfgfile )
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
        raise web.seeother( '%s?ids=%s&x=%s' % (baseurl, id_, x) )


class click1d:
    """
    Click plot time axis and load time slice.
    """
    def GET( self, id_ ):
        w = web.input()
        t = '0.0'
        if len( w ) > 0:
            ids = id_.split(',')
            f  = os.path.join( ids[0], conf.cfgfile )
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
        raise web.seeother( '%s?ids=%s&t=%s' % (baseurl, id_, t) )


class download:
    """
    Download data
    """
    def GET( self, filename ):
        w = web.input()
        f = os.path.join( w.ids, conf.cfgfile )
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
        for d in conf.repodir:
            f = os.path.join( d, w.ids, root )
            if os.path.exists( f ):
                break
        else:
            found = False
        if not found:
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
            return out % dict( title='WebSims', baseurl=baseurl, search='' )


class list_:
    """
    Simulation list. Useful for remote machine processing.
    """
    def GET( self ):
        web.header( 'Content-Type', 'text/plain' )
        return sorted( util.findmembers( '.', conf.cfgfile, '.wsgroup', '.wsignore' ) )


class about:
    """
    About WebSims
    """
    def GET( self ):
        out = (
            html.main.head + '<br>' +
            publish_parts( __doc__, writer_name='html4css1' )['body'] +
            html.main.foot
        ) % dict( title='WebSims', baseurl=baseurl, search='' )
        web.header( 'Content-Type', 'text/html' )
        return out


def sizeof_fmt( num ):
    for x in 'B','KB','MB','GB','TB':
        if num < 1024.0:
            break
        num /= 1024.0
    return '%.0f%s' % (num, x)


class staticfile:
    """
    Serve static files and directories.
    """
    def listdir( self, root, path ):
        f = os.path.join( '.', path )
        try:
            files = os.listdir( f )
        except os.error:
            raise web.notfound()
        title = 'Directory listing for %s' % root + path
        d = dict( title=title, baseurl=baseurl, search='' )
        out = html.main.head + html.static.head
        if path:
            url = os.path.dirname( os.path.normpath( baseurl + root + path ) ) + '/'
            d.update( url=url, link='..', mtime='', size='' )
            out += html.static.item % d
        for f in sorted( files ):
            ff = path + f
            link = url = f
            if os.path.isdir( ff ):
                url = f + '/'
                link = f + '/'
                mtime = time.strftime( '%Y-%m-%d',
                    time.localtime( os.path.getmtime( ff ) ) )
                size = ''
            elif os.path.islink( ff ):
                link = f + '@'
                mtime = ''
                size = ''
            else:
                mtime = time.strftime( '%Y-%m-%d',
                    time.localtime( os.path.getmtime( ff ) ) )
                size = sizeof_fmt( os.path.getsize( ff ) )
            d.update( url=url, link=link, mtime=mtime, size=size )
            out += html.static.item % d
        out += html.static.foot + html.main.foot
        web.header( 'Content-Type', 'text/html' )
        return out % d
    def GET( self, root, path ):
        if '..' in path:
            raise web.notfound()
        f = path
        if 'static' in root:
            f = os.path.join( os.path.dirname( __file__ ), 'static', path )
        elif not path:
            return self.listdir( root, path )
        elif os.path.isdir( f ):
            if not path.endswith( '/' ):
                raise web.redirect( baseurl + root + path + '/' )
            return self.listdir( root, path )
        if os.path.isfile( f ):
            web.header( 'Content-Type', mimetypes.guess_type( f )[0] )
            web.header( 'Content-Length', os.path.getsize( f ) )
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            return open( f, 'rb' ).read()
        else:
            raise web.notfound()


def index( w ):
    """
    Build list of simulations.
    """
    out = html.main.head + html.index.head
    include = True
    if w.search:
        grep = re.compile( w.search, re.IGNORECASE )
    for ids in sorted( util.findmembers( '.', conf.cfgfile, '.wsgroup', '.wsignore' ) ):
        if type( ids ) == str:
            f = os.path.join( ids, conf.cfgfile )
            if w.search:
                include = grep.search( open( f, 'r' ).read() )
            if include:
                d = dict()
                try:
                    exec open( f ) in d
                except:
                    d.update( title='ERROR', author='', rundate='' )
                label = ids.split( '/' )[0]
                f = os.path.join( baseurl, 'repo', f )
                d.update( meta=f, baseurl=baseurl, id=ids, label=label )
                out += html.index.item_solo % d
        else:
            group = ''
            for id_ in sorted( ids ):
                f = os.path.join( id_, conf.cfgfile )
                if w.search:
                    include = grep.search( open( f, 'r' ).read() )
                if include:
                    d = dict()
                    try:
                        exec open( f ) in d
                    except:
                        d.update( title='ERROR', author='', rundate='' )
                    label = id_.split( '/' )[0]
                    f = os.path.join( baseurl, 'repo', f )
                    d.update( meta=f, baseurl=baseurl, id=id_, label=label )
                    group += html.index.item_grouped % d
            if group:
                out += html.index.group_start + group + html.index.group_end
    out += html.index.foot + html.main.foot
    return out % dict( baseurl=baseurl, search=w.search, title='WebSims' )


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
            return out % dict( title='Error', baseurl=baseurl, search='' )
    f = os.path.join( ids[0], conf.cfgfile )
    m = util.load( f )
    plot = ''
    download = ''
    if static:
        w.title = m.title + ' - ' + m.x_static_title
        panes = m.x_static_panes
    else:
        w.title = m.title + ' - ' + m.x_title
        panes = m.x_panes
    if hasattr( m, 'notes' ):
        w.notes = publish_parts( m.notes, writer_name='html4css1' )['body']
    else:
        w.notes = ''
    for ipane in range( len( panes ) ):
        for id_ in ids:
            f = os.path.join( id_, conf.cfgfile )
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
            if m.t_panes:
                plot += html.show.click2d % dict( w )
            else:
                plot += html.show.plot2d % dict( w )
            if m.downloadable:
                download += html.show.download_item % dict( w )
    out = html.main.head + html.show.head
    if m.t_panes:
        out += html.show.form1d
    if m.x_panes:
        out += html.show.form2d
    out += plot
    if m.downloadable:
        out += html.show.download_head + download + html.show.download_foot
    out += html.show.foot + html.main.foot
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
    return out % dict( w )


def show1d( w ):
    """
    Time history page
    """
    ids = w.ids.split( ',' )
    x = w.x.split( ',' )
    download = ''
    for id_ in ids:
        w.id = id_
        f = os.path.join( id_, conf.cfgfile )
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
                        download += html.show.download_item % dict( w )
    if hasattr( m, 'notes' ):
        w.notes = publish_parts( m.notes, writer_name='html4css1' )['body']
    else:
        w.notes = ''
    w.title = m.title + ' - ' + m.t_title
    w.axes = ','.join( [ m.t_axes[i] for i in ix ] )
    w.flim = '0-%s%s' % (0.5 / m.t_delta[it], 'Hz')
    w.xlim = ', '.join(
        [ '0-%s%s' % ( abs( m.t_delta[i] * m.t_shape[i] ), m.t_unit[i] ) for i in ix ]
    )
    it = list( m.x_axes ).index( 'Time' )
    ix = [ i for i in range(ndim) if i != it and m.x_shape[i] > 1 ]
    w.tlim = '0-%s%s' % (m.x_delta[it] * m.x_shape[it], m.x_unit[it])
    out = html.main.head + html.show.head + html.show.form1d
    if m.x_panes:
        out += html.show.form2d + html.show.click1d
    else:
        out += html.show.plot1d
    if m.downloadable:
        out += html.show.download_head + download + html.show.download_foot
    out += html.show.foot + html.main.foot
    web.header( 'Content-Type', 'text/html' )
    web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
    return out % dict( w )


