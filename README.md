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
script to add the necessary paths to the matlab path.
From there you can run for instance the following:

'afc_main('KleinHennig2011','ModelInitiative','identifierXY','4');'

or

'afc main('van de Par Kohlrausch 1999','ModelInitiative','breebaart1','500');'

The available afc experiments are located in the /experiments/afc folder.




