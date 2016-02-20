#!/usr/bin/env python3
"""
Configure and launch jobs.
"""
import os
import re
import sys
import json
import time
import json
import copy
import shlex
import socket
import subprocess
import multiprocessing

defaults = {
    'host': '',
    'machine': '',
    'maxcores': 0,
    'maxnodes': 1,
    'maxram': 0,
    'maxtime': 1440,
    'queue_opts': [],
    'ppn_range': [],
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


class typed_dict(dict):
    def __setitem__(self, k, v):
        if isinstance(self[k], type(v)):
            raise TypeError(k, self[k], v)
        dict.__setitem__(self, k, v)


def json_args(argv):
    d = {}
    l = []
    for k in argv:
        if k[0] == '-':
            k = k.lstrip('-')
            if '=' in k:
                k, v = k.split('=')
                if len(v) and not v[0].isalpha():
                    v = json.loads(v)
                d[k] = v
            else:
                d[k] = True
        elif k[0] in '{[':
            d.update(json.loads(k))
        else:
            l.append(k)
    return d, l


def hostname():
    h = os.uname()
    g = socket.getfqdn()
    host = ' '.join([h[0], h[4], h[1], g])
    for m, h in hostmap:
        if h in host:
            return host, m
    return host, 'Default'


def configure(*args, **kwargs):
    job = copy.deepcopy(defaults)
    job = typed_dict(job)
    job['host'], job['machine'] = hostname()
    job['maxcores'] = multiprocessing.cpu_count()
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
    Compute resource usage. Loop over queue configurations and if resources
    exceeded, try another queue
    """
    if job is None:
        job = configure(**kwargs)
    else:
        for k, v in kwargs.items():
            job[k] = v
    job.update({
        'jobid': '',
        'date': time.strftime('%Y-%m-%d'),
    })
    k = job['mode']
    d = job['mode_opts']
    if k in d:
        job.update(d[k])
    if job['depend']:
        job['depend_flag'] = job['depend_flag'].format(**job)
    else:
        job['depend_flag'] = ''
    if job['notify']:
        job['notify_flag'] = job['notify_flag'].format(**job)
    else:
        job['notify_flag'] = ''
    opts = job['queue_opts']
    if opts == []:
        opts = [(job['queue'], {})]
    elif job['queue']:
        opts = [d for d in opts if d[0] == job['queue']]
        if len(opts) == 0:
            raise Exception('Error: unknown queue: %s' % job['queue'])
    for q, d in opts:
        job['queue'] = q
        job.update(d)
        job.update({
            'nodes': 1,
            'cores': job['nproc'],
            'ppn': job['nproc'],
            'totalcores': job['nproc'],
            'ram': 0,
            'walltime': '',
            'submission': '',
        })
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
        if not job['pmem']:
            job['pmem'] = job['maxram'] // job['ppn']
        job['ram'] = job['pmem'] * job['ppn']
        m = job['maxtime']
        job['walltime'] = '%d:%02d:00' % (m // 60, m % 60)
        # sus = m // 60 * job['totalcores'] + 1
        if job['ppn_range'] and job['ppn'] > job['ppn_range'][-1]:
            continue
        if job['maxtime'] and job['minutes'] > job['maxtime']:
            continue
        break
    if job['nthread'] < 0 and 'OMP_NUM_THREADS' in os.environ:
        job['nthread'] = os.environ['OMP_NUM_THREADS']
    job['execute'] = job['execute'].format(**job)
    job['submit'] = job['submit'].format(**job)
    if job['wrapper']:
        job['wrapper'] = job['wrapper'].format(**job)
        job['submission'] = job['name'] + '.sh'
    else:
        job['submission'] = job['executable']
    if job['ram'] and job['ram'] > job['maxram']:
        print('Warning: RAM per node (%sMb) exceeded' % job['maxram'])
    if job['minutes'] > job['maxtime']:
        print('Warning: walltime limit (%s) exceeded' % job['walltime'])
    return job


def launch(job=None, **kwargs):
    if job is None:
        job = prepare(**kwargs)
    else:
        for k, v in kwargs.items():
            job[k] = v
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


if __name__ == '__main__':
    d = json_args(sys.argv[1:])
    d = configure(d)
    d = json.dumps(d, indent=4, sort_keys=True)
    print(d)
