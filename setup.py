#!/usr/bin/env python
"""
Build SORD binaries and documentation
"""

def build( mode='sm', optimize='gpO' ):
    import os
    import util, configure
    cfg = configure.configure()
    extras = (
        'swab',
        'swab-safe',
        'asc2flt',
        'flt2asc',
        'stats', )
    base = (
        'globals.f90',
        'diffcn.f90',
        'diffnc.f90',
        'hourglass.f90',
        'bc.f90',
        'surfnormals.f90',
        'util.f90',
        'frio.f90', )
    common = (
        'arrays.f90',
        'fieldio.f90',
        'stats.f90',
        'parameters.f90',
        'setup.f90',
        'gridgen.f90',
        'source.f90',
        'material.f90',
        'fault.f90',
        'resample.f90',
        'checkpoint.f90',
        'timestep.f90',
        'stress.f90',
        'acceleration.f90',
        'sord.f90', )
    cwd = os.getcwd()
    srcdir = os.path.realpath( os.path.dirname( __file__ ) )
    os.chdir( srcdir + os.sep + 'extras' )
    new = False
    for f in extras:
        source = cfg['getarg'], f + '.f90'
        object = '..' + os.sep + 'bin' + os.sep + f
        compiler = cfg['sfc'] + cfg['O']
        new |= util.compile( compiler, object, source )
    os.chdir( srcdir + os.sep + 'src' )
    if 's' in mode:
        source = base + ( 'serial.f90', ) + common
        for opt in optimize:
            object = '..' + os.sep + 'bin' + os.sep + 'sord-s' + opt
            compiler = cfg['sfc'] + cfg[opt]
            new |= util.compile( compiler, object, source )
    if 'm' in mode and cfg['mfc']:
        source = base + ( 'mpi.f90', ) + common
        for opt in optimize:
            object = '..' + os.sep + 'bin' + os.sep + 'sord-m' + opt
            compiler = cfg['mfc'] + cfg[opt]
            new |= util.compile( compiler, object, source )
    if new:
        util.tarball()
    os.chdir( cwd )
    return

css = """\
body { margin: 0px; background-color: #fff; color: #000; font-family: 'Lucida Grande', Geneva, Verdana, sans-serif }
div { margin: 0px; }
div.line-block { margin: 20px; margin-top: 10px; margin-bottom: 10px; }
div.footer { margin: 20px; margin-top: 40px; }
p { margin: 20px; margin-top: 15px; margin-bottom: 15px; }
dl { margin: 20px; margin-top: 35px; margin-bottom: 15px; }
table { margin: 60px; margin-top: 0px; margin-bottom: 0px; border: none; }
td { border: none; }
pre { margin: 60px; margin-top: 15px; margin-bottom: 15px; }
h1 { margin: 0px; padding: 20px; border-top: medium solid #700;; border-bottom: medium solid #300; font-weight: lighter; color: #fff; background-color: #600; text-shadow: #000 3px 3px 3px; }
h2, h3 { padding: 5px; margin: 15px; margin-top: 20px; margin-bottom: 10px; background-color: #eee; }
a { color: #00c; text-decoration: none; }
a:hover, a:active { color: #66f; text-decoration: none; }
img { border: 15px solid #fff; padding: 0px; }
"""

def docs():
    import os
    out = '\nExamples\n'
    out += '--------\n'
    sources = [ 'loh1.py', 'tpv3.py', 'saf.py', ]
    for f in sources:
      doc = file( 'examples/' + f, 'r' ).readlines()[2].strip()
      #out += '| %s: `%s <examples/%s>`_\n' % ( doc, f, f )
      out += '| `%s <examples/%s>`_: %s\n' % ( f, f, doc )
    out += '\nFortran source code\n'
    out += '-------------------\n'
    sources = [
      'sord.f90',
      'globals.f90',
      'parameters.f90',
      'setup.f90',
      'arrays.f90',
      'gridgen.f90',
      'material.f90',
      'resample.f90',
      'timestep.f90',
      'stress.f90',
      'source.f90',
      'acceleration.f90',
      'hourglass.f90',
      'bc.f90',
      'diffcn.f90',
      'diffnc.f90',
      'fault.f90',
      'surfnormals.f90',
      'fieldio.f90',
      'checkpoint.f90',
      'stats.f90',
      'serial.f90',
      'mpi.f90',
      'frio.f90',
      'util.f90',
    ]
    for f in sources:
      doc = file( 'src/' + f, 'r' ).readlines()[0].strip().replace( '! ', '' )
      #out += '| %s: `%s <src/%s>`_\n' % ( doc, f, f )
      out += '| `%s <src/%s>`_: %s\n' % ( f, f, doc )
    out += '\nPython wrappers\n'
    out += '---------------\n'
    sources = [
      'run.py',
      'defaults.py',
      'fieldnames.py',
      'configure.py',
      'setup.py',
      'remote.py',
      'util.py',
    ]
    for f in sources:
      doc = file( f, 'r' ).readlines()[2].strip()
      #out += '| %s: `%s <%s>`_\n' % ( doc, f, f )
      out += '| `%s <%s>`_: %s\n' % ( f, f, doc )
    download = "Latest source code version `%s <sord.tgz>`_" % file( 'version', 'r' ).read().strip()
    file( 'download.txt', 'w' ).write( download )
    file( 'sources.txt', 'w' ).write( out )
    file( 'style.css', 'w' ).write( css )
    os.system(' \
        rst2html.py \
        -g -d -s \
        --strict \
        --cloak-email-addresses \
        --initial-header-level=3 \
        --no-toc-backlinks \
        --stylesheet-path=style.css \
        readme.txt | sed "/\<col/d" > index.html \
    ')
    os.unlink( 'download.txt' )
    os.unlink( 'sources.txt' )
    os.unlink( 'style.css' )
    return

if __name__ == '__main__':
    import sys, util
    build( 'sm', 'gpO' )
    if len( sys.argv ) > 1:
        if sys.argv[1] == 'docs':
            docs()
        elif sys.argv[1] == 'install':
            util.install()
        elif sys.argv[1] == 'uninstall':
            util.uninstall()
        else:
            sys.exit( 'Error: unknown option: %r' % sys.argv[1] )

