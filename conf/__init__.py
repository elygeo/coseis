#!/usr/bin/env python
"""
Machine configuration
"""
import os, sys, re, shutil, getopt, subprocess, shlex
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

def configure( module='default', machine=None, save_machine=False, options=None, **kwargs ):
    """
    Merge module, machine, keyword, and command line parameters.

    Parameters
    ----------
    module : module name
    machine : machine name
    save_machine : remember machine name
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
        f = os.path.join( path, machine )
        if not os.path.isdir( f ):
            sys.exit( 'Error: configuration %s not found.' % machine )
        f = os.path.join( path, machine, 'conf.py' )
        if os.path.isfile( f ):
            exec open( f ) in job
        if save_machine:
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
        job['rundir'] = os.path.realpath( os.path.expanduser( job['rundir'] ) )

    # configuration object
    job = namespace( job )

    return job, kwargs

def prepare( job=None, **kwargs ):
    """
    Compute and display resource usage
    """

    # configure job
    if job == None:
        job, kwargs = configure( **kwargs )
    job.__dict__.update( kwargs )
    job.jobid = None

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
    print( 'Machine: ' + job.machine )
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

    # launch command
    if job.run:
        k = job.run
        if job.run == 'submit':
            if job.depend:
                k += '2'
        elif job.mode:
            k = job.mode + '_' + k
        if k in job.launch:
            job.launch = job.launch[k] % job.__dict__
        else:
            sys.exit( 'Error: %s launch mode not supported.' % k )
    else:
        job.launch = None
    job.pre = job.pre % job.__dict__
    job.post = job.post % job.__dict__

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
    if job == None:
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

    # process templates
    for m in job.module, job.machine:
        d = os.path.join( path, m )
        for base in os.listdir( d ):
            if base != 'conf.py':
                f = os.path.join( d, base )
                if base == 'script.sh':
                    base = job.name + '.sh'
                ff = os.path.join( dest, base )
                out = open( f ).read() % job.__dict__
                open( ff, 'w' ).write( out )
                shutil.copymode( f, ff )

    # link or copy files
    for f in stagein:
        shutil.copy2( f, dest )

    return job

def launch( job=None, stagein=(), new=True, **kwargs ):
    """
    Launch or submit job.
    """

    # create skeleton
    if job == None:
        job = skeleton( stagein=stagein, new=new, **kwargs )
    else:
        job.__dict__.update( kwargs )
    if not job.launch:
        return job

    # check host
    if job.host not in job.hosts:
        sys.exit( 'Error: hostname %r does not match configuration %r'
            % (job.host, job.machine) )

    # run directory
    cwd = os.getcwd()
    os.chdir( job.rundir )

    # launch
    print( job.launch )
    if job.run.startswith( 'submit' ):
        p = subprocess.Popen( shlex.split( job.launch ), stdout=subprocess.PIPE )
        stdout = p.communicate()[0]
        print( stdout )
        if p.returncode:
            sys.exit( 'Submit failed' )
        d = re.search( job.submit_pattern, stdout ).groupdict()
        job.__dict__.update( d )
    else:
        if job.pre:
            subprocess.check_call( job.pre, shell=True )
        subprocess.check_call( shlex.split( job.launch ) )
        if job.post:
            subprocess.check_call( job.post, shell=True )

    os.chdir( cwd )
    return job

# run tests if called from the command line
if __name__ == '__main__':
    import pprint
    modules = 'default', 'sord', 'cvm'
    machines = os.listdir('.')
    for module in modules:
        for machine in machines:
            if os.path.isdir( machine ) and machine not in modules:
                print 80 * '-'
                job = configure( module=module, machine=machine )[0]
                job = prepare( job, rundir='tmp', bin='date', run='exec', mode='s' )
                skeleton( job )
                pprint.pprint( job.__dict__ )
                shutil.rmtree( 'tmp' )

