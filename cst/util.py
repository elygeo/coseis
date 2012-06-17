"""
Miscellaneous tools.
"""

def make(command, objects, sources):
    import os, hashlib, subprocess
    g = hashlib.sha1(' '.join(command))
    for s in sources:
        g.update(open(s).read())
    f = objects[0] + '.sha1'
    if os.path.exists(f):
        h = g.copy()
        for o in objects:
            if not os.path.exists(o):
                h = None
                break
            h.update(open(o).read())
        if h != None and h.hexdigest() == open(f).read():
            return False
        os.unlink(f)
    command += ['-o', objects[0]]
    print(' '.join(command))
    subprocess.check_call(command)
    for o in objects:
        g.update(open(o).read())
    open(f, 'w').write(g.hexdigest())
    return True


def f90modules(path):
    mods = set()
    deps = set()
    for line in open(path):
        tok = line.split()
        if tok:
            if tok[0] == 'module':
                mods.update(tok[1:])
            elif tok[0] == 'use':
                deps.update(tok[1:])
    return list(mods), list(deps)


def archive():
    import os, gzip, cStringIO
    try:
        import git
    except ImportError:
        print('Warning: Source code not archived. To enable, use')
        print('Git versioned source code and install GitPython.')
    else:
        p = os.path.dirname(__file__)
        f = os.path.join(p, 'build')
        if not os.path.exists(f):
            os.mkdir(f)
        f = os.path.join(p, 'build', 'coseis.tgz')
        s = cStringIO.StringIO()
        r = git.Repo(p)
        r.archive(s, prefix='coseis/')
        s.reset()
        gzip.open(f, 'wb').write(s.read())


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
            if isinstance(d[k], basestring) and '\n' in d[k]:
                out += k + ' = """' + d[k] + '"""\n'
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
    import os, sys, getopt
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
        if not hasattr(m, 'script'):
            f = os.path.splitext(m.__file__)[0] + '.sh'
            try:
                job.script = open(f).read()
            except IOError:
                pass

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

    # host config:
    for h, o in job.host_opts.items():
        if h in job.host:
            for k, v in o.items():
                job[k] = v

    # compiler config
    if 'mpi' in job.compiler_f90:
        job.compiler_mpi = True
    k = job.compiler
    if k in job.compiler_opts:
        job.compiler_opts = job.compiler_opts[k]

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
    if not job.compiler_mpi:
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
            walltime = '',
        ))

        # parallelization
        if job.core_range:
            job.nodes = min(job.maxnodes, (job.nproc - 1) // job.core_range[-1] + 1)
            job.ppn = (job.nproc - 1) // job.nodes + 1
            for i in job.core_range:
                job.cores = i
                if i >= job.ppn:
                    break
            job.totalcores = job.nodes * job.core_range[-1]

        # memory
        if not job.pmem:
            job.pmem = job.maxram / job.ppn
        job.ram = job.pmem * job.ppn

        # SU estimate and wall time limit
        if job.maxtime:
            job.minutes = min(job.minutes, job.maxtime)
        job.walltime = '%d:%02d:00' % (job.minutes // 60, job.minutes % 60)
        sus = job.minutes // 60 * job.totalcores + 1

        # if resources exceeded, try another queue
        if job.core_range and job.ppn > job.cores:
            continue
        if job.maxtime and job.minutes >= job.maxtime:
            continue
        break

    # messages
    print('Machine: %s' % job.machine)
    print('Cores: %s of %s' % (job.nproc, job.maxnodes * job.core_range[-1]))
    print('Nodes: %s of %s' % (job.nodes, job.maxnodes))
    print('RAM: %sMb of %sMb per node' % (job.ram, job.maxram))
    print('SUs: %s' % sus)
    print('Time limit: ' + job.walltime)

    # warnings
    if job.core_range and job.ppn > job.cores:
        print('Warning: exceeding available cores per node (%s)' % job.core_range[-1])
    if job.ram and job.ram > job.maxram:
        print('Warning: exceeding available RAM per node (%sMb)' % job.maxram)
    if job.maxtime and job.minutes == job.maxtime:
        print('Warning: exceeding maximum time limit (%02d:00)' % job.maxtime)

    # run directory
    d = job.rundir.format(**job)
    print('Run directory: ' + d)
    job.rundir = os.path.realpath(os.path.expanduser(d))

    # launch commands
    job.launch = job.launch.copy()
    for k in job.launch:
        job.launch[k] = job.launch[k].format(**job)
    if not job.launch_command:
        k = 'exec'
        if job.run:
            k = job.run
        if k not in job.launch:
            raise Exception('Error: %s launch mode not supported.' % k)
        job.launch_command = job.launch[k]

    # batch script
    job.script = job.script.format(**job)

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

    # save job
    f = os.path.join(dest, job.name + '.job.py')
    save(f, job)

    # create script
    if 'submit' in job.launch:
        f = os.path.join(dest, job.name + '.sh')
        open(f, 'w').write(job.script)
        os.chmod(f, 0755)

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

    # launch command
    if not job.run:
        return job

    # run directory
    cwd = os.getcwd()
    os.chdir(job.rundir)

    # launch
    if job.run == 'submit':
        if job.depend:
            c = job.launch['submit2']
        else:
            c = job.launch['submit']
        print(c)
        p = subprocess.Popen(shlex.split(c), stdout=subprocess.PIPE)
        stdout = p.communicate()[0]
        print(stdout)
        if p.returncode:
            raise Exception('Submit failed')
        d = re.search(job.submit_pattern, stdout).groupdict()
        job.update(d)
        save(job.name + '.job.py', job)
    else:
        save(job.name + '.job.py', job)
        for c in job.pre, job.launch_command, job.post:
            print(c)
            if '\n' in c or ';' in c or '|' in c:
                subprocess.check_call(c, shell=True)
            elif c:
                subprocess.check_call(shlex.split(c))

    os.chdir(cwd)
    return job

