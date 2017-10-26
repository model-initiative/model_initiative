function model_server(no_intervals, model_name_and_args,detector_name_and_args,model_language,detector_language)
% This main function serves the experiment output to the pathway model
% and decision stages and provides a response.
% Operation is via file exchange.
%
% v0.1 3/8/2016 by Torsten Marquardt. UCL Ear Institute,
% v0.11 04/2017  by Mathias Dietz. Western University, NCA.
% 
% Last argument is optional, the user should only use it when 
% the detector and the pathway model are written in different languages
% 
global model_framework

cd(model_framework.iopath);
if model_language=='python'
        python_model_server_call(no_intervals,model_name_and_args,detector_name_and_args,model_language,detector_language)
else
    if exist('finished.txt', 'file')
        delete('finished.txt')
    end
    if exist('feedback.csv', 'file')
        delete('feedback.csv')
    end

    n=0; % trial #
    while 1
        n=n+1;
        % grab feedback from last trial
        if exist('feedback.csv','file')
            %feedback = csvread('feedback.csv');
            delete('feedback.csv')
        else
            feedback = [];
        end
        if exist('a_priori.csv','file')
            a_priori = csvread('a_priori.csv');
        else
            a_priori = [];
        end
        % wait until stimulus intervals are genereted
        go = 0;
        while ~go
            go = exist(['interval_'  num2str(no_intervals) '.wav'],'file');
            pause(.02)
            if exist('finished.txt','file')
                disp(['total number of trials: ' num2str(n-1)])
                delete('finished.txt')
                cd(model_framework.mainpath);
                return
            end
        end

        % model process from reading file to making decision
        [wave,fs] = audioread('interval_1.wav');
        delete('interval_1.wav');
        disp(['Model started! No. ' num2str(n)])
        pathway_out{1} = eval(model_name_and_args);
        for q=2:no_intervals
            [wave2,fs2] = audioread(['interval_'  num2str(q) '.wav']);
            delete(['interval_'  num2str(q) '.wav']);
            if fs ~= fs2
                error('All stimulus intervals must have same sampling rate!')
            end
            if size(wave) ~= size(wave2)
                error('All stimulus intervals must have the same length and number of channels')
            else
                wave = wave2;    
            end
            pathway_out{q} = eval(model_name_and_args);
        end
        if  ~exist('detector_language','var')            
            response=eval(detector_name_and_args);
            disp(['response: ' num2str(response)])
            csvwrite('detector_out.csv',response)
        else
            save pathway_out.mat pathway_out -v6
            detector_interface_matlab(detector_name_and_args,detector_language)
            cd(model_framework.iopath); 
        end
    end
end
