"""
Miscellaneous tools.
"""

def build_ext():
    """
    Compile C extensions
    """
    import os
    from distutils.core import setup, Extension
    import numpy as np
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    if not os.path.exists('trinterp.so'):
        incl = [np.get_include()]
        ext = [Extension('trinterp', ['trinterp.c'], include_dirs=incl)]
        setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)


def build_fext(**kwargs):
    """
    Compile Fortran extentions
    """
    import os, shlex
    from numpy.distutils.core import setup, Extension
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    if not os.path.exists('rspectra.so'):
        fopt = shlex.split(configure(**kwargs)[0].f2py_flags)
        ext = [Extension('rspectra', ['rspectra.f90'], f2py_options=fopt)]
        setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)


def archive():
    import os, gzip, tarfile
    try:
        import git
    except ImportError:
        print('Warning: Source code not archived. To enable, use')
        print('Git versioned source code and install GitPython.')
    else:
        path = os.path.dirname(__file__)
        repo = git.Repo(path)
        open('tmp.log', 'w').write(repo.git.log())
        repo.archive(open('tmp.tar', 'w'), prefix='coseis/')
        tarfile.open('tmp.tar', 'a').add('tmp.log', 'coseis/changelog.txt')
        tar = open('tmp.tar', 'rb').read()
        os.remove('tmp.tar')
        os.remove('tmp.log')
        f = os.path.join(path, 'build', 'coseis.tgz')
        gzip.open(f, 'wb').write(tar)


def prune(d, pattern=None, types=None):
    """
    Delete dictionary keys with specified name pattern or types

    Parameters
    ----------
    d: dict of parameters
    pattern: regular expression of parameter names to prune
        default = '(^_)|(_$)|(^.$)|(^..$)'
    types: list of parameters types to keep
        default = Numpy types + [NoneType, bool, str, int, lone, float, tuple, list, dict]
        Functions, classes, and modules are pruned by default.

    >>> prune({'aa': 0, 'aa_': 0, '_aa': 0, 'a_a': 0, 'b_b': prune})
    {'a_a': 0}
    """
    import re
    import numpy as np
    if pattern is None:
        pattern = '(^_)|(_$)|(^.$)|(^..$)'

    if types is None:
        types = set(
            np.typeDict.values() +
            [np.ndarray, type(None), bool, str, unicode, int, long, float, tuple, list, dict]
        )
    grep = re.compile(pattern)
    for k in d.keys():
        if grep.search(k) or type(d[k]) not in types:
            del(d[k])
    return d


def open_excl(filename, *args):
    """
    Thread-safe exclusive file open. Silent return if exists.
    """
    import os
    if os.path.exists(filename):
        return
    try:
        os.mkdir(filename + '.lock')
    except OSError:
        return
    fh = open(filename, *args)
    os.rmdir(filename + '.lock')
    return fh


def save(fh, d, expand=None, keep=None, header='', prune_pattern=None,
    prune_types=None, ext_threshold=None, ext_raw=False):
    """
    Write variables from a dict into a Python source file.
    """
    import os
    import numpy as np
    if fh is not None:
        if isinstance(fh, basestring):
            fh = open(os.path.expanduser(fh), 'w')
    if type(d) is not dict:
        d = d.__dict__
    if expand is None:
        expand = []
    prune(d, prune_pattern, prune_types)
    n = ext_threshold
    if n == None:
        n = np.get_printoptions()['threshold']
    out = ''
    has_array = False
    for k in sorted(d):
        if k not in expand and (keep is None or k in keep):
            if type(d[k]) == np.ndarray and fh is not None:
                has_array = True
                if d[k].size > n:
                    f = os.path.dirname(fh.name)
                    if ext_raw:
                        f = os.path.join(f, k + '.bin')
                        d[k].tofile(f)
                        m = k, k, d[k].dtype, d[k].shape
                        out += "%s = memmap('%s.bin', %s, mode='c', shape=%s)\n" % m
                    else:
                        f = os.path.join(f, k + '.npy')
                        np.save(f, d[k])
                        out += "%s = load('%s.npy', mmap_mode='c')\n" % (k, k)
            else:
                out += '%s = %r\n' % (k, d[k])
    if has_array:
        out = header + 'from numpy import array, load, float32, memmap\n' + out
    else:
        out = header + out
    for k in expand:
        if k in d:
            if type(d[k]) is tuple:
                out += k + ' = (\n'
                for item in d[k]:
                    out += '    %r,\n' % (item,)
                out += ')\n'
            elif type(d[k]) is list:
                out += k + ' = [\n'
                for item in d[k]:
                    out += '    %r,\n' % (item,)
                out += ']\n'
            elif type(d[k]) is dict:
                out += k + ' = {\n'
                for item in sorted(d[k]):
                    out += '    %r: %r,\n' % (item, d[k][item])
                out += '}\n'
            else:
                raise Exception('Cannot expand %s type %s' % (k, type(d[k])))
    if fh is not None:
        fh.write(out)
    return out


class load():
    """
    Load variables from Python source files.
    """
    def __init__(self, fh, d=None, prune_pattern=None, prune_types=None):
        import os
        if isinstance(fh, basestring):
            fh = open(os.path.expanduser(fh))
        if d is not None:
            d = {}
        exec fh in d
        prune(d, prune_pattern, prune_types)
        self.__dict__ = d
        return


def configure(modules=None, machine=None, **kwargs):
    """
    Merge module, keyword, and command line parameters.

    Parameters
    ----------
    modules: list of module names.
    machine: machine name.
    save_site: save site specific parameters (machine, account)
    **kwargs: override parameters supplied as keyword arguments

    Returns
    -------
    job: object containing merged parameters as object attributes.
    kwarg: dictionary containing unmatched parameters
    """
    import os, copy, getopt
    from . import conf

    # defaults
    job = copy.deepcopy(conf.__dict__)
    try:
        from . import site
    except ImportError:
        pass
    else:
        job.update(site.__dict__)

    # modules
    if modules == None:
        modules = []
    if machine:
        job['machine'] = machine
    if job['machine']:
        modules += [job['machine']]
    for m in modules:
        job.update(__import__('conf.' + m, level=1).__dict__)
    for m in modules:
        k = m + '_'
        if k in job:
            job.update(job[k])

    # function parameters
    kwargs = kwargs.copy()
    for k in kwargs.copy():
        if k in job:
            job[k] = kwargs[k]
            del(kwargs[k])

    # command line parameters
    options = job['options']
    if options:
        short, long = zip(*options)[:2]
        opts = getopt.getopt(job['argv'], ''.join(short), long)[0]
        short = [s.rstrip(':') for s in short]
        long = [l.rstrip('=') for l in long]
        for opt, val in opts:
            key = opt.lstrip('-')
            if opt.startswith('--'):
                i = long.index(key)
            else:
                i = short.index(key)
            opt, key, cast = options[i][1:]
            if opt[-1] in ':=':
                job[key] = type(cast)(val)
            else:
                job[key] = cast

    # fortran flags
    if 'fortran_flags_default_' in job:
        if 'fortran_flags' not in job:
            k = job['fortran_serial']
            job['fortran_flags'] = job['fortran_flags_default_'][k]

    # prune unneeded variables and create configuration object
    d = job['__doc__']
    prune(job)
    job['__doc__'] = d
    prune(kwargs)
    class obj:
        pass
    obj = obj()
    obj.__dict__ = job

    return obj, kwargs


def make(compiler, object_, source):
    """
    An alternative Make that uses state files.
    """
    import os, glob, shlex, difflib, subprocess

    object_ = os.path.expanduser(object_)
    source = [os.path.expanduser(f) for f in source if f]
    statedir = os.path.join(os.path.dirname(object_), 'build-state')
    if not os.path.isdir(statedir):
        os.mkdir(statedir)
    statefile = os.path.join(statedir, os.path.basename(object_))
    if isinstance(compiler, basestring):
        compiler = shlex.split(compiler)
    else:
        compiler = list(compiler)
    command = compiler + [object_] + source
    state = [' '.join(command) + '\n']
    for f in source:
        state += open(f).readlines()
    compile_ = True
    if os.path.isfile(object_):
        try:
            oldstate = open(statefile).readlines()
        except IOError:
            pass
        else:
            diff = ''.join(difflib.unified_diff(oldstate, state, n=0))
            if diff:
                print(diff)
            else:
                compile_ = False
    if compile_:
        try:
            os.unlink(statefile)
        except OSError:
            pass
        print('\n' + ' '.join(command))
        subprocess.check_call(command)
        open(statefile, 'w').writelines(state)
        for pat in '*.o', '*.mod', '*.ipo', '*.il', '*.stb':
            for f in glob.glob(pat):
                os.unlink(f)
    return compile_


def prepare(job=None, **kwargs):
    """
    Compute and display resource usage
    """
    import os, time
    import numpy as np

    # configure job
    if job is None:
        job, kwargs = configure(**kwargs)
    job.__dict__.update(kwargs)
    job.jobid = None

    # misc
    job.rundate = time.strftime('%Y %b %d')
    if hasattr(job, 'dtype'):
        job.dtype = np.dtype(job.dtype).str

    # number of processes
    if not hasattr(job, 'nproc') or job.mode == 's':
        job.nproc = 1

    # queue options
    opts = job.queue_opts
    if opts == None:
        opts = [(job.queue, {})]
    elif job.queue is not None:
        opts = [d for d in opts if d[0] == job.queue]
        if len(opts) == 0:
            raise Exception('Error: unknown queue: %s' % job.queue)

    # loop over queue configurations
    for q, d in opts:
        job.queue = q
        job.__dict__.update(d)

        # parallelization
        if job.maxcores and job.maxnodes:
            job.nodes = min(job.maxnodes, (job.nproc - 1) // job.maxcores + 1)
            job.ppn = (job.nproc - 1) // job.nodes + 1
            job.cores = min(job.maxcores, job.ppn)
            job.totalcores = job.nodes * job.maxcores
        else:
            job.nodes = 1
            job.ppn = job.nproc
            job.cores = job.nproc
            job.totalcores = job.nproc

        # memory
        if not hasattr(job, 'pmem'):
            job.pmem = job.maxram / job.ppn
        job.ram = job.pmem * job.ppn

        # SU estimate and wall time limit with extra allowance
        if hasattr(job, 'seconds'):
            seconds = job.seconds * job.ppn // job.cores
            minutes = 10 + int(seconds // 30)
        else:
            seconds = 3600
            minutes = 60
        if job.maxtime:
            maxminutes = 60 * job.maxtime[0] + job.maxtime[1]
            minutes = min(minutes, maxminutes)
        job.minutes = minutes
        job.walltime = '%d:%02d:00' % (minutes // 60, minutes % 60)
        sus = seconds // 3600 * job.totalcores + 1

        # if resources exceeded, try another queue
        if job.maxcores and job.ppn > job.maxcores:
            continue
        if job.maxtime and minutes == maxminutes:
            continue
        break

    # messages
    print('Machine: %s' % job.machine)
    print('Cores: %s of %s' % (job.nproc, job.maxnodes * job.maxcores))
    print('Nodes: %s of %s' % (job.nodes, job.maxnodes))
    print('RAM: %sMb of %sMb per node' % (job.ram, job.maxram))
    print('SUs: %s' % sus)
    print('Time limit: ' + job.walltime)

    # warnings
    if job.maxcores and job.ppn > job.maxcores:
        print('Warning: exceeding available cores per node (%s)' % job.maxcores)
    if job.ram and job.ram > job.maxram:
        print('Warning: exceeding available RAM per node (%sMb)' % job.maxram)
    if job.maxtime and minutes == maxminutes:
        print('Warning: exceeding maximum time limit (%s:%02d:00)' % job.maxtime)

    # run directory
    print('Run directory: ' + job.rundir)
    job.rundir = os.path.realpath(os.path.expanduser(job.rundir))

    return job


def skeleton(job=None, stagein=(), new=True, **kwargs):
    """
    Create run directory tree from templates.

    Parameters
    ----------
    job: job configuration object
    stagein: list of files to copy into run directory
    new: (True|False) create new directory, or use existing

    Templates located in the configuration directory are processed with the given
    keyword parameters.  Module specific templates are used if found, in addition
    to machine specific templates.
    """
    import os, shutil

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        job.__dict__.update(kwargs)

    # locations
    rundir = job.rundir
    path = os.path.join(os.path.dirname(__file__), 'conf')
    dest = os.path.realpath(os.path.expanduser(rundir)) + os.sep

    # create destination directory
    if new:
        os.makedirs(dest)

    # process machine templates
    if job.machine:
        d = os.path.join(path, job.machine)
        for base in os.listdir(d):
            if base != 'conf.py':
                f = os.path.join(d, base)
                if base == 'script.sh':
                    base = job.name + '.sh'
                ff = os.path.join(dest, base)
                out = open(f).read().format(**job.__dict__)
                open(ff, 'w').write(out)
                shutil.copymode(f, ff)

    # stage directories and files
    for f in stagein:
        if f.endswith(os.sep):
            if f.startswith(os.sep) or '..' in f:
                raise Exception('Error: cannot stage %s outside rundir.' % f)
            os.makedirs(os.path.join(rundir, f))
        else:
            shutil.copy2(f, dest)

    return job


def launch(job=None, stagein=(), new=True, **kwargs):
    """
    Launch or submit job.
    """
    import os, re, shlex, subprocess

    # create skeleton
    if job is None:
        job = skeleton(stagein=stagein, new=new, **kwargs)
    else:
        job.__dict__.update(kwargs)

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
        cmd = job.launch[k].format(**job.__dict__)
    else:
        raise Exception('Error: %s launch mode not supported.' % k)
    print(cmd)

    # check host
    if re.match(job.hostname, job.host) is None:
        s = job.host, job.machine
        raise Exception('Error: hostname %r does not match configuration %r' % s)

    # run directory
    cwd = os.getcwd()
    os.chdir(job.rundir)

    # launch
    if job.run.startswith('submit'):
        p = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE)
        stdout = p.communicate()[0]
        print(stdout)
        if p.returncode:
            raise Exception('Submit failed')
        d = re.search(job.submit_pattern, stdout).groupdict()
        job.__dict__.update(d)
    else:
        if job.pre:
            subprocess.check_call(job.pre, shell=True)
        subprocess.check_call(shlex.split(cmd))
        if job.post:
            subprocess.check_call(job.post, shell=True)

    os.chdir(cwd)
    return job


