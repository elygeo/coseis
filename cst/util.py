"""
Miscellaneous tools.
"""

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


def archive(path):
    import os, gzip, cStringIO
    try:
        import git
    except ImportError:
        print('Warning: Source code not archived. Source archiving')
        print('improves reproducibility by storing the exact code')
        print('version with the simulations results. To enable, use')
        print('Git versioned source code and install GitPython.')
    else:
        p = os.path.dirname(__file__)
        r = git.Repo(p)
        s = cStringIO.StringIO()
        r.archive(s, prefix='coseis/')
        s.reset()
        gzip.open(path, 'wb').write(s.read())


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

    # host configuration:
    for h, o in job.host_opts.items():
        if h in job.host:
            for k, v in o.items():
                job[k] = v

    # notification
    if job.nproc > job.notify_threshold:
        job.notify = job.notify.format(email=job.email)
    else:
        job.notify = ''

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
    if not job.build_mpi:
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

        # additional job parameters
        job.update(dict(
            nodes = 1,
            cores = job.nproc,
            ppn = job.nproc,
            totalcores = job.nproc,
            ram = 0,
            walltime = '',
        ))

        # MPI parallelization
        r = job.ppn_range
        if not r:
            r = range(1, job.maxcores + 1)
        job.nodes = min(job.maxnodes, (job.nproc - 1) // r[-1] + 1)
        job.ppn = (job.nproc - 1) // job.nodes + 1
        for i in r:
            if i >= job.ppn:
                break
        job.ppn = i
        job.totalcores = job.nodes * job.maxcores

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
        if job.ppn_range and job.ppn > job.ppn_range[-1]:
            continue
        if job.maxtime and job.minutes >= job.maxtime:
            continue
        break

    # messages
    print('Nodes: %s' % job.nodes)
    print('Procs per node: %s' % job.ppn)
    print('Threads per node: %s' % job.nthread)
    print('RAM per node: %sMb' % job.ram)
    print('SUs: %s' % sus)
    print('Time: ' + job.walltime)

    # warnings
    if job.ram and job.ram > job.maxram:
        print('Warning: exceeding available RAM per node (%sMb)' % job.maxram)
    if job.maxtime and job.minutes == job.maxtime:
        print('Warning: exceeding maximum time limit (%02d:00)' % job.maxtime)

    # directories
    print('Run directory: ' + job.rundir)
    job.rundir = os.path.realpath(os.path.expanduser(job.rundir))
    job.iodir = os.path.expanduser(job.iodir)

    # launch commands
    job.command = job.command.format(**job)
    job.launch = job.launch.format(**job)
    job.script = job.script.format(**job)
    if job.depend:
        job.submit = job.submit2.format(**job)
    else:
        job.submit = job.submit.format(**job)
    del(job['submit2'])

    return job


rundir_error = """\
For safety, run directories are no longer created or replaced.
To manually create the run directory do:

    import os
    os.makedirs(%s)
"""

def skeleton(job=None, **kwargs):
    """
    Create run directory
    """
    import os

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # test for previous runs 
    f = os.path.join(job.rundir, job.name + '.conf.py')
    if not job.force and os.path.exists(f):
        raise Exception('Existing job found. Use --force to overwrite')
    if not os.path.isdir(job.rundir):
        raise Exception(rundir_error % job.rundir)

    # create submit script
    if job.submit:
        g = os.path.join(job.rundir, job.name + '.sh')
        open(g, 'w').write(job.script)
        os.chmod(g, 0755)

    # save configuration
    del(job['options'], job['script'])
    save(f, job)

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
        print(job.submit)
        c = shlex.split(job.submit)
        p = subprocess.Popen(c, stdout=subprocess.PIPE)
        out = p.communicate()[0]
        print(out)
        if p.returncode:
            raise Exception('Submit failed')
        d = re.search(job.submit_pattern, out).groupdict()
        job.update(d)
        save(job.name + '.conf.py', job)
    else:
        save(job.name + '.conf.py', job)
        for c in job.pre, job.launch, job.post:
            if c:
                print(c)
                if '\n' in c or ';' in c or '|' in c:
                    subprocess.check_call(c, shell=True)
                elif c:
                    subprocess.check_call(shlex.split(c))

    os.chdir(cwd)
    return job

