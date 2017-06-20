% revision 1.00.1 beta, 07/01/04

function ModelInitiative_init

% this file is used to initialize model parameters for AFC

% global def
% global work
global model_framework

% tell the model that we are not finished, by removing the finished file
% (if existing)
if exist([model_framework.iopath 'finished.txt'], 'file')
    delete([model_framework.iopath 'finished.txt'])
end
if exist([model_framework.iopath 'detector_out.csv'], 'file')
    delete([model_framework.iopath 'detector_out.csv'])
end

%eof
