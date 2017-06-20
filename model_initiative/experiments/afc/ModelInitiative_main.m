% Stephan Ewert
% small edits from Mathias Dietz

function response = ModelInitiative_main

% the model_main function must return the presentation interval selected by the model

global def
global work
global model_framework

% (FIXME) number of channels hardcoded to 2 because binaural

left_target_idx = 2*work.position{work.pvind}(end) - 1;

for n=1:def.intervalnum
    
    left_interval_idx = mod(2*n - left_target_idx, 2*def.intervalnum); % odd number -> never zero problem
    
    % grab the interval from work.signal 
    tmpSig = work.signal(:,left_interval_idx:left_interval_idx+1);
    
    % write to disk model_framework path defined in here
    audiowrite([model_framework.iopath 'interval_' num2str(n) '.wav'], tmpSig, def.samplerate);
end

go = 0;
while ~go
    go = exist([model_framework.iopath 'detector_out.csv'], 'file');
    pause(.02)
end

% grab the response
response = csvread([model_framework.iopath 'detector_out.csv']);
delete( [model_framework.iopath 'detector_out.csv'] )

if response == work.position{work.pvind}(end)		
    r = 'correct';		% correct response
    r_num = 1;
else
    r = 'false';		% false response
    r_num = 0;
end
% tell the model the correct response
csvwrite( [model_framework.iopath 'feedback.csv'],r_num)

% the model also displays some info in the matlab workspace window
% might also go to an extra function "example_display"

if ( def.modelDisplayEnable )	
	if ( work.stepnum{work.pvind}(end) == 1 )
		disp(['starting run ' num2str(work.numrun) ' out of ' num2str(size(work.control,1))]);
	end
	
	disp(['step ' num2str(work.stepnum{work.pvind}(end)) '   ' r]);
end


% eof
