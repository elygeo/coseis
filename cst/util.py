"""
Miscellaneous tools.
"""

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


class storage(dict):
    __doc__ = None
    def __setitem__(self, key, val):
        v = self[key]
        if val != None and v != None and type(val) != type(v):
            raise TypeError(key, v, val)
        dict.__setitem__(self, key, val)
        return
    def __setattr__(self, key, val):
        self[key] = val
        return
    def __getattr__(self, key):
        return self[key]


import numpy
prune_types_default = (
    [type(None), bool, str, unicode, int, long, float, tuple, list, dict] +
    numpy.typeDict.values()
)
del(numpy)

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
    {'aa': 0, 'aa_': 0, 'a_a': 0}
    """
    import re
    if pattern is None:
        pattern = '^_'
    if types is None:
        types = prune_types_default
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
    if expand is None:
        expand = []
    if prune_types is None:
        prune_types = prune_types_default + [np.ndarray]
    prune(d, prune_pattern, prune_types)
    n = ext_threshold
    if n == None:
        n = np.get_printoptions()['threshold']
    out = ''
    if '__doc__' in d:
        out = '"""' + __doc__ + '"""'
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


def configure(*args, **kwargs):
    import sys, getopt
    from . import conf

    # modules
    if args == ():
        args = conf.default, conf.site
    job = {'doc': args[0].__doc__}
    for m in args:
        for k in dir(m):
            if k[0] != '_':
                job[k] = getattr(m, k)
    job = storage(**job)

    # merge key-word arguments, 1st pass
    for k in kwargs:
        job[k] = kwargs[k]

    # merge machine parameters
    if job.machine:
        m = conf.__name__ + '.' + job.machine
        __import__(m)
        m = sys.modules[m]
        job.doc = m.__doc__
        for k in dir(m):
            if k[0] != '_':
                job[k] = getattr(m, k)

    # key-word arguments, 2nd pass
    for k in kwargs:
        job[k] = kwargs[k]

    # command line parameters
    if job.options:
        short, long = zip(*job.options)[:2]
        opts = getopt.getopt(job.argv, ''.join(short), long)[0]
        short = [s.rstrip(':') for s in short]
        long = [l.rstrip('=') for l in long]
        for opt, val in opts:
            key = opt.lstrip('-')
            if opt.startswith('--'):
                i = long.index(key)
            else:
                i = short.index(key)
            opt, key, cast = job.options[i][1:]
            if opt[-1] in ':=':
                job[key] = type(cast)(val)
            else:
                job[key] = cast
        if not job.prepare:
            job.run = ''
        if job.run == 'debug':
            job.optimize = 'g'

    # merge fortran flags
    k = job.fortran_serial
    if k in job.fortran_flags:
        job.fortran_flags = job.fortran_flags[k]

    return job


def prepare(job=None, **kwargs):
    """
    Compute and display resource usage
    """
    import os, time

    # prepare job
    if job is None:
        job = configure(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # misc
    job.update(dict(
        jobid = '',
        rundate = time.strftime('%Y %b %d'),
    ))

    # number of processes
    if not hasattr(job, 'nproc') or job.mode == 's':
        job.nproc = 1

    # queue options
    opts = job.queue_opts
    if opts == []:
        opts = [(job.queue, {})]
    elif job.queue:
        opts = [d for d in opts if d[0] == job.queue]
        if len(opts) == 0:
            raise Exception('Error: unknown queue: %s' % job.queue)

    # loop over queue configurations
    for q, d in opts:
        job.queue = q
        job.update(d)

        # addtional job parameters
        job.update(dict(
            nodes = 1,
            ppn = job.nproc,
            cores = job.nproc,
            totalcores = job.nproc,
            ram = 0,
            minutes = 0,
            walltime = '',
        ))

        # parallelization
        if job.maxcores:
            job.nodes = min(job.maxnodes, (job.nproc - 1) // job.maxcores + 1)
            job.ppn = (job.nproc - 1) // job.nodes + 1
            job.cores = min(job.maxcores, job.ppn)
            job.totalcores = job.nodes * job.maxcores

        # memory
        if not job.pmem:
            job.pmem = job.maxram / job.ppn
        job.ram = job.pmem * job.ppn

        # SU estimate and wall time limit with extra allowance
        seconds = job.seconds * job.ppn // job.cores
        minutes = 10 + int(seconds // 30)
        maxminutes = 60 * job.maxtime[0] + job.maxtime[1]
        if maxminutes:
            minutes = min(minutes, maxminutes)
            seconds = min(seconds * 60, maxminutes)
        job.minutes = minutes
        job.walltime = '%d:%02d:00' % (minutes // 60, minutes % 60)
        sus = seconds // 3600 * job.totalcores + 1

        # if resources exceeded, try another queue
        if job.maxcores and job.ppn > job.maxcores:
            continue
        if maxminutes and minutes == maxminutes:
            continue
        break

    # messages
    #print('Machine: %s' % job.machine)
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
    if maxminutes and minutes == maxminutes:
        print('Warning: exceeding maximum time limit (%s:%02d:00)' % job.maxtime)

    # run directory
    print('Run directory: ' + job.rundir)
    job.rundir = os.path.realpath(os.path.expanduser(job.rundir))

    return job


def skeleton(job=None, **kwargs):
    """
    Create run directory
    """
    import os, shutil

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # dry-run
    if not job.prepare:
        return job

    # create destination directory
    dest = os.path.realpath(os.path.expanduser(job.rundir)) + os.sep
    if job.force == True and os.path.isdir(dest):
        shutil.rmtree(dest)
    if job.new:
        os.makedirs(dest)

    # create script
    if 'submit' in job.launch:
        out = job.script_template.format(**job).format(**job).format(**job)
        f = os.path.join(dest, job.name + '.sh')
        open(f, 'w').write(out)

    # stage directories and files
    for f in job.stagein:
        if f.endswith(os.sep):
            if f.startswith(os.sep) or '..' in f:
                raise Exception('Error: cannot stage %s outside rundir.' % f)
            os.makedirs(os.path.join(job.rundir, f))
        else:
            shutil.copy2(f, dest)

    return job


def launch(job=None, **kwargs):
    """
    Launch or submit job.
    """
    import os, re, shlex, subprocess

    # prepare job
    if job is None:
        job = skeleton(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

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
        cmd = job.launch[k].format(**job)
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
        job.update(d)
    else:
        if job.pre:
            subprocess.check_call(job.pre, shell=True)
        subprocess.check_call(shlex.split(cmd))
        if job.post:
            subprocess.check_call(job.post, shell=True)

    os.chdir(cwd)
    return job

