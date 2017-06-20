% example_set - setup function of experiment 'example' -
%
% This function is called by afc_main when starting
% the experiment 'example'. It defines elements
% of the structure 'set'. The elements of 'set' are used 
% by the function 'example_user.m'.
% 
% If an experiments can be started with different experimental 
% conditions, e.g, presentation at different sound preasure levels,
% one might switch between different condition dependent elements 
% of structure 'set' here.
%
% For most experiments it is also suitable to pregenerate some 
% stimuli here.
% 
% To design an own experiment, e.g., 'myexperiment',
% make changes in this file and save it as 'myexperiment_set.m'.
% Ensure that this function does exist, even if absolutely nothing 
% is done here.
%
% See also help example_cfg, example_user, afc_main

function van_de_Par_Kohlrausch_1999_set

global def
global work
global set


% define signals in structure set

set.hannlen = round(0.05*def.samplerate);
set.targetlen = round(0.3*def.samplerate); %special to this study: length of target tone in samples
set.window = hannfl(def.intervallen,set.hannlen,set.hannlen);
set.tone_window = [zeros(set.hannlen,1); hannfl(set.targetlen,set.hannlen,set.hannlen); zeros(set.hannlen,1)];

if work.exppar2 == 1
    set.N_S_phase=[1 1];
elseif work.exppar2 == 2
    set.N_S_phase=[1 -1];
elseif work.exppar2 == 3
    set.N_S_phase=[-1 1];
elseif work.exppar2 == 4
    % just an example that more can be added here. e.g. NoSm:
    set.N_S_phase=[1 0];
end
% eof