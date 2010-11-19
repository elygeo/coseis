#!/usr/bin/env python
"""
Configure, build, and launch utilities.
"""
import os, sys, re, shutil, getopt, subprocess, shlex, time
import numpy as np

path = os.path.realpath( os.path.dirname( __file__ ) )

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
        default = Numpy types + [NoneType, bool, str, int, lone, float, tuple, list, dict]
        Functions, classes, and modules are pruned by default.

    >>> prune( {'aa': 0, 'aa_': 0, '_aa': 0, 'a_a': 0, 'b_b': prune} )
    {'a_a': 0}
    """
    if pattern is None:
        pattern = '(^_)|(_$)|(^.$)|(^..$)'
    if types is None:
        types = set(
            np.typeDict.values() +
            [type(None), bool, str, int, long, float, tuple, list, dict]
        )
    grep = re.compile( pattern )
    for k in d.keys():
        if grep.search( k ) or type( d[k] ) not in types:
            del( d[k] )
    return d

_site_template = '''\
"""
Site specific configuration
"""
machine = %(machine)r
repo = %(repo)r
'''

def configure( module=None, machine=None, save_site=False, **kwargs ):
    """
    Merge module, machine, keyword, and command line parameters.

    Parameters
    ----------
    module : module name
    machine : machine name
    save_site : save site specific parameters (machine, email, repo)
    **kwargs : override parameters supplied as keyword arguments

    Returns
    -------
    job : job configuration object containing merged module, kwarg, and machine
        configuration parameters as object attributes
    kwarg : dictionary containing unmatched parameters

    Module and machine names correspond to subdirectories of the conf folder
    that contain configuration parameters in a file conf.py.
    """

    # command line arguments
    if 'argv' in kwargs:
        argv = kwargs['argv']
    else:
        argv = sys.argv[1:]

    path = os.path.dirname( __file__ )
    job = {'module': module}

    # default parameters
    f = os.path.join( path, 'conf.py' )
    exec open( f ) in job

    # module parameters
    if module:
        job['name'] = module
        f = os.path.join( path, module + '.py' )
        exec open( f ) in job

    # site parameters
    f = os.path.join( path, 'site.py' )
    if os.path.isfile( f ):
        exec open( f ) in job
    job['repo'] = os.path.expanduser( job['repo'] )

    # machine parameters
    if machine:
        job['machine'] = machine
    else:
        machine = job['machine']
    if machine:
        f = os.path.join( path, machine, 'conf.py' )
        exec open( f ) in job

    # per machine module specific parameters
    if module:
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
    options = job['options']
    if options:
        short, long = zip( *options )[:2]
    else:
        short, long = [], []
    opts = getopt.getopt( argv, ''.join( short ), long )[0]
    short = [ s.rstrip( ':' ) for s in short ]
    long = [ l.rstrip( '=' ) for l in long ]
    for opt, val in opts:
        key = opt.lstrip('-')
        if opt.startswith( '--' ):
            i = long.index( key )
        else:
            i = short.index( key )
        opt, key, cast = options[i][1:]
        if opt[-1] in ':=':
            job[key] = type( cast )( val )
        else:
            job[key] = cast

    # fortran flags
    if 'fortran_flags_default_' in job:
        if 'fortran_flags' not in job:
            k = job['fortran_serial']
            job['fortran_flags'] = job['fortran_flags_default_'][k]

    # save site configuration
    if save_site:
        f = os.path.join( path, 'site.py' )
        open( f, 'w' ).write( _site_template % job )

    # prune unneeded variables and create configuration object
    doc = job['__doc__']
    prune( kwargs )
    prune( job )
    job = namespace( job )
    job.__doc__ = doc

    return job, kwargs


def make( compiler, object_, source ):
    """
    An alternative Make that uses state files.
    """
    import glob, difflib
    object_ = os.path.expanduser( object_ )
    source = [ os.path.expanduser( f ) for f in source if f ]
    statedir = os.path.join( os.path.dirname( object_ ), '.state' )
    if not os.path.isdir( statedir ):
        os.mkdir( statedir )
    statefile = os.path.join( statedir, os.path.basename( object_ ) )
    if type( compiler ) is str:
        compiler = shlex.split( compiler )
    else:
        compiler = list( compiler )
    command = compiler + [object_] + source
    state = [' '.join( command ) + '\n']
    for f in source:
        state += open( f ).readlines()
    compile_ = True
    if os.path.isfile( object_ ):
        try:
            oldstate = open( statefile ).readlines()
        except( IOError ):
            pass
        else:
            diff = ''.join( difflib.unified_diff( oldstate, state, n=0 ) )
            if diff:
                print( diff )
            else:
                compile_ = False
    if compile_:
        try:
            os.unlink( statefile )
        except( OSError ):
            pass
        print( '\n' + ' '.join( command ) )
        subprocess.check_call( command )
        open( statefile, 'w' ).writelines( state )
        for pat in '*.o', '*.mod', '*.ipo', '*.il', '*.stb':
            for f in glob.glob( pat ):
                os.unlink( f )
    return compile_


def install_path( path, name=None ):
    """
    Install path file in site-packages directory.
    """
    from distutils.sysconfig import get_python_lib
    src = os.path.realpath( os.path.expanduser( path ) )
    if name is None:
        name = os.path.basename( src )
    dst = os.path.join( get_python_lib(), name + '.pth' )
    if os.path.exists( dst ):
        sys.exit( 'Error: %s exists\n%s' % (dst, open( dst ).read()) )
    print( 'Installing ' + dst )
    print( 'for path ' + src )
    try:
        open( dst, 'w' ).write( src )
    except( IOError ):
        sys.exit( 'No write permission for Python directory' )
    return


def uninstall_path( path, name=None ):
    """
    Remove path file from site-packages directory.
    """
    from distutils.sysconfig import get_python_lib
    src = os.path.realpath( os.path.expanduser( path ) )
    if name is None:
        name = os.path.basename( src )
    dst = os.path.join( get_python_lib(), name + '.pth' )
    print( 'Removing ' + dst )
    if os.path.isfile( dst ):
        try:
            os.unlink( dst )
        except( IOError ):
            sys.exit( 'No write permission for Python directory' )
    return


def prepare( job=None, **kwargs ):
    """
    Compute and display resource usage
    """

    # configure job
    if job is None:
        job, kwargs = configure( **kwargs )
    job.__dict__.update( kwargs )
    job.jobid = None

    # misc
    job.rundate = time.strftime( '%Y %b %d' )
    if hasattr( job, 'dtype' ):
        job.dtype = np.dtype( job.dtype ).str

    # parallelization
    if not hasattr( job, 'nproc' ):
        job.nproc = 1
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
    print( 'Machine: %s' % job.machine )
    print( 'Cores: %s of %s' % (job.nproc, job.maxnodes * job.maxcores) )
    print( 'Nodes: %s of %s' % (job.nodes, job.maxnodes) )

    # memory
    if not hasattr( job, 'pmem' ):
        job.pmem = job.maxram / job.ppn
    job.ram = job.pmem * job.ppn
    print( 'RAM: %sMb of %sMb per node' % (job.ram, job.maxram) )

    # SU estimate and wall time limit with extra allowance
    if hasattr( job, 'seconds' ):
        ss = job.seconds * job.ppn / job.cores
        mm = 10 + ss / 40
    else:
        ss = 3600
        mm = 60
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

    # run directory
    print( 'Run directory: ' + job.rundir )
    job.rundir = os.path.realpath( os.path.expanduser( job.rundir ) )

    return job


def skeleton( job=None, stagein=(), new=True, **kwargs ):
    """
    Create run directory tree from templates.

    Parameters
    ----------
    job : job configuration object
    stagein : list of files to copy into run directory
    new : (True|False) create new directory, or use existing

    Templates located in the configuration directory are processed with the given
    keyword parameters.  Module specific templates are used if found, in addition
    to machine specific templates.
    """

    # prepare job
    if job is None:
        job = prepare( **kwargs )
    else:
        job.__dict__.update( kwargs )

    # locations
    rundir = job.rundir
    path = os.path.realpath( os.path.dirname( __file__ ) )
    dest = os.path.realpath( os.path.expanduser( rundir ) ) + os.sep

    # create destination directory
    if new:
        os.makedirs( dest )

    # process machine templates
    if job.machine:
        d = os.path.join( path, job.machine )
        for base in os.listdir( d ):
            if base != 'conf.py':
                f = os.path.join( d, base )
                if base == 'script.sh':
                    base = job.name + '.sh'
                ff = os.path.join( dest, base )
                out = open( f ).read() % job.__dict__
                open( ff, 'w' ).write( out )
                shutil.copymode( f, ff )

    # stage directories and files
    for f in stagein:
        if f.endswith( os.sep ):
            if f.startswith( os.sep ) or '..' in f:
                sys.exit( 'Error: cannot stage %s outside rundir.' % f )
            os.makedirs( os.path.join( rundir, f ) )
        else:
            shutil.copy2( f, dest )

    return job


def launch( job=None, stagein=(), new=True, **kwargs ):
    """
    Launch or submit job.
    """

    # create skeleton
    if job is None:
        job = skeleton( stagein=stagein, new=new, **kwargs )
    else:
        job.__dict__.update( kwargs )

    # serial or mpi mode
    if not job.mode:
        job.mode = 's'
        if job.nproc > 1:
            job.mode = 'm'

    # launch command
    if not job.run:
        return job
    k = job.run
    if job.run == 'submit':
        if job.depend:
            k += '2'
    else:
        k = job.mode + '_' + k
    if k in job.launch:
        cmd = job.launch[k] % job.__dict__
    else:
        sys.exit( 'Error: %s launch mode not supported.' % k )
    print( cmd )

    # check host
    if re.match( job.hostname, job.host ) is None:
        s = job.host, job.machine
        sys.exit( 'Error: hostname %r does not match configuration %r' % s )

    # run directory
    cwd = os.getcwd()
    os.chdir( job.rundir )

    # launch
    if job.run.startswith( 'submit' ):
        p = subprocess.Popen( shlex.split( cmd ), stdout=subprocess.PIPE )
        stdout = p.communicate()[0]
        print( stdout )
        if p.returncode:
            sys.exit( 'Submit failed' )
        d = re.search( job.submit_pattern, stdout ).groupdict()
        job.__dict__.update( d )
    else:
        if job.pre:
            subprocess.check_call( job.pre, shell=True )
        subprocess.check_call( shlex.split( cmd ) )
        if job.post:
            subprocess.check_call( job.post, shell=True )

    os.chdir( cwd )
    return job

# test
def test():
    """
    Test configuration modules and machines
    """
    import pprint
    modules = None, 'cvm'
    machines = [None] + os.listdir('.')
    cwd = os.getcwd()
    os.chdir( path )
    for module in modules:
        for machine in machines:
            if machine is None or os.path.isdir( machine ):
                print 80 * '-'
                job = configure( module=module, machine=machine )[0]
                job = prepare( job, rundir='tmp', command='date', run='exec', mode='s' )
                skeleton( job )
                print( job.__doc__ )
                del( job.__dict__['__doc__'] )
                pprint.pprint( job.__dict__ )
                shutil.rmtree( 'tmp' )
    os.chdir( cwd )

# command line
if __name__ == '__main__':
    test()

