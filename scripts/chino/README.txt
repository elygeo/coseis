Point-source earthquake simulation in the SCEC Community Velocity Model
-----------------------------------------------------------------------

Steps:

1.  Edit ``data.py`` to set the event ID number, and run it to download
    moment tensor, broadband seismograms, and station coordinates::

        python data.py

2.  Run ``map.py`` to generate the stations map
    ::

        python map.py

3.  Edit ``material.py`` to set the mesh resolution and CVM version, and run it
    to generate the mesh and extract the velocity model.  For low resolution tests,
    run interactively::

        python material.py -i

    For full resolution, HPC run, submit the job to batch scheduler
    ::

        python material.py -q

4.  Edit ``sim.py`` to set the mesh and CVM matching one of the versions
    generated in the previous step, and run it to start the simulation.  For low
    resolution tests, run interactively::

        python sim.py -i

    For full resolution, HPC run, submit the job to batch scheduler
    ::

        python sim.py -q

5.  Generate metadata for viewing in WebSims
    ::

        python websims.py

