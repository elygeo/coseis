def test_doctest():
    """
    Test with doctest.
    """
    import doctest
    import cst
    doctest.testmod(cst.coord)
    doctest.testmod(cst.sord)
    doctest.testmod(cst.util)

if __name__ == "__main__":
    test_doctest()

