Point-source earthquake simulation in the SCEC Community Velocity Model
-----------------------------------------------------------------------

Steps:

1.  Edit ``data.py`` to set the event ID number. Run the script to download moment
    tensor, broadband seismograms, and station coordinates::

        python data.py

2.  Run ``map.py`` to generate the stations map
    ::

        python map.py

3.  Edit ``material.py`` to set the mesh resolution and CVM version.  Run the
    script to generate the mesh and extract the velocity model.  For low resolution
    test, run interactively::

        python material.py -i

    For full resolution, HPC run, submit the job to batch scheduler
    ::

        python material.py -q

4.  Run low resolution simulation test
    ::

        python sim.py -i

    or submit full resolution job to the batch scheduler
    ::

        python sim.py -q

5.  Generate metadata for viewing in WebSims
    ::

        python websims.py

