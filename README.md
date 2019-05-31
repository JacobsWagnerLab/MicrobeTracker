__MicrobeTracker is no longer supported. Please visit [oufti.org](http://oufti.org/) for an upgraded software package for image analysis.__

# MicrobeTracker

![](https://drive.google.com/uc?id=1-g_X_vhaChDfCtOAoXklbPDADi7SI76g)

*Caulobacter crescentus* cells at 0.06 µm/px resolution outlined by MicrobeTracker

## Introduction
Many aspects of spatial and temporal organization organization of bacterial and other microbial cells are crucial for their investigation. These aspects, however, are frequently very similar between different strains and conditions can be easily obscured by cell-to-cell variability. In order to study bacterial cells in detail, traditional optical imaging methods have to be supplemented with automatic image analysis, which would allow for high precision analysis of large numbers of cells.

MicrobeTracker Suite is a set of tools designed to efficiently measure the properties of such spatio-temporal organization. This software is capable to precisely outline rod-shaped or other similarly-shaped bacterial cells even in crowded phase contrast images and to track them in time lapses over multiple generations. It also integrates fluorescence and phase contrast data in order to quantify fluorescently labeled objects and to localize them inside cells at subpixel resolution.

## The suite
MicrobeTracker Suite is based on MATLAB and consists of:

* MicrobeTracker program - outlines and tracks the cells

* SpotFinderZ, SpotFinderM - tools for spot detection inside cells

* Tools - supporting functions for data visualization and primary data analysis.

The data is saved in comprehensive MATLAB format and can be processed by the user directly if a more complex analysis is required than what can be provided by the tools. The Suite requires MATLAB with Image Processing and Spline toolboxes.

## Acknowledgements
Funding was provided by NSF, NIH, and HHMI.

## Licensing and distribution
MicrobeTracker is free software redistributed under the GNU General Public License. Anybody is free to use it, under the condition that the following citation is provided in publication.

Sliusarenko O, Heinritz J, Emonet T, and Jacobs-Wagner C, "High- throughput, subpixel-precision analysis of bacterial morphogenesis and intracellular spatio-temporal dynamics", Mol. Micro, 2011; 80(3): 612:627.


*Note*: While we are not able to provide individual technical support, the user can find detailed description of the interface and tools (with examples) in this online MicrobeTracker Manual.
