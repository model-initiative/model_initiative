function pointerILD = Dietz_et_al_2015(ExperimentNo)

disp('This simulation tests more conditions than tested experimentally.')
disp('Data with non-zero ILD was only tested ex. for ITD=0 and ITD=1 ms.')

addpath([fileparts(which(mfilename)), filesep, 'tools', filesep, 'custom_envelope_generation'])

correspondingKH2011Experiment = [4 8 5];

global model_framework

fs=48000;
fmod = 50;

ITD = [0 200 600 1000 1400 2000]; % in microsec
ILD = -5:5:5; % in dB

if ExperimentNo == 1
    exppar1 = [0 8750 17500];
    csvwrite( [model_framework.iopath 'a_priori.csv'],fmod)
    disp(['writing stimulus paramter to disk for model: f_mod = ' num2str(fmod) ' Hz']);
elseif ExperimentNo == 2
    exppar1 = [1 3 2];
elseif ExperimentNo == 3
    csvwrite( [model_framework.iopath 'a_priori.csv'],fmod)
    disp(['writing stimulus paramter to disk for model: f_mod = ' num2str(fmod) ' Hz']);
    exppar1 = [45 65];
end

pointerILD=zeros(length(exppar1),length(ITD),length(ILD));
NoOfConditionsStr = num2str(numel(pointerILD));
counter = 0;

% shape loop begins here
for shape_idx = 1:length(exppar1) 
    % special treat for models that need to know fmod
    if ExperimentNo == 2
        if exppar1(shape_idx) < 3
            fmod = 100/3;
        else
            fmod = 50;
        end
        csvwrite( [model_framework.iopath 'a_priori.csv'],fmod)
        disp(['writing stimulus paramter to disk for model: f_mod = ' num2str(fmod) ' Hz']);
    end
        
    %ITD LOOP BEGINS HERE
    for ITDidx = 1:length(ITD)
       % ILD loop begins here
       for ILDidx=1:length(ILD);

           stim = jndstimulus2017(correspondingKH2011Experiment(ExperimentNo),...
               exppar1(shape_idx),ITD(ITDidx),1,ILD(ILDidx));

           % write to disk model_framework path defined in here
            audiowrite([model_framework.iopath 'interval_1.wav'],stim,fs);

            counter = counter + 1;
            disp(['condition ' num2str(counter) ' of ' NoOfConditionsStr]);

            % wait for model to write "choice.dat"
            go = 0;
            while ~go
                go = exist([model_framework.iopath 'detector_out.csv'], 'file');
                pause(.02)
            end

            % grab the response
            pointerILD(shape_idx,ITDidx,ILDidx) = csvread([model_framework.iopath 'detector_out.csv']);
            delete( [model_framework.iopath 'detector_out.csv'] )

       end; %OF ILD loop   
    end; %OF ITD loop
 end; %OF shape loop   

csvwrite([model_framework.iopath, 'finished.txt'],'') 
save([model_framework.datapath, 'Dietz_et_al_2015_pointerILDs_Experiment_' num2str(ExperimentNo)], 'pointerILD', 'ITD', 'ILD','exppar1')
