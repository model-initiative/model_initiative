function detector_interface_matlab(detector_name_and_args,detector_language)
%The role of this function is to launch a seperate thread in which the detector chosen by the user will run
%Users don't have to call that function themsevessince it will be automatically called by the model_server function 


global model_framework
cd ([model_framework.mainpath,filesep,'fileexchange']);

% Writing the detector name and arguments in a file for the new thread to find and read
fdetector= fopen('det_params.txt','w');
fprintf(fdetector,'%s',detector_name_and_args);
fclose(fdetector);
cd ([model_framework.mainpath,filesep,'model_server']);

% Launching the thread in which the chosen detector will be run in the language chosen by the user. 
if detector_language=='matlab'
   if and(isunix,~ismac)
       cmd='matlab -nodisplay -nosplash -nodesktop -r "detector_server_matlab()"'
   elseif ismac
       cmd='/usr/local/bin/matlab -nodisplay -nosplash -nodesktop -r "detector_server_matlab()"'
   else
       cmd='matlab -nodisplay -nosplash -nodesktop -r detector_server_matlab()'
   end
elseif detector_language=='octave'
    if  and(isunix,~ismac)
        cmd=['export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu;octave --no-gui --eval ''pkg load control io signal statistics nan;detector_server_matlab()''']
    elseif ismac
       cmd='/usr/local/bin/octave-cli --no-gui  --eval "detector_server_matlab()"'
    else
        cmd=['octave-gui.exe --no-gui --eval "pkg load control io signal statistics nan;detector_server_matlab()"']
    end
    
elseif detector_language=='python'
      if and(isunix,~ismac)
        cmd=['export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu;python -c "from detector_server_python import * ;detector_server_python()"']
      elseif ismac
        cmd=['python -c "from detector_server_python import * ;detector_server_python()"']
      else
        cmd=['python -c "from detector_server_python import * ;detector_server_python()"']

      end
end      
s=system(cmd)
end



