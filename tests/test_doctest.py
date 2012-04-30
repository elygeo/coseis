import doctest
import cst

def test_doctest():
    doctest.testmod(cst.coord)
    doctest.testmod(cst.sord)
    doctest.testmod(cst.util)

if __name__ == "__main__":
    test_doctest()

