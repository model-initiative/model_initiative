% to run this experiment use
% afc_main('KleinHennig2011','string1','string2','4')
% 
% string1: use 'ModelInitiative' for artificial observer. Otherwise subject ID
% string2: use your own identifier here. Suggestion: specify which model and detector version you are going to use this time e.g. 'NCC_noise18_argmin_v1'
% string2: name of experiment according to Klein Hennig et al. 2011. Note: experiments 6+7 need to be specified as 6.1, or 6.2, or 7.1, or 7.2
%
% In contrast to the original this does not include lowpass masking noise

global model_framework


def.expname = 'KleinHennig2011';		% name of experiment   

% general measurement procedure
def.measurementProcedure = 'transformedUpDown';	% measurement procedure
def.intervalnum = 2;                    % number of intervals
def.rule = [1 3];                       % [up down]-rule: [1 2] = 1-up 2-down
def.varstep = [2 1.4 1.1];                  % [starting stepsize ... minimum stepsize] of the tracking variable
def.steprule = -1;                      % stepsize is changed after each upper (-1) or lower (1) reversal
def.reversalnum = 6;                    % number of reversals in measurement phase
def.repeatnum = 5;                      % number of repeatitions of the experiment
def.varstepApply = 2;					% 1 = additive (the way it was), 2 = multiplicative (multiply def.startvar with current stepsize on wrong response or divide by current stepsize on correct response, depending on steprule)

% tracking variable (dependent variable)
def.startvar = 2000;                     % starting value of the tracking variable
def.expvarunit = 'us';                  % unit of the tracking variable
def.expvardescription= 'ITD';           % description of the tracking variable

% limits for tracking variable
def.minvar = 0;                   % minimum value of the tracking variable
def.maxvar = 8001;                     % maximum value of the tracking variable
def.terminate = 1;                  % terminate execution on min/maxvar hit: 0 = warning, 1 = terminate
def.endstop = 2;                    % Allows x nominal levels higher/lower than the limits before terminating (if def.terminate = 1) 

% experimental variable #1 (independent variable)
def.exppar1unit = 'us';       		    % unit of experimental parameter
def.exppar1description = 'segm dur';         % description of the experimental parameter

% SE:  _cfg is executed in afc_main, it is not a function
% (for the reason below):
% so it can be used to insert any logic we want in afc_main and it lives in
% afc_main's function space, so we select different exppars depending on
% varargin

% default is condition 1
def.exppar1 = [1250 2500 5000 10000];

% otherwise override depending on condition
if ~isempty(varargin)
    tmpcondition = varargin{end};			% extract condition
    
    if str2double(tmpcondition) == 1
        def.exppar1 = [1250 2500 5000 10000];
    elseif str2double(tmpcondition) == 2
        def.exppar1 = [0 4375 13125];
    elseif str2double(tmpcondition) == 3
        def.exppar1 = [1250 2500 5000 10000];
    elseif str2double(tmpcondition) == 4
        def.exppar1 = [0 4375 8750 13125 17500];
    elseif str2double(tmpcondition) == 5
        def.exppar1 = [36 48 60 66];
        def.exppar1unit = 'dB';       		    % unit of experimental parameter
    elseif str2double(tmpcondition) == 6.1
        def.exppar1 = [10000 5000];
    elseif str2double(tmpcondition) == 6.2
        def.exppar1 = [8750 3750];
    elseif str2double(tmpcondition) == 7.1
        def.exppar1 = [0 0.67];
        def.exppar1unit = 'offset';
    elseif str2double(tmpcondition) == 7.2
        def.exppar1 = [0 0.67];
        def.exppar1unit = 'offset';
    elseif str2double(tmpcondition) == 8
        def.exppar1 = [1 2];
        def.exppar1unit = '1or2';
    elseif str2double(tmpcondition) == 10
        def.exppar1 = [1250 2500 5000 10000];
    end
end

def.parrand = 1;                       % toggles random presentation of the elements in "exppar" on (1), off(0).

% other experimental conditions are addressed by userpar# passed to afc_main call

% interface, feedback and messages 
def.mouse = 1;                      % enables mouse/touch screen control (1), or disables (0) 
def.markinterval = 1;               % toggles visual interval marking on (1), off(0)
def.feedback = 1;                   % visual feedback after response: 0 = no feedback, 1 = correct/false/measurement phase
def.messages = 'messages';          % message configuration file, if 'autoSelect' AFC automatically selects depending on expname and language setting, fallback is 'default'. If 'default' or any arbitrary string, the respectively named _msg file is used.
def.language = 'EN';                % EN = english, DE = german, FR = french, DA = danish

% save paths and save function
def.result_path = model_framework.datapath;		% where to save results
def.control_path = model_framework.datapath;   	% where to save control files
def.savefcn = 'default';			% function which writes results to disk

% samplerate and sound output
def.samplerate = 48000;				% sampling rate in Hz
def.intervallen = 48000*0.5;        % length of each signal-presentation interval in samples (might be overloaded in 'expname_set')
def.pauselen = 48000/3;			% length of pauses between signal-presentation intervals in samples (might be overloaded in 'expname_set')
def.presiglen = 100;				% length of signal leading the first presentation interval in samples (might be overloaded in 'expname_set')
def.postsiglen = 100;				% length of signal following the last presentation interval in samples (might be overloaded in 'expname_set')
def.bits = 16;                      % output bit depth: 8 or 16 see def.externSoundCommand for 32 bits

% computing
def.allowpredict = 0;				% if 1 generate new stimui during sound output if def.markinterval disabled

% calibration
def.calScript = '';		% if 'autoSelect' load 'xxx_calibration' file where xxx is the last string passed to afc_main, otherwise load default_calibration;
                                    % if 'xyz' load 'xyz_calibration' if existing, otherwise load the default  

% debugging/show
def.showEnable = 0;                 % enables show features if 1 (defaults to 0)
def.showbothears = 1;               % if set to 1 shows the signal for both ears (otherwise only one ear signal)
def.showtrial = 0;                  % shows trial signal after each presentation (0 == off, 1 == on)
def.showspec = 1;                   % shows spectra from target and references after each trial (0 == off, 1 == on)
def.showstimuli = 1;                % shows stimuli
def.showspec_frange = [0 10000];	% range of frequencies to show in Hz
def.showspec_dbrange = [-20 -100];	% dynamic range to show for spectra in dB re 1
def.showrun = 0;                    % shows time development of the tracking variable 

% eof
