function model_interface_matlab()
    %This function is called from the matlab_model_server_call when the model_language chosen by the user is either matlab or octave (as 1 argument of the model_server matlab function) 
    %This function then calls the matlab model_server function
    addpath('..')
    model_initiative_init_model
    
    %Reads the information related to the pathway model
    path_to_file=['..',filesep,'fileexchange',filesep,'params.txt']
    f = fopen(path_to_file,'r');
    params=textscan(f, '%f %s %s %s %s' );
    fclose(f)
    no_intervals=params{1}
    model_name_and_args=params{2}{:}
    detector_name_and_args=params{3}{:}
    model_language=params{4}{:}
    detector_language=params{5}{:}
    delete(path_to_file); 

    %calls the matlab/octave model_server function with the right arguments
    model_server(no_intervals,model_name_and_args,detector_name_and_args,model_language,detector_language)
