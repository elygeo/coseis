from . import hello, sord_mpi, sord_pml, sord_kostrov


def test():
    passed = []
    failed = []
    for m in [
        hello,
        sord_mpi,
        sord_pml,
        sord_kostrov,
    ]:
        c = '%s.test()' % m.__name__
        print('-' * 80)
        print('>>> ' + c)
        try:
            m.test(submit='')
            passed.append('PASSED: ' + c)
        except Exception as e:
            failed.append('FAILED: %s: %s' % (c, e.message))
    print('\n' + '\n'.join(passed))
    print('\n' + '\n'.join(failed))
    return


if __name__ == "__main__":
    test()
