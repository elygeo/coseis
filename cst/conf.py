#!/usr/bin/env python3

defaults = {

    # machine properties
    'host': '',
    'machine': '',
    'maxcores': 0,
    'maxnodes': 1,
    'maxram': 0,
    'maxtime': 1440,
    'queue_opts': [],
    'ppn_range': [],

    # job parameters
    'account': '',
    'binary_flag': '',
    'depend': '',
    'depend_flag': '',
    'executable': '',
    'execute': '{executable}',
    'minutes': 0,
    'mode': '',
    'mode_opts': {},
    'name': 'job',
    'notify': '',
    'notify_flag': '',
    'nproc': 1,
    'nthread': -1,
    'pmem': 0,
    'queue': '',
    'script_flag': '',
    'submit': '',
    'submit_flags': '',
    'submit_pattern': '(?P<jobid>\\d+\\S*)\\D*$',
    'verbose': 1,
    'wrapper': '',

}

hostmap = [
    ['miralac1.fst.alcf.anl.gov', 'ALCF-BGQ-Mira'],
    ['vestalac1.ftd.alcf.anl.gov', 'ALCF-BGQ-Dev'],
    ['cetuslac1.fst.alcf.anl.gov', 'ALCF-BGQ-Dev'],
    ['grotius.watson.ibm.com', 'IBM-Wat2Q'],
    ['hpc-login1.usc.edu', 'USC-HPC'],
    ['hpc-login2-l.usc.edu', 'USC-HPC'],
]

def hostname():
    import os, socket
    h = os.uname()
    g = socket.getfqdn()
    host = ' '.join([h[0], h[4], h[1], g])
    for m, h in hostmap:
        if h in host:
            return host, m
    return host, 'Default'


class typed_dict(dict):
    def __setitem__(self, k, v):
        if type(v) != type(self[k]):
            raise TypeError(key, self[k], v)
        dict.__setitem__(self, k, v)

def configure(*args, **kwargs):
    import os, sys, pwd, copy, json, multiprocessing

    # defaults
    job = copy.deepcopy(defatuls)
    job = typed_dict(defaults)
    job['host'], job['machine'] = hostname()
    job['maxcores'] = multiprocessing.cpu_count()

    # merge arguments and machine specific parameters
    d = {}
    for a in args:
        d.update(a)
    d.update(kwargs)
    if job['machine'] and job['machine'].lower() != 'default':
        path = __file__[:-3] + os.sep
        f = path + job['machine'] + '.json'
        d.update(json.load(open(f)))
    for a in args:
        d.update(a)
    for k, v in d.items():
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
        for k, v in kwargs.items():
            job[k] = v]

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
        job['depend_flag'] = job['depend_flag'].format(**job)
    else:
        job['depend_flag'] = ''

    # notification
    if job['notify']:
        job['notify_flag'] = job['notify_flag'].format(**job)
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

    # format commands
    job['execute'] = job['execute'].format(**job)
    job['submit'] = job['submit'].format(**job)
    if job['wrapper']:
        job['wrapper'] = job['wrapper'].format(**job)
        job['submission'] = job['name'] + '.sh'
    else:
        job['submission'] = job['executable']

    # messages
    if job['verbose'] > 1:
        print('Nodes: %s' % job['nodes'])
        print('Procs per node: %s' % job['ppn'])
        print('Threads per node: %s' % job['nthread'])
        print('RAM per node: %sMb' % job['ram'])
        print('SUs: %s' % sus)
        print('Time: ' + job['walltime'])
    if job['verbose']:
        if job['ram'] and job['ram'] > job['maxram']:
            print('Warning: RAM per node (%sMb) exceeded' % job['maxram'])
        if job['minutes'] > job['maxtime']:
            print('Warning: walltime limit (%s) exceeded' % job['walltime'])

    return job


def launch(job=None, **kwargs):
    import os, re, shlex, subprocess

    # prepare job
    if job is None:
        job = prepare(**kwargs)
    else:
        for k, v in kwargs.items():
            job[k] = v

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

if 
