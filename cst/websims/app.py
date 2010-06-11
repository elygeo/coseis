#!/usr/bin/env python
"""
WebSims: A Python-based web application for storing, exploring and
disseminating 4D earthquake simulation data
"""
import os, sys, re, web, gzip, cStringIO
import numpy as np
import util, plot, html, conf
from docutils.core import publish_parts

cfgfile = conf.cfgfile
baseurl = conf.baseurl
repodir = conf.repodir
cache_max_age = 86400

repourl = baseurl + '/static/repo'
urls = (
    baseurl,			'main',
    baseurl + '/list',		'list_',
    baseurl + '/about',		'about',
    baseurl + '/image/(.+)',	'image',
    baseurl + '/download/(.+)',	'download',
    baseurl + '/click1d/(.+)',	'click1d',
    baseurl + '/click2d/(.+)',	'click2d',
    '(.*)',			'notfound',
)

os.chdir( os.path.realpath( os.path.dirname( __file__ ) ) )

class main:
    """
    Main page.
    """
    def GET( self ):
        w = web.input( ids=[], t='', decimate='', x='', lowpass='', search='' )
        w.ids = ','.join( w.ids )
        w.title = 'WebSims'
        w.baseurl = baseurl
        w.repourl = repourl
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
            f  = os.path.join( repodir[0], ids[0], cfgfile )
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
                j = (int( jj[i] ) - j0[i]) * (nn[i] - 1) / (j1[i] - j0[i]) + 1
                j = max( 1, min( nn[i], j ) )
                if dx[i] < 0.0:
                    j = nn[i] - j + 1
                x[i] = str( (j - 1) * abs( dx[i] ) )
            x = ','.join( x )
        raise web.redirect( '%s?ids=%s&x=%s' % (baseurl, id_, x) )

class click1d:
    """
    Click plot time axis and load time slice.
    """
    def GET( self, id_ ):
        w = web.input()
        t = '0.0'
        if len( w ) > 0:
            ids = id_.split(',')
            f  = os.path.join( repodir[0], ids[0], cfgfile )
            m  = util.load( f )
            j  = int( w.keys()[0].split(',')[0] )
            it = list( m.x_axes ).index( 'Time' )
            nt = m.x_shape[it]
            dt = m.x_delta[it]
            j0 = 100
            j1 = 900
            j  = (j - j0) * (nt - 1) / (j1 - j0) + 1
            j  = max( 1, min( nt, j ) )
            t  = str( (j - 1) * dt )
        raise web.redirect( '%s?ids=%s&t=%s' % (baseurl, id_, t) )

class download:
    """
    Download data
    """
    def GET( self, filename ):
        w = web.input()
        f = os.path.join( repodir[0], w.ids, cfgfile )
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
        for d in repodir:
            f = os.path.join( d, w.ids, root )
            if os.path.exists( f ):
                break
        else:
            found = False
        if not found:
            print( 'File not found: ' + root )
            web.header( 'Content-Type', 'text/html' )
            web.header( 'Cache-Control', 'max-age=%s' % cache_max_age )
            out = (
                html.main.head +
                '<h2>Error</h2>\n' +
                '<div>File not found: %s</div>\n' % root +
                html.main.foot
            )
            return out % dict( title='WebSims', baseurl=baseurl, search='' )
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
        n = len( repodir[0] ) + 1
        ids = sorted( util.findmembers( repodir[0], cfgfile, '.wsgroup', '.wsignore' ) )
        for i in range( len( ids ) ):
            if type( ids[i]  ) == str:
                ids[i] = ids[i][n:]
            else:
                ids[i] = [ id[n:] for id in ids[i] ]
        web.header( 'Content-Type', 'text/plain' )
        return ids

class about:
    """
    About WebSims
    """
    def GET( self ):
        out = (
            html.main.head + html.main.about + html.main.foot
        ) % dict( title='WebSims', baseurl=baseurl, search='' )
        web.header( 'Content-Type', 'text/html' )
        return out

class notfound:
    """
    Error page
    """
    def GET( self, url ):
        out = (
            html.main.head + '<h2>Not found: %s</h2>\n' % url + html.main.foot
        ) % dict( title='Not found', baseurl=baseurl, search='' )
        raise web.notfound( out )

def index( w ):
    """
    Build list of simulations.
    """
    out = html.main.head + html.index.head
    include = True
    if w.search:
        grep = re.compile( w.search, re.IGNORECASE )
    for ids in sorted( util.findmembers( repodir[0], cfgfile, '.wsgroup', '.wsignore' ) ):
        if type( ids ) == str:
            f = os.path.join( ids, cfgfile )
            if w.search:
                include = grep.search( open( f, 'r' ).read() )
            if include:
                d = dict()
                try:
                    exec open( f ) in d
                except:
                    d.update( title='ERROR', author='', rundate='' )
                n = len( repodir[0] ) + 1
                id = ids[n:]
                label = id.split( '/' )[0]
                d.update( meta=f, baseurl=baseurl, id=id, label=label )
                out += html.index.item_solo % d
        else:
            group = ''
            for id_ in sorted( ids ):
                f = os.path.join( id_, cfgfile )
                if w.search:
                    include = grep.search( open( f, 'r' ).read() )
                if include:
                    d = dict()
                    try:
                        exec open( f ) in d
                    except:
                        d.update( title='ERROR', author='', rundate='' )
                    n = len( repodir[0] ) + 1
                    id = id_[n:]
                    label = id.split( '/' )[0]
                    d.update( meta=f, baseurl=baseurl, id=id, label=label )
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
    f = os.path.join( repodir[0], ids[0], cfgfile )
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
            f = os.path.join( repodir[0], id_, cfgfile )
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
        f = os.path.join( repodir[0], id_, cfgfile )
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

web.config.debug = False
web.config.debug = True
app = web.application( urls, globals() )

if __name__ == "__main__":
    sys.argv.append( '8081' )
    app.run()

