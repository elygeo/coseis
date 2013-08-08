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
            if not isinstance(val, basestring) or not isinstance(v, basestring):
                raise TypeError(key, v, val)
        dict.__setitem__(self, key, val)
        return
    def __setattr__(self, key, val):
        self[key] = val
        return
    def __getattr__(self, key):
        return self[key]


def configure(**kwargs):
    import os, sys, json, pwd, socket, multiprocessing
    import numpy as np

    # defaults
    path = os.path.join(os.path.dirname(__file__), 'conf') + os.sep
    f = path + 'default.json'
    job = json.load(open(f))
    job['rundir'] = os.getcwd()
    job['dtype'] = np.dtype('f').str
    job['argv'] = sys.argv[1:]
    job = storage(**job)
    job['maxcores'] = multiprocessing.cpu_count()

    # host
    h = os.uname()
    g = socket.getfqdn()
    job['host'] = ' '.join([h[0], h[4], h[1], g])

    # email
    try:
        import configobj
        f = os.path.join(os.path.expanduser('~'), '.gitconfig')
        job['email'] = configobj.ConfigObj(f)['user']['email']
    except:
        job['email'] = pwd.getpwuid(os.geteuid())[0]

    # guess machine
    for m, h in job['host_map']:
        if h in job['host']:
            job['machine'] = m
            break
    del(job['host_map'])

    # merge key-word arguments, 1st pass
    for k in kwargs:
        job[k] = kwargs[k]

    # merge machine parameters
    if job['machine']:
        f = path + job['machine'] + '.json'
        m = json.load(open(f))
        for k in m:
            job[k] = m[k]
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
        job[k] = json.loads(v)

    # notification
    if job['nproc'] > job['notify_threshold']:
        job['notify'] = job['notify'].format(email=job['email'])
    else:
        job['notify'] = ''

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
    job.update({
        'jobid': '',
        'rundate': time.strftime('%Y %b %d'),
    })

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
    if job['verbose'] > 0:
        if job['ram'] and job['ram'] > job['maxram']:
            print('Warning: exceeding available RAM per node (%sMb)' % job['maxram'])
        if job['maxtime'] and job['minutes'] == job['maxtime']:
            print('Warning: exceeding maximum time limit (%02d:00)' % job['maxtime'])

    # directories
    job['rundir'] = os.path.realpath(os.path.expanduser(job['rundir']))
    job['iodir'] = os.path.expanduser(job['iodir'])

    # launch commands
    job['command'] = job['command'].format(**job)
    job['launch'] = job['launch'].format(**job)
    job['script'] = job['script'].format(**job)
    if job['depend']:
        job['submit'] = job['submit2'].format(**job)
    else:
        job['submit'] = job['submit'].format(**job)
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
    Create run files
    """
    import os, json

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # test for previous runs 
    f = os.path.join(job['rundir'], job['name'] + '.conf.json')
    if not job['force'] and os.path.exists(f):
        raise Exception('Existing job found. Use --force=True to overwrite')
    if not os.path.isdir(job['rundir']):
        raise Exception(rundir_error % job['rundir'])

    # create submit script
    if job['submit']:
        g = os.path.join(job['rundir'], job['name'] + '.sh')
        open(g, 'w').write(job['script'])
        os.chmod(g, 0755)

    # save configuration
    f = open(f, 'w')
    json.dump(job, f, indent=4, sort_keys=True)

    return job


def launch(job=None, **kwargs):
    """
    Launch or submit job.
    """
    import os, re, shlex, subprocess, json

    # prepare job
    if job is None:
        job = skeleton(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # launch command
    if not job['run']:
        return job

    # run directory
    cwd = os.getcwd()
    os.chdir(job['rundir'])

    # launch
    if job['run'] == 'submit':
        print(job['submit'])
        c = shlex.split(job['submit'])
        p = subprocess.Popen(c, stdout=subprocess.PIPE)
        out = p.communicate()[0]
        print(out)
        if p.returncode:
            raise Exception('Submit failed')
        d = re.search(job['submit_pattern'], out).groupdict()
        job.update(d)
        f = open(job['name'] + '.conf.json', 'w')
        json.dump(job, f, indent=4, sort_keys=True)
    else:
        f = open(job['name'] + '.conf.json', 'w')
        json.dump(job, f, indent=4, sort_keys=True)
        for c in job['pre'], job['launch'], job['post']:
            if c:
                print(c)
                if '\n' in c or ';' in c or '|' in c:
                    subprocess.check_call(c, shell=True)
                elif c:
                    subprocess.check_call(shlex.split(c))

    os.chdir(cwd)
    return job

