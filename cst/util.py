"""
Miscellaneous tools.
"""

class storage()
elif k in parameters:
            u = parameters[k]
            if u != None and v != None and type(u) != type(v):
                raise TypeError(k, v, u)


def hostname():
    import os, json, socket
    h = os.uname()
    g = socket.getfqdn()
    host = ' '.join([h[0], h[4], h[1], g])
    f = os.path.dirname(__file__)
    f = os.path.join(f, 'conf', 'hostmap.json')
    d = json.load(open(f))
    for m, h in d:
        if h in host:
            return host, m
    return host, 'Default'


def configure(args=None, defaults=None, **kwargs):
    import os, sys, pwd, json, multiprocessing

    # defaults
    if args == None:
        args = {}
    args.update(kwargs)
    path = os.path.dirname(__file__)
    path = os.path.join(path, 'conf') + os.sep
    f = path + 'default.json'
    job = json.load(open(f))

FIXME
    job = storage(**job)
    job['argv'] = sys.argv[1:]
    job['host'], job['machine'] = hostname()
    job['maxcores'] = multiprocessing.cpu_count()
    if defaults != None:
        job.update(defaults)

    # merge arguments, 1st pass
    for k in args:
        job[k] = args[k]

    # merge machine parameters
    if job['machine'] and job['machine'].lower() != 'default':
        f = path + job['machine'] + '.json'
        m = json.load(open(f))
        job.update(m)
    #for h, o in job['host_opts'].items():
    #    if h in job['host']:
    #        for k, v in o.items():
    #            job[k] = v

    # arguments, 2nd pass
    for k in args:
        job[k] = args[k]

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
        'date': time.strftime('%Y-%m-%d'),
    })

    # mode options
    k = job['mode']
    d = job['mode_opts']
    if k in d:
        job.update(d[k])

    # dependency
    if job['depend']:
        job['depend_flag'] = job['depend_flag'].format(depend=job['depend'])
    else:
        job['depend_flag'] = ''

    # notification
    if job['email']:
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
            'submission': '',
        })

        # processes
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
            job['pmem'] = job['maxram'] // job['ppn']
        job['ram'] = job['pmem'] * job['ppn']

        # SU estimate and wall time limit
        # FIXME???
        m = job['maxtime']
        job['walltime'] = '%d:%02d:00' % (m // 60, m % 60)
        sus = m // 60 * job['totalcores'] + 1

        # if resources exceeded, try another queue
        if job['ppn_range'] and job['ppn'] > job['ppn_range'][-1]:
            continue
        if job['maxtime'] and job['minutes'] > job['maxtime']:
            continue
        break

    # threads
    if job['nthread'] < 0 and 'OMP_NUM_THREADS' in os.environ:
        job['nthread'] = os.environ['OMP_NUM_THREADS']

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
        if job['minutes'] > job['maxtime']:
            print('Warning: walltime estimate exceeds limit (%s)' % job['walltime'])

    # format commands
    job['execute'] = job['execute'].format(**job)
    job['submit'] = job['submit'].format(**job)
    if job['wrapper']:
        job['wrapper'] = job['wrapper'].format(**job)
        job['submission'] = job['name'] + '.sh'
    else:
        job['submission'] = job['executable']

    return job


def launch(job=None, **kwargs):
    import os, re, shlex, subprocess

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        for k in kwargs:
            job[k] = kwargs[k]

    # launch
    if job['submit']:
        if job['wrapper']:
            f = job['name'] + '.sh'
            open(f, 'w').write(job['wrapper'])
            os.chmod(f, 755)
        c = shlex.split(job['submit'])
        out = subprocess.check_output(c)
        print(out)
        d = re.search(job['submit_pattern'], out).groupdict()
        job.update(d)
    else:
        c = shlex.split(job['execute'])
        subprocess.check_call(c)

    return job

