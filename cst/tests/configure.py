#!/usr/bin/env python

def test(argv=[]):
    """
    Test configurations
    """
    import os, pprint
    import cst
    p = os.path.dirname(cst.conf.__file__)
    machines = ['default'] + os.listdir(p)
    d = 'run/configure'
    os.makedirs(d)
    kwargs = {
        'rundir': d,
        'run': 'exec',
        'argv': argv,
        'command': 'COMMAND',
        'force': True,
    }
    for machine in machines:
        if not machine.endswith('.py'):
            continue
        if machine in ['__init__.py', 'default.py', 'site.py', 'cvms.py']:
            continue
        machine = machine[:-3]
        print(80 * '-')
        print('Machine: ' + machine)
        cst.conf.default.machine = machine
        job = cst.util.configure(cst.conf.default, **kwargs)
        job = cst.util.prepare(job)
        job = cst.util.skeleton(job)
        if 0:
            print(job['doc'])
            del(job['doc'])
            pprint.pprint(job)
            reload(cst.conf.cvms)
            reload(cst.conf.default)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

