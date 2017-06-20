function detector_server_matlab()
%This function is called by the detector_interface_matlab/python functions
%There is no need for the user to call that function him/herself
%it reads the detector parameters from a file and launch the corresponding matlab/octave detector.

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if ~isOctave
	myclean = onCleanup(@() myCleanupFun());
end
addpath('..')
model_initiative_init_model
cd(['..',filesep,'fileexchange']) 
f = fopen('det_params.txt','r');
detector_details=textscan(f,  '%s');
detector_name_and_args=detector_details{:}{1}
fclose(f);
delete('det_params.txt');



% Loads the pathway_out variable and returns the decision made by the detector
if exist('pathway_out.mat','file')
    load('pathway_out.mat');
    response=eval(detector_name_and_args)
    csvwrite('detector_out.csv',response);
    delete('pathway_out.mat');
end   

exit()
end

% This myCleanupFun function is here to guarantee a safe exit from the spawned thread
function myCleanupFun()
quit force
exit()
end

