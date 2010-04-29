#!/usr/bin/env python
"""
Machine configuration
"""
import os, re, shutil

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

    INPUT
        nproc : number of desired processes
        maxcores : physical number of cores per node
        maxnodes : physical number of compute nodes in the system

    OUTPUT
        nodes : number of compute nodes
        ppn : number of processes per node
        cores : number of cores per node
        totalcores : total number of cores
    """
    if maxcores:
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

def skeleton( conf, files=(), new=True ):
    """
    Create run directory skeleton from templates.

    INPUT
        conf: dictionary of parameters
        files: list of files to link or copy into directory
        new: (True|False) create new directory, or use existing

    Templates located in the configuration directory are processed with the given
    dictionary conf.  Module and machine names must be specified as parameters in
    conf.  Module specific templates are used if found, in addition to machine
    specific templates.  If no machine specific templates are found, default
    templates are used. 
    """
    path = os.path.realpath( os.path.dirname( __file__ ) )
    dest = os.path.realpath( os.path.expanduser( conf['rundir'] ) ) + os.sep
    if new:
        os.makedirs( dest )
    templates = ()
    f = os.path.join( path, conf['module'], 'templates' )
    if conf['module'] != 'default' and os.path.isdir( f ):
        templates += f,
    f = os.path.join( path, conf['machine'], 'templates' )
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
                out = open( f ).read() % conf
                open( ff, 'w' ).write( out )
                shutil.copymode( f, ff )
    os.chdir( cwd )
    for f in files:
        try:
            os.link( f, dest + f )
        except:
            shutil.copy2( f, dest )
    return

def configure( module='default', machine=None, save=False ):
    """
    Read configuration files.

    INPUT:
        module: module name
        machine: machine name
        save: remember machine name

    OUTPUT:
        conf: dictionary containing merged module and machine configuration

    Module and machine names correspond to subdirectories of the conf folder
    that contain configuration parameters in a file conf.py.
    """
    path = os.path.realpath( os.path.dirname( __file__ ) )
    conf = {}
    conf['module'] = module
    f = os.path.join( path, module, 'conf.py' )
    exec open( f ) in conf
    f = os.path.join( path, 'machine' )
    if not machine and os.path.isfile( f ):
        machine = open( f ).read().strip()
    if machine:
        machine = os.path.basename( os.path.normpath( machine ) )
        conf['machine'] = machine
        f = os.path.join( path, machine, 'conf.py' )
        if os.path.isfile( f ):
            exec open( f ) in conf
        if save:
            f = os.path.join( path, 'machine' )
            open( f, 'w' ).write( machine )
    f = os.path.join( path, 'email' )
    if os.path.isfile( f ):
        conf['email'] = open( f ).read().strip()
    if module in conf:
        conf.update( conf[module] )
    if 'fortran_flags_default' in conf:
        if 'fortran_flags' not in conf:
            k = conf['fortran_serial'][0]
            conf['fortran_flags'] = conf['fortran_flags_default'][k]
    prune( conf, pattern='(^_)|(^.$)|(^sord$)|(^cvm$)|(^fortran_flags_default$)' )
    return conf

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
                    skeleton( cf )
                    shutil.rmtree( 'tmp' )

