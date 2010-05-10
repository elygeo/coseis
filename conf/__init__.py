#!/usr/bin/env python
"""
Machine configuration
"""
import os, re, shutil, getopt, sys
import numpy as np

def configure( module='default', machine=None, save=False, options=None, **kwargs ):
    """
    Merge module, machine, keyword, and command line parameters.

    Parameters
    ----------
        module : module name
        machine : machine name
        save : remember machine name
        options : list command line options consisting of:
            (sort_form, long_form, parameter, value)
        **kwargs : override parameters supplied as keyword arguments

    Returns
    -------
        conf : dictionary containing merged module, kwarg, and machine configuration
        kwarg : dictionary containing unmerged parameters

    Module and machine names correspond to subdirectories of the conf folder
    that contain configuration parameters in a file conf.py.
    """

    # module parameters
    path = os.path.realpath( os.path.dirname( __file__ ) )
    conf = {}
    conf['module'] = module
    f = os.path.join( path, module, 'conf.py' )
    exec open( f ) in conf

    # machine parameters
    f = os.path.join( path, 'machine' )
    if 'machine' in kwargs:
        machine = kwargs['machine']
    elif os.path.isfile( f ):
        machine = open( f ).read().strip()
    conf['machine'] = machine
    if machine:
        machine = os.path.basename( os.path.normpath( machine ) )
        f = os.path.join( path, machine, 'conf.py' )
        if os.path.isfile( f ):
            exec open( f ) in conf
        if save:
            f = os.path.join( path, 'machine' )
            open( f, 'w' ).write( machine )

    # email address
    f = os.path.join( path, 'email' )
    if os.path.isfile( f ):
        conf['email'] = open( f ).read().strip()

    # per machine module specific parameters
    if module in conf:
        conf.update( conf[module] )

    # function parameters
    kwargs = kwargs.copy()
    for k, v in kwargs.copy().iteritems():
        if k in conf:
            conf[k] = v
            del( kwargs[k] )

    # command line parameters
    if options:
        short, long = zip( *options )[:2]
        opts = getopt.getopt( sys.argv[1:], ''.join( short ), long )[0]
        for opt, val in opts:
            key = opt.lstrip('-')
            if opt.startswith( '--' ):
                i = long.index( key )
            else:
                i = short.index( key )
            key, val = options[i][2:]
            conf[key] = val

    # fortran flags
    if 'fortran_flags_default' in conf:
        if 'fortran_flags' not in conf:
            k = conf['fortran_serial'][0]
            conf['fortran_flags'] = conf['fortran_flags_default'][k]

    # prune unneeded variables
    prune( conf, pattern='(^_)|(^.$)|(^..$)|(^sord$)|(^cvm$)|(^fortran_flags_default$)' )
    prune( kwargs, pattern='(^_)|(^.$)|(^..$)|(^sord$)|(^cvm$)|(^fortran_flags_default$)|(_$)' )

    # misc
    if 'dtype' in conf:
        conf['dtype'] = np.dtype( conf['dtype'] ).str
    if 'rundir' in conf:
        conf['rundir'] = os.path.expanduser( conf['rundir'] )

    return conf, kwargs

def prune( d, pattern=None, types=None ):
    """
    Delete dictionary keys with specified name pattern or types
    Default types are: functions and modules.

    >>> prune( {'a': 0, 'a_': 0, '_a': 0, 'a_a': 0, 'b': prune} )
    {'a_a': 0}
    """
    if pattern == None:
        pattern = '(^_)|(_$)|(^.$)|(^..$)'
    if types is None:
        types = type( re ), type( re.sub )
    grep = re.compile( pattern )
    for k in d.keys():
        if grep.search( k ) or type( d[k] ) in types:
            del( d[k] )
    return d

def resources( cf ):
    """
    Compute and display resource usage
    """

    # parallelization
    if cf.maxcores and cf.maxnodes:
        cf.nodes = min( cf.maxnodes, (cf.nproc - 1) / cf.maxcores + 1 )
        cf.ppn = (cf.nproc - 1) / cf.nodes + 1
        cf.cores = min( cf.maxcores, cf.ppn )
        cf.totalcores = cf.nodes * cf.maxcores
    else:
        cf.nodes = 1
        cf.ppn = cf.nproc
        cf.cores = cf.nproc
        cf.totalcores = cf.nproc
    print( 'Machine: ' + cf.machine )
    print( 'Cores: %s of %s' % (cf.nproc, cf.maxnodes * cf.maxcores) )
    print( 'Nodes: %s of %s' % (cf.nodes, cf.maxnodes) )

    # memory
    if hasattr( cf, 'pmem' ):
        cf.ram = cf.pmem * cf.ppn
        print( 'RAM: %sMb of %sMb per node' % (cf.ram, cf.maxram) )

    # SU estimate and generous wall time limit
    if hasattr( cf, 'seconds' ):
        ss = cf.seconds * cf.ppn / cf.cores
        mm = ss / 60 * 2.0 + 10
        if cf.maxtime:
            mm = min( mm, 60 * cf.maxtime[0] + cf.maxtime[1] )
        hh = mm / 60
        mm = mm % 60
        cf.walltime = '%d:%02d:00' % (hh, mm)
        sus = int( ss / 3600 * cf.totalcores + 1 )
        print( 'SUs: %s' % sus )
    print( 'Time limit: ' + cf.walltime )

    # warnings
    if cf.maxcores and cf.ppn > cf.maxcores:
        print( 'Warning: exceding available cores per node (%s)' % cf.maxcores )
    if cf.ram and cf.ram > cf.maxram:
        print( 'Warning: exceding available RAM per node (%sMb)' % cf.maxram )

    return cf

def skeleton( files=(), new=True, **kwargs ):
    """
    Create run directory skeleton from templates.

    Parameters
    ----------
        files : list of files to link or copy into directory
        new : (True|False) create new directory, or use existing
        **kwargs : keyword parameters

    Templates located in the configuration directory are processed with the given
    keyword parameters.  Module and machine names must be specified as parameters in
    kwargs.  Module specific templates are used if found, in addition to machine
    specific templates.  If no machine specific templates are found, default
    templates are used. 
    """
    rundir = kwargs['rundir']
    module = kwargs['module']
    machine = kwargs['machine']
    path = os.path.realpath( os.path.dirname( __file__ ) )
    dest = os.path.realpath( os.path.expanduser( rundir ) ) + os.sep
    if new:
        os.makedirs( dest )
    templates = ()
    f = os.path.join( path, module, 'templates' )
    if module != 'default' and os.path.isdir( f ):
        templates += f,
    f = os.path.join( path, machine, 'templates' )
    if not os.path.isdir( f ):
        f = os.path.join( path, 'default', 'templates' )
    templates += f,
    cwd = os.getcwd()
    for t in templates:
        os.chdir( t )
        for root, dirs, temps in os.walk( '.' ):
            for f in dirs:
                ff = os.path.join( dest, root, f )
                os.mkdir( ff )
            for f in temps:
                ff = os.path.join( dest, root, f )
                out = open( f ).read() % kwargs
                open( ff, 'w' ).write( out )
                shutil.copymode( f, ff )
    os.chdir( cwd )
    for f in files:
        try:
            os.link( f, dest + f )
        except:
            shutil.copy2( f, dest )
    return

# launch job
def launch( rundir='.', run=None, machine=None, host=None, hosts=[None], **kwargs ):
    """
    Launch or queue job.
    """
    cwd = os.getcwd()
    os.chdir( rundir )
    if run == 'q':
        if host not in hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (host, machine) )
        print( 'bash queue.sh' )
        if os.system( 'bash queue.sh' ):
            sys.exit( 'Error queing job' )
    elif run:
        if host not in hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (host, machine) )
        print( 'bash run.sh -' + run )
        if os.system( 'bash run.sh -' + run ):
            sys.exit( 'Error running job' )
    os.chdir( cwd )
    return

# Test all configurations if run from the command line
if __name__ == '__main__':
    import pprint
    modules = 'default', 'sord', 'cvm'
    machines = os.listdir('.')
    for module in modules:
        for machine in machines:
            if os.path.isdir( machine ) and machine not in modules:
                cf = configure( module, machine )[0]
                print 80 * '-'
                pprint.pprint( cf )
                if module == 'default':
                    cf['rundir'] = 'tmp'
                    skeleton( **cf )
                    shutil.rmtree( 'tmp' )

