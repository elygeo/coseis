#!/usr/bin/env python

def test(argv=[]):
    """
    Test configurations
    """
    import os, pprint
    import cst
    cwd = os.getcwd()
    path = os.path.dirname(cst.__file__)
    path = os.path.join(path, 'conf')
    d = os.path.join('run', 'configure')
    os.makedirs(d)
    os.chdir(d)
    for f in os.listdir(path):
        if not f.endswith('yaml'):
            continue 
        machine = os.path.splitext(f)[0]
        kwargs = {
            'machine': machine,
            'run': 'exec',
            'argv': argv,
            'command': 'COMMAND',
            'verbose': 0,
            'force': True,
        }
        job = cst.util.configure(**kwargs)
        job = cst.util.prepare(job)
        job = cst.util.stage(job)
        if job['verbose']:
            print(80 * '-')
            print(machine)
            pprint.pprint(job)
        else:
            print(machine)
    os.chdir(cwd)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

