def test_conf():
    """
    Test configuration modules and machines
    """
    import os, pprint
    import cst
    path = os.path.dirname(cst.conf.__file__)
    machines = ['default'] + os.listdir(path)
    kwargs = dict(
        run = 'exec',
        argv = [],
        mode = 's',
        name = 'conf',
        force = True,
        command = 'COMMAND',
    )
    for modules in [
        (cst.conf.default, cst.conf.site),
        (cst.conf.default, cst.conf.cvms, cst.conf.site),
    ]:
        for machine in machines:
            if not machine.endswith('.py'):
                continue
            if machine in ['__init__.py', 'default.py', 'cvms.py']:
                continue
            machine = machine[:-3]
            print(80 * '-')
            print(machine)
            cst.conf.site.machine = machine
            reload(cst.conf.default)
            reload(cst.conf)
            job = cst.util.configure(*modules, **kwargs)
            job = cst.util.prepare(job)
            job = cst.util.skeleton(job)
            print(job.doc)
            del(job['doc'])
            pprint.pprint(job)
    #reload(cst.conf.default)
    #reload(cst.conf.cvms)
    #reload(cst.conf.site)

# continue if command line
if __name__ == '__main__':
    test_conf()

