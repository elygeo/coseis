def test_conf():
    """
    Test configuration modules and machines
    """
    import os, shutil, pprint
    import cst
    path = os.path.dirname(cst.conf.__file__)
    modules = cst.conf.default, cst.conf.cvms
    machines = ['default'] + os.listdir(path)
    for module in modules:
        for machine in machines:
            if machine.endswith('.pyc'):
                continue
            if machine == 'default.py' or machine == 'cvms.py':
                continue
            if machine.endswith('.py'):
                machine = machine[:-3]
            print(80 * '-')
            print(machine)
            cst.conf.site.machine = machine
            reload(cst.conf.default)
            reload(cst.conf)
            job = cst.util.configure(
                module,
                argv = [],
                rundir = 'tmp',
                command = 'date',
                run = 'exec',
                mode = 's',
            )[0]
            cst.util.prepare(job)
            cst.util.skeleton(job)
            shutil.rmtree('tmp')
            pprint.pprint(job)
            print(cst.conf.default.__doc__)

# continue if command line
if __name__ == '__main__':
    test_conf()

