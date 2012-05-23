def test_conf():
    """
    Test configuration modules and machines
    """
    import os, shutil, pprint
    import cst
    path = os.path.dirname(cst.conf.__file__)
    machines = ['default'] + os.listdir(path)
    for modules in [
        (cst.conf.default, cst.conf.site),
        (cst.conf.default, cst.conf.cvms, cst.conf.site),
    ]:
        for machine in machines:
            if machine.endswith('.pyc'):
                continue
            if machine in ['__init__.py', 'default.py', 'cvms.py']:
                continue
            if machine.endswith('.py'):
                machine = machine[:-3]
            print(80 * '-')
            print(machine)
            cst.conf.site.machine = machine
            reload(cst.conf.default)
            reload(cst.conf)
            job = cst.util.configure(
                modules,
                argv = [],
                rundir = 'tmp',
                command = 'date',
                run = 'exec',
                mode = 's',
            )[0]
            cst.util.prepare(job)
            cst.util.skeleton(job)
            shutil.rmtree('tmp')
            print(job.doc)
            del(job['doc'])
            pprint.pprint(job)

# continue if command line
if __name__ == '__main__':
    test_conf()

