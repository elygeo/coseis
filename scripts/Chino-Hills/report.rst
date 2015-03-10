.. role:: raw-math(raw)
    :format: latex html
.. default-role:: raw-math

2008 `$M_w$` 5.4 Chino Hills ground motion simulations
======================================================

Ground motions from the 2008 `$M_w$` 5.4 Chino Hills, CA earthquake are
compared to simulations using the CVM-S 4.0 and CVM-H 6.3 + GTL. The source is
a point double couple and CLVD moment tensor obtained from the Southern
California Seismic Network, with a time function `$m(t) = t/T^2 e^{-t/T}$`
where `$T = 0.25$` sec.  The minimum S-wave velocity is truncated at 500 m/s,
obscuring some details of the GTL model. The velocity models are sampled at 50
meter resolution, requiring 5.5 billion mesh points for the simulation domain
(Fig. 12).  Simulations were computed with the Support Operator Rupture
Dynamics code (SORD, Ely, et al., 2008), using 15,360 processes on the NICS
Kraken super-computer, requiring eight hours run time per simulation. These
preliminary results show general agreement in amplitude and character among the
observed and synthetic data (Figs. 13-15). Additional analysis and simulations
are needed to adequately quantify effects of the new GTL model.

.. figure:: map.pdf

    Station map with basins delineated by dashed contour of `$V_S$` =
    2.5 km/s, at 1 km depth, for CVM-S (red) and CVM-H (blue).

.. figure:: map-cvms.pdf

    Station map with CVM-S surface `$V_S$`.

.. figure:: map-cvmh.pdf

    Station map with CVM-H surface `$V_S$`.

.. figure:: map-cvmg.pdf

    Station map with surface `$V_S$` from `$V_{S30}$` derived GTL.

.. |caption| replace:: Recorded (black) and simulated 0.1 to 1.0 Hz ground
    velocity (cm/s) for CVM-S (red), CVM-H (blue), and CVM-H + GTL (green), at
    stations

.. figure:: waveform-1-0.pdf

    |caption| east of the epicenter.

.. figure:: waveform-1-1.pdf

    |caption| north-west of the epicenter.

.. figure:: waveform-1-2.pdf

    |caption| west of the epicenter.

.. figure:: waveform-1-3.pdf

    |caption| south of the epicenter.

