#!/usr/bin/env python
"""
Machine configuration
"""
import os, re, shutil, getopt, sys
import numpy as np

class namespace:
    """
    Namespace with object attributes initialized from a dict.
    """
    def __init__( self, d ):
        self.__dict__.update( d )

def prune( d, pattern=None, types=None ):
    """
    Delete dictionary keys with specified name pattern or types

    Parameters
    ----------
    d : dict of parameters
    pattern : regular expression of parameter names to prune
        default = '(^_)|(_$)|(^.$)|(^..$)'
    types : list of parameters types to keep
        default = [NoneType, bool, str, int, float, tuple, list, dict]
        Functions, classes, and modules are pruned by default.

    >>> prune( {'aa': 0, 'aa_': 0, '_aa': 0, 'a_a': 0, 'b_b': prune} )
    {'a_a': 0}
    """
    if pattern == None:
        pattern = '(^_)|(_$)|(^.$)|(^..$)'
    if types == None:
        types = type(None), bool, str, int, float, tuple, list, dict
    grep = re.compile( pattern )
    for k in d.keys():
        if grep.search( k ) or type( d[k] ) not in types:
            del( d[k] )
    return d

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
    job : job configuration object containing merged module, kwarg, and machine
        configuration parameters as object attributes
    kwarg : dictionary containing unmatched parameters

    Module and machine names correspond to subdirectories of the conf folder
    that contain configuration parameters in a file conf.py.
    """

    # module parameters
    path = os.path.realpath( os.path.dirname( __file__ ) )
    job = {}
    job['module'] = module
    f = os.path.join( path, module, 'conf.py' )
    exec open( f ) in job

    # machine parameters
    f = os.path.join( path, 'machine' )
    if not machine and os.path.isfile( f ):
        machine = open( f ).read().strip()
    if machine:
        machine = os.path.basename( os.path.normpath( machine ) )
        f = os.path.join( path, machine, 'conf.py' )
        if os.path.isfile( f ):
            exec open( f ) in job
        if save:
            f = os.path.join( path, 'machine' )
            open( f, 'w' ).write( machine )
    job['machine'] = machine

    # email address
    f = os.path.join( path, 'email' )
    if os.path.isfile( f ):
        job['email'] = open( f ).read().strip()

    # per machine module specific parameters
    k = module + '_'
    if k in job:
        job.update( job[k] )

    # function parameters
    kwargs = kwargs.copy()
    for k, v in kwargs.copy().iteritems():
        if k in job:
            job[k] = v
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
            job[key] = val

    # fortran flags
    if 'fortran_flags_default_' in job:
        if 'fortran_flags' not in job:
            k = job['fortran_serial'][0]
            job['fortran_flags'] = job['fortran_flags_default_'][k]

    # prune unneeded variables
    prune( job )
    prune( kwargs )

    # misc
    if 'dtype' in job:
        job['dtype'] = np.dtype( job['dtype'] ).str
    if 'rundir' in job:
        job['rundir'] = os.path.expanduser( job['rundir'] )

    # configuration object
    job = namespace( job )

    return job, kwargs

def resources( job ):
    """
    Compute and display resource usage
    """

    # parallelization
    if job.maxcores and job.maxnodes:
        job.nodes = min( job.maxnodes, (job.nproc - 1) / job.maxcores + 1 )
        job.ppn = (job.nproc - 1) / job.nodes + 1
        job.cores = min( job.maxcores, job.ppn )
        job.totalcores = job.nodes * job.maxcores
    else:
        job.nodes = 1
        job.ppn = job.nproc
        job.cores = job.nproc
        job.totalcores = job.nproc
    print( 'Machine: ' + job.machine )
    print( 'Cores: %s of %s' % (job.nproc, job.maxnodes * job.maxcores) )
    print( 'Nodes: %s of %s' % (job.nodes, job.maxnodes) )

    # memory
    if hasattr( job, 'pmem' ):
        job.ram = job.pmem * job.ppn
        print( 'RAM: %sMb of %sMb per node' % (job.ram, job.maxram) )

    # SU estimate and generous wall time limit
    if hasattr( job, 'seconds' ):
        ss = job.seconds * job.ppn / job.cores
        mm = ss / 60 * 2.0 + 10
        if job.maxtime:
            mm = min( mm, 60 * job.maxtime[0] + job.maxtime[1] )
        hh = mm / 60
        mm = mm % 60
        job.walltime = '%d:%02d:00' % (hh, mm)
        sus = int( ss / 3600 * job.totalcores + 1 )
        print( 'SUs: %s' % sus )
    print( 'Time limit: ' + job.walltime )

    # warnings
    if job.maxcores and job.ppn > job.maxcores:
        print( 'Warning: exceding available cores per node (%s)' % job.maxcores )
    if job.ram and job.ram > job.maxram:
        print( 'Warning: exceding available RAM per node (%sMb)' % job.maxram )

    return job

def skeleton( job, files=(), new=True ):
    """
    Create run directory skeleton from templates.

    Parameters
    ----------
    job : job configuration object
    files : list of files to link or copy into directory
    new : (True|False) create new directory, or use existing

    Templates located in the configuration directory are processed with the given
    keyword parameters.  Module specific templates are used if found, in addition
    to machine specific templates.  If no machine specific templates are found,
    default templates are used. 
    """

    # parameters
    rundir = job.rundir
    module = job.module
    machine = job.machine

    # locations
    path = os.path.realpath( os.path.dirname( __file__ ) )
    dest = os.path.realpath( os.path.expanduser( rundir ) ) + os.sep

    # create destination directory
    if new:
        os.makedirs( dest )

    # module templates
    templates = ()
    f = os.path.join( path, module, 'templates' )
    if module != 'default' and os.path.isdir( f ):
        templates += f,

    # machine templates
    f = os.path.join( path, machine, 'templates' )
    if not os.path.isdir( f ):
        f = os.path.join( path, 'default', 'templates' )
    templates += f,

    # process templates
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

    # link or copy files
    for f in files:
        try:
            os.link( f, dest + f )
        except:
            shutil.copy2( f, dest )

    return

def launch( job ):
    """
    Launch or queue job.
    """
    cwd = os.getcwd()
    os.chdir( job.rundir )
    if job.run == 'q':
        if job.host not in job.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (job.host, job.machine) )
        print( 'bash queue.sh' )
        if os.system( 'bash queue.sh' ):
            sys.exit( 'Error queing job' )
    elif job.run:
        if job.host not in job.hosts:
            sys.exit( 'Error: hostname %r does not match configuration %r'
                % (job.host, job.machine) )
        print( 'bash run.sh -' + job.run )
        if os.system( 'bash run.sh -' + job.run ):
            sys.exit( 'Error running job' )
    os.chdir( cwd )
    return

def stage( **kwargs ):
    """
    Configure and stage job
    """
    job = configure( **kwargs )
    job = resources( job )
    skeleton( job )
    return job

def run( **kwargs ):
    """
    Configure, stage, and launch job
    """
    job = configure( **kwargs )
    job = resources( job )
    skeleton( job )
    launch( job )
    return job

# run tests if called from the command line
if __name__ == '__main__':
    import pprint
    modules = 'default', 'sord', 'cvm'
    machines = os.listdir('.')
    for module in modules:
        for machine in machines:
            if os.path.isdir( machine ) and machine not in modules:
                job = configure( module, machine )[0]
                print 80 * '-'
                pprint.pprint( job.__dict__ )
                if module == 'default':
                    job.rundir = 'tmp'
                    skeleton( job )
                    shutil.rmtree( 'tmp' )

