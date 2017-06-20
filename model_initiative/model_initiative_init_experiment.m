global model_framework

% define model initative main folder
model_framework.mainpath = fileparts(which(mfilename));

% define folder or drive over which model and operating environment interface
model_framework.iopath = [fileparts(which(mfilename)),filesep, 'fileexchange' , filesep];

% define folder where the experiment should save the data. If possible,
% make this variable or folder known to the experiment software
model_framework.datapath = [fileparts(which(mfilename)),filesep, 'data' , filesep];

addpath([fileparts(which(mfilename)), filesep, 'fileexchange'])
addpath([fileparts(which(mfilename)), filesep, 'experiments'])
addpath([fileparts(which(mfilename)), filesep, 'plot_routines'])
addpath([fileparts(which(mfilename)), filesep, 'data'])
addpath([fileparts(which(mfilename)), filesep, 'tools',filesep,'custom_envelope_generation'])
