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
    for k, v in kwargs.iteritems():
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

    # misc
    conf['dtype'] = np.dtype( conf['dtype'] ).str
    conf['rundir'] = os.path.expanduser( conf['rundir'] )

    # prune unneeded variables
    prune( conf, pattern='(^_)|(^.$)|(^..$)|(^sord$)|(^cvm$)|(^fortran_flags_default$)' )

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

def parallel( nproc, maxcores, maxnodes ):
    """
    Find optimal parallelization for desired number of processes.

    Parameters
    ----------
        nproc : number of desired processes
        maxcores : physical number of cores per node
        maxnodes : physical number of compute nodes in the system

    Returns
    -------
        nodes : number of compute nodes
        ppn : number of processes per node
        cores : number of cores per node
        totalcores : total number of cores
    """
    if maxcores and maxnodes:
        nodes = min( maxnodes, (nproc - 1) / maxcores + 1 )
        ppn = (nproc - 1) / nodes + 1
        cores = min( maxcores, ppn )
        totalcores = nodes * maxcores
    else:
        nodes = 1
        ppn = nproc
        cores = nproc
        totalcores = nproc
    return (nodes, ppn, cores, totalcores)

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

# Test all configurations if run from the command line
if __name__ == '__main__':
    import pprint
    modules = 'default', 'sord', 'cvm'
    machines = os.listdir('.')
    for module in modules:
        for machine in machines:
            if os.path.isdir( machine ) and machine not in modules:
                cf = configure( module, machine )
                print 80 * '-'
                pprint.pprint( cf )
                if module == 'default':
                    cf['rundir'] = 'tmp'
                    skeleton( **cf )
                    shutil.rmtree( 'tmp' )

