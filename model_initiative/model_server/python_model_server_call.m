function python_model_server_call(no_intervals,model_name_and_args,detector_name_and_args,model_language,detector_language)
%This function is called by the matlab/octave model_server functin when the language chosen by the user is python
%it then launches a new thread to run the model_server_python function

%saving arguments to use when calling the model_server_python function

save('params.mat', 'no_intervals', 'model_name_and_args','detector_name_and_args','model_language','detector_language')
cd(['..',filesep,'model_server'])
%launch the thread in which the model_server_python will be run
if and(isunix, ~ismac)
	cmd=['export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu;python model_interface_python.py']
elseif ismac
	cmd=['python  model_interface_python.py']
else
	cmd=['python  model_interface_python.py']
end
s=system(cmd)
