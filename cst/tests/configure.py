#!/usr/bin/env python

def test(argv=[]):
    """
    Test configurations
    """
    import os, json
    import cst
    path = os.path.dirname(cst.__file__)
    path = os.path.join(path, 'conf')
    for f in ['DEFAULT'] + os.listdir(path):
        if f in ('default.yaml', 'hostmap.yaml'):
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
            for k, v in sorted(job.items()):
                print('%s: %s' % (k, json.dumps(v)))
        else:
            print(machine)

# continue if command line
if __name__ == '__main__':
    import sys
    test(sys.argv[1:])

