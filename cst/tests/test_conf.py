def test_conf():
    """
    Test configuration modules and machines
    """
    import os, shutil, pprint
    import cst
    path = os.path.dirname(cst.conf.__file__)
    modules = cst.conf.default, cst.conf.cvms
    machines = [None] + os.listdir(path)
    for module in modules:
        for machine in machines:
            if machine.endswith('.pyc'):
                continue
            if machine == 'default.py' or machine == 'cvms.py':
                continue
            print(80 * '-')
            print machine
            job = cst.util.configure(module, argv=[])[0]
            job = cst.util.prepare(job, rundir='tmp', command='date', run='exec', mode='s')
            cst.util.skeleton(job)
            print(job.__doc__)
            del(job.__dict__['__doc__'])
            pprint.pprint(job.__dict__)
            shutil.rmtree('tmp')

# continue if command line
if __name__ == '__main__':
    test_conf()

