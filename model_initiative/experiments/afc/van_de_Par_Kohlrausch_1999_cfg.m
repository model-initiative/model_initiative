% to run this experiment use
% afc_main('van_de_Par_Kohlrausch_1999','string1','string2',target_frequency)
% 
% string1: use 'ModelInitiative' for artificial observer. Otherwise subject ID
% string2: use your own identifier here. Suggestion: specify which model and detector version you are going to use this time e.g. 'Breebaart_v1'

global model_framework
global set

def.expname = 'van_de_Par_Kohlrausch_1999';		% name of experiment   

% general measurement procedure
def.measurementProcedure = 'transformedUpDown';	% measurement procedure
def.intervalnum = 3;                    % number of intervals
def.rule = [1 2];                       % [up down]-rule: [1 2] = 1-up 2-down
def.varstep = [8 4 2 1];                  % [starting stepsize ... minimum stepsize] of the tracking variable
def.steprule = +1;                      % stepsize is changed after each upper (-1) or lower (1) reversal
def.reversalnum = 8;                    % number of reversals in measurement phase
def.repeatnum = 4;                      % number of repeatitions of the experiment
def.varstepApply = 1;					% 1 = additive (the way it was), 2 = multiplicative (multiply def.startvar with current stepsize on wrong response or divide by current stepsize on correct response, depending on steprule)

% tracking variable (dependent variable)
def.startvar = 0; %not specified in paper  % starting value of the tracking variable 
def.expvarunit = 'dB';                  % unit of the tracking variable
def.expvardescription= 'signal-to-noise level';      % description of the tracking variable

% limits for tracking variable
def.minvar = -50;                   % minimum value of the tracking variable
def.maxvar = +20;                 % maximum value of the tracking variable
def.terminate = 1;                % terminate execution on min/maxvar hit: 0 = warning, 1 = terminate
def.endstop = 2;                  % Allows x nominal levels higher/lower than the limits before terminating (if def.terminate = 1) 

if isempty(varargin)
    set.target_frequency = 500; % default: No Spi
else
    set.target_frequency = str2double(varargin{end});			% extract condition
end

% experimental variable #2 (independent variable)
def.exppar1unit = 'Hz';       		    % unit of experimental parameter
def.exppar1description = 'masker BW';   % description of the experimental parameter
def.exppar1 = [5 10 25 50 100 250 500 1000 2000 4000 8000];
def.exppar1(def.exppar1 > 2*set.target_frequency) = [];

% experimental variable #2 (independent variable)
def.exppar2unit = 'phi';       		          % unit of experimental parameter
def.exppar2description = 'interaural phase condition';  % description of the experimental parameter
def.exppar2 = 2;disp('only doing NoSpi otherwise change line 48 of van_de_Par_Kohlrausch_1999_cfg to [1 2 3]');

def.parrand = 0;  %not specified in paper    % toggles random presentation of the elements in "exppar" on (1), off(0).

% interface, feedback and messages 
def.mouse = 1;                      % enables mouse/touch screen control (1), or disables (0) 
def.markinterval = 1;               % toggles visual interval marking on (1), off(0)
def.feedback = 1;                   % visual feedback after response: 0 = no feedback, 1 = correct/false/measurement phase
def.messages = 'messages';          % message configuration file, if 'autoSelect' AFC automatically selects depending on expname and language setting, fallback is 'default'. If 'default' or any arbitrary string, the respectively named _msg file is used.
def.language = 'EN';                % EN = english, DE = german, FR = french, DA = danish

% save paths and save function
def.result_path = model_framework.datapath;		% where to save results
def.control_path = model_framework.datapath;   	% where to save control files
def.savefcn = 'default'; % paper uses median currently not used here			% function which writes results to disk

% samplerate and sound output
def.samplerate = 32000;				% sampling rate in Hz
def.intervallen = 32000*0.4;        % length of each signal-presentation interval in samples (might be overloaded in 'expname_set')
def.pauselen = 32000*.2;			% length of pauses between signal-presentation intervals in samples (might be overloaded in 'expname_set')
def.presiglen = 100;				% length of signal leading the first presentation interval in samples (might be overloaded in 'expname_set')
def.postsiglen = 100;				% length of signal following the last presentation interval in samples (might be overloaded in 'expname_set')
def.bits = 16;                      % output bit depth: 8 or 16 see def.externSoundCommand for 32 bits

% computing
def.allowpredict = 0;				% if 1 generate new stimui during sound output if def.markinterval disabled

% calibration
def.calScript = '';		% if 'autoSelect' load 'xxx_calibration' file where xxx is the last string passed to afc_main, otherwise load default_calibration;
                                    % if 'xyz' load 'xyz_calibration' if existing, otherwise load the default  
% debugging/show
def.showEnable = 1;                 % enables show features if 1 (defaults to 0)
def.showbothears = 0;               % if set to 1 shows the signal for both ears (otherwise only one ear signal)
def.showtrial = 0;                  % shows trial signal after each presentation (0 == off, 1 == on)
def.showspec = 0;                   % shows spectra from target and references after each trial (0 == off, 1 == on)
def.showstimuli = 0;                % shows stimuli
def.showspec_frange = [0 10000];	% range of frequencies to show in Hz
def.showspec_dbrange = [-20 -100];	% dynamic range to show for spectra in dB re 1
def.showrun = 1;                    % shows time development of the tracking variable 

% eof