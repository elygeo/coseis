Test Suite
----------

To check syntax with Pyflakes do:

    ./pyflakes.sh

To run the test suite using nose_ do:
::

    nosetests -v

To also include tests that require a GUI and plotting to the screen do:
::

    nosetests -v --exe

To submit nosetests to a batch queue do:
::

    ./nosetests.py

To run individual tests:
::

    python test_name.py

.. _nose: http://readthedocs.org/docs/nose/

