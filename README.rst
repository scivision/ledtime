===============
led-timemeasure
===============

We use known LED sequences to test camera timing. The user will have two or more
cameras they wish to test the time synchronization of the exposures via an LED
flashing sequence.

Camera requirements
--------------------
Each camera should have a hardware external trigger input that is driven by a
stable (long-term and short-term) clock source controlling an ASIC or FPGA outputting
a pulse train with period matching the desired frame rate.

Additionally, the cameras should have a "fire" output which is a hardware output
telling the instant when the exposure started. In our system we pack this into a byte
and record this as a ``.fire`` file

Testing Programs
-----------------
1. ``RunLEDplot``: click on LED coordinates, which are saved to _Coord.h5 files. Plots made to verify clicks (should see square waves with distinct frequencies matching LEDs
2. ``RunledMatcher``: given video input, makes plot of simulated LEDs against 1-D pixel vs time brightness. Sim should match video! does NOT use .fire measurements

Utilities
---------
``Runsimleds``: test run of LED simulated square wave (that are used in RunledMatcher)
``RunFireReader``: read and plot .fire file recorded from real camera **outputs time of exposures corrected for dropped frames**

TODO
----
* Upgrade RunledMatcher to use the computed time from RunFireRader functions -- this automatically
implements correction from RunFireReader