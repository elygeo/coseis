def test_conf():
    """
    Test configuration modules and machines
    """
    import os, shutil, pprint
    import cst
XXX FIXME
    cwd = os.getcwd()
    os.chdir(os.path.join(os.path.dirname(__file__), '..', 'conf'))
    modules = None, 'cvms'
    machines = [None] + os.listdir('.')
    for module in modules:
        for machine in machines:
            if machine is None or os.path.isdir(machine):
                print(80 * '-')
                print machine
                job = cst.util.configure(module=module, machine=machine, argv=[])[0]
                job = cst.util.prepare(job, rundir='tmp', command='date', run='exec', mode='s')
                cst.util.skeleton(job)
                print(job.__doc__)
                del(job.__dict__['__doc__'])
                pprint.pprint(job.__dict__)
                shutil.rmtree('tmp')
    os.chdir(cwd)

# continue if command line
if __name__ == '__main__':
    test_conf()

