"""
Miscellaneous tools.
"""

def build_cext(name):
    """
    Build C extension.
    """
    import os
    from distutils.core import setup, Extension
    import numpy as np
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    incl = [np.get_include()]
    ext = [Extension(name, [name + '.c'], include_dirs=incl)]
    setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)
    return


def build_fext(name):
    """
    Build Fortran extension.
    """
    import os, shlex
    from numpy.distutils.core import setup, Extension
    fopt = shlex.split(configure().f2py_flags)
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    ext = [Extension(name, [name + '.f90'], f2py_options=fopt)]
    setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)
    return


def archive(path):
    import os, gzip, cStringIO
    try:
        import git
        assert git.__version__ > '0.2'
    except (ImportError, AssertionError):
        print('Warning: Source code not archived. Source archiving')
        print('improves reproducibility by storing the exact code')
        print('version with the simulations results. To enable, use Git')
        print('versioned source code and install GitPython version > 2.0')
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
            if not isinstance(val, basestring) or not isinstance(v, basestring):
                raise TypeError(key, v, val)
        dict.__setitem__(self, key, val)
        return
    #def __setattr__(self, key, val):
    #    self[key] = val
    #    return
    #def __getattr__(self, key):
    #    return self[key]


def hostname():
    import os, yaml, socket
    h = os.uname()
    g = socket.getfqdn()
    host = ' '.join([h[0], h[4], h[1], g])
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'conf', 'hostmap.yaml')
    d = yaml.load(open(f))
    for m, h in d:
        if h in host:
            return host, m
    return host, 'Default'


def configure(**kwargs):
    import os, sys, pwd, json, yaml, multiprocessing

    # defaults
    path = os.path.dirname(__file__)
    path = os.path.join(path, 'conf') + os.sep
    f = path + 'default.yaml'
    job = yaml.load(open(f))
    job = storage(**job)
    job['argv'] = sys.argv[1:]
    job['host'], job['machine'] = hostname()
    job['maxcores'] = multiprocessing.cpu_count()

    # email
    try:
        import configobj
        f = os.path.expanduser('~')
        f = os.path.join(f, '.gitconfig')
        job['email'] = configobj.ConfigObj(f)['user']['email']
    except:
        job['email'] = pwd.getpwuid(os.geteuid())[0]

    # merge key-word arguments, 1st pass
    for k in kwargs:
        job[k] = kwargs[k]

    # merge machine parameters
    if job['machine'] and job['machine'].lower() != 'default':
        f = path + job['machine'] + '.yaml'
        m = yaml.load(open(f))
        job.update(m)
    for h, o in job['host_opts'].items():
        if h in job['host']:
            for k, v in o.items():
                job[k] = v

    # key-word arguments, 2nd pass
    for k in kwargs:
        job[k] = kwargs[k]

    # command line parameters
    for i in job['argv']:
        if not i.startswith('--'):
            raise Exception('Bad argument ' + i)
        k, v = i[2:].split('=')
        if len(v) and not v[0].isalpha():
            v = json.loads(v)
        job[k] = v

    return job


def prepare(job=None, **kwargs):
    """
    Compute and display resource usage
    """
    import time

    # prepare job
    if job is None:
        job = configure(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # misc
    job.update({
        'jobid': '',
        'date': time.strftime('%Y-%m-%d'),
    })

    # dependency
    if job['depend']:
        job['depend_flag'] = job['depend_flag'].format(depend=job['depend'])
    else:
        job['depend_flag'] = ''

    # notification
    if job['nproc'] > job['notify_threshold']:
        job['notify_flag'] = job['notify_flag'].format(email=job['email'])
    else:
        job['notify_flag'] = ''

    # queue options
    opts = job['queue_opts']
    if opts == []:
        opts = [(job['queue'], {})]
    elif job['queue']:
        opts = [d for d in opts if d[0] == job['queue']]
        if len(opts) == 0:
            raise Exception('Error: unknown queue: %s' % job['queue'])

    # loop over queue configurations
    for q, d in opts:
        job['queue'] = q
        job.update(d)

        # additional job parameters
        job.update({
            'nodes': 1,
            'cores': job['nproc'],
            'ppn': job['nproc'],
            'totalcores': job['nproc'],
            'ram': 0,
            'walltime': '',
        })

        # MPI parallelization
        r = job['ppn_range']
        if not r:
            r = range(1, job['maxcores'] + 1)
        job['nodes'] = min(job['maxnodes'], (job['nproc'] - 1) // r[-1] + 1)
        job['ppn'] = (job['nproc'] - 1) // job['nodes'] + 1
        for i in r:
            if i >= job['ppn']:
                break
        job['ppn'] = i
        job['totalcores'] = job['nodes'] * job['maxcores']

        # memory
        if not job['pmem']:
            job['pmem'] = job['maxram'] / job['ppn']
        job['ram'] = job['pmem'] * job['ppn']

        # SU estimate and wall time limit
        if job['maxtime']:
            job['minutes'] = min(job['minutes'], job['maxtime'])
        job['walltime'] = '%d:%02d:00' % (job['minutes'] // 60, job['minutes'] % 60)
        sus = job['minutes'] // 60 * job['totalcores'] + 1

        # if resources exceeded, try another queue
        if job['ppn_range'] and job['ppn'] > job['ppn_range'][-1]:
            continue
        if job['maxtime'] and job['minutes'] >= job['maxtime']:
            continue
        break

    # messages
    if job['verbose'] > 1:
        print('Nodes: %s' % job['nodes'])
        print('Procs per node: %s' % job['ppn'])
        print('Threads per node: %s' % job['nthread'])
        print('RAM per node: %sMb' % job['ram'])
        print('SUs: %s' % sus)
        print('Time: ' + job['walltime'])

    # warnings
    if job['verbose']:
        if job['ram'] and job['ram'] > job['maxram']:
            print('Warning: exceeding available RAM per node (%sMb)' % job['maxram'])
        if job['maxtime'] and job['minutes'] == job['maxtime']:
            print('Warning: exceeding maximum time limit (%02d:00)' % job['maxtime'])

    # launch commands
    job['execute'] = job['execute'].format(**job)
    if job['submitt']:
        job['submit'] = job['submit'].format(**job)
        job['launch'] = job['submit'].format
    if job['script']:
        job['script'] = job['script'].format(**job)
        job['submission'] = f = job['name'] + '.sh'


def stage(job=None, **kwargs):
    import os

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # write job script
    if job['script']:
        XXX chdir
        f = os.path.join(job['path'] + f)
        open(f, 'w').write(job['script'])
        os.chmod(f, 0755)

    return job

