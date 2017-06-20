% revision 1.00.1 beta, 07/01/04

function ModelInitiative_close

global model_framework

% this is called when afc closes.
% send the finished command to the model via file

% FIXME no path definition
csvwrite([model_framework.iopath, 'finished.txt'],'')