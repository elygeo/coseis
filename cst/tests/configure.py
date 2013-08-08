#!/usr/bin/env python

def test(argv=[]):
    """
    Test configurations
    """
    import os, pprint
    import cst
    p = os.path.dirname(cst.__file__)
    p = os.path.join(p, 'conf')
    d = os.path.join('run', 'configure')
    if not os.path.exists(d):
        os.makedirs(d)
    os.chdir(d)
    for f in os.listdir(p):
        if not f.endswith('yaml') or f == 'default.yaml':
            continue 
        machine = os.path.splitext(f)[0]
        kwargs = {
            'machine': machine,
            'run': 'exec',
            'argv': argv,
            'command': 'COMMAND',
            'force': True,
        }
        job = cst.util.configure(**kwargs)
        job = cst.util.prepare(job)
        job = cst.util.skeleton(job)
        if job['verbose'] > 1:
            print(machine)
            pprint.pprint(job)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

