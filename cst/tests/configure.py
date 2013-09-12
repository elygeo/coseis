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
    path = os.path.dirname(cst.__file__)
    path = os.path.join(path, 'conf')
    for f in ['DEFAULT'] + os.listdir(path):
        if f.endswith('.yaml') or f in ('Makefile', 'default.json', 'hostmap.json'):
            continue 
        machine = os.path.splitext(f)[0]
        job = cst.util.prepare(
            machine = machine,
            command = 'COMMAND',
            verbose = 0,
            argv = argv,
        )
        if job['verbose']:
            print(80 * '-')
            print(machine)
            dump(dict(job))
        else:
            print(machine)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

