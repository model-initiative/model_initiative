function correct_rate = N0Spi_example

global model_framework
correct = zeros(20,1);

fs=48000;
SNR = -40;

tone(:,1)=sin(2*pi*(0:fs/2-1)'*500/fs)/10*sqrt(2)*10^(SNR/20);
tone(:,2)=-tone(:,1);

disp('showing (target interval | response interval)')

for trial = 1:20
    target_interval = ceil(3*rand); % 1,2, or 3
    for n=1:3
        noise = repmat(randn(fs/2,1)/10,1,2); % RMS = 0.1 to avoid clipping
        if n==target_interval
            stim = noise + tone;
        else
            stim = noise;
        end
        audiowrite([model_framework.iopath 'interval_'  num2str(n) '.wav'],stim,fs);
    end
    % wait for model to write "choice.dat"
    go = 0;
    while ~go
        go = exist([model_framework.iopath 'detector_out.csv'], 'file');
        pause(.02)
    end
    % grab the response
    response = csvread([model_framework.iopath 'detector_out.csv']);
    correct(trial) = response==target_interval;
    disp([num2str(target_interval) '|' num2str(response) '; condition: ' num2str(trial) ' of 20']);
    delete( [model_framework.iopath 'detector_out.csv'] )
end
correct_rate = mean(correct);
disp(['correct rate: ' num2str(correct_rate*100) '%']);
csvwrite([model_framework.iopath, 'finished.txt'],'') 
save([model_framework.datapath, 'NoSpi_example'], 'correct','correct_rate')
