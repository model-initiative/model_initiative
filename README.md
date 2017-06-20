# README #

## Introduction

This document aims to describe how to use matlab/octave and/or python to launch auditory pathway
models and detectors in the context of a model comparison framework described in more details below.

![alt](schema.png)
A: Classic experiment in psychoacoustics B: Structure of the model comparison framework, models process
sounds output by the experiment side.The model’s output is then fed to the detector which comes up with a decision/

From the figure below, two sides can be observed: the experiment side and the model/detector side/

## Launching the experiment side
Launching the experiment side requires a couple of matlab toolboxes:
* the AFC toolbox can be found at: http://medi.uni-oldenburg.de/afc/
* the AMT toolbox development version can be found at: https://sourceforge.net/p/amtoolbox/code/ci/master/tree/
* the binaural cross-correlogram toolbox by Michael Akeroyd (not currently available but also not manda-
tory to run most experiments)

### Setting up the AFC toolbox

The easiest way to set it up is probably to uncompress the afc folder after downloading it and copy/paste
it in the main model initiative repo (ie where the other folders model server, fileexchange... are).
When this is done, one small edit has to be made, open the file /afc/base/default cfg and at line 704,
replace the line def.clearGlobals = 1; by def.clearGlobals = [1 1 1 1 1 0];
You can now open a matlab instance, navigate to the main model initiative folder and run the model initiative experiment init
script to add the necessary paths to the matlab path./
From there you can run for instance the following:

```afc_main('KleinHennig2011','ModelInitiative','identifierXY','4');```

or

```afc main('van de Par Kohlrausch 1999','ModelInitiative','breebaart1','500');```

The available afc experiments are located in the /experiments/afc folder./

### Launching the model/detector side

Comparing different computational models can be challenging when models are written in different lan-
guages. The Model Initiative library addresses that issue by allowing the user to launch matlab/octave
models and detectors as well as python models and detectors from a common command line (either matlab
or python command line). The main idea behind that is to create threads in which models and detectors
run. These threads are created and closed automatically when the user runs either the model server matlab
function or the model server python function. Because the way to launch matlab,octave or python threads
varies with the platform that the user runs (Windows, MacOS, Linux), some small editing/configuring might
be necessary to use the library. Those edits will be explained further in the following subsections./

#### Minimum requirements for the matlab user

* Matlab, above R2013a

To run python examples, the python requirements must be satisfied as well

#### Minimum requirements for the octave user

* Octave above 4.0.0
* Packages nan,statistics, signal, control, io /
  * https://octave.sourceforge.io/control/
  * https://octave.sourceforge.io/io/
  * https://octave.sourceforge.io/nan/
  * https://octave.sourceforge.io/signal/
  * https://octave.sourceforge.io/statistics/









