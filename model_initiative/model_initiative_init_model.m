global model_framework

% define folder or drive over which model and operating environment interface
model_framework.iopath = [fileparts(which(mfilename)),filesep, 'fileexchange' , filesep];
model_framework.mainpath = fileparts(which(mfilename));
    
addpath([fileparts(which(mfilename)), filesep, 'model_server'])
addpath([fileparts(which(mfilename)), filesep, 'pathway_models'])
addpath(genpath([fileparts(which(mfilename)), filesep, 'pathway_models']))
addpath([fileparts(which(mfilename)), filesep, 'decision_stages'])

% do not include data or plot_routines folder here because that is not the
% business of the model but rather of the experiment

