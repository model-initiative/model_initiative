function KleinHennig2011_set

global def
global set
global model_framework

addpath([model_framework.mainpath, filesep, 'tools', filesep, 'custom_envelope_generation'])

% make condition dependend entries in structure set


% define signals in structure set

set.hannlen = round(0.05*def.samplerate);
set.window = hannfl(def.intervallen,set.hannlen,set.hannlen);

% eof