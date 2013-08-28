#!/usr/bin/env python

def test(argv=[]):
    """
    Test configurations
    """
    import os
    import cst
    try:
        import yaml
    except ImportError:
        import pprint
        dump = pprint.pprint
    else:
        def dump(x):
            print(yaml.dump(x, default_flow_style=False))
    cwd = os.getcwd()
    path = os.path.dirname(cst.__file__)
    path = os.path.join(path, 'conf')
    d = os.path.join('run', 'configure')
    os.makedirs(d)
    os.chdir(d)
    for f in ['DEFAULT'] + os.listdir(path):
        if f.endswith('.yaml') or f in ('Makefile', 'default.json', 'hostmap.json'):
            continue 
        machine = os.path.splitext(f)[0]
        kwargs = {
            'machine': machine,
            'run': 'exec',
            'argv': argv,
            'command': 'COMMAND',
            'verbose': 0,
        }
        job = cst.util.configure(**kwargs)
        job = cst.util.prepare(job)
        job = cst.util.stage(job)
        os.unlink('job.conf.json')
        if job['verbose']:
            print(80 * '-')
            print(machine)
            dump(dict(job))
        else:
            print(machine)
    os.chdir(cwd)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

