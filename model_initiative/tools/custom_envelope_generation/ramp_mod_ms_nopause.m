% ramp_mod_ms
%
% len = signal length in samples
% fs = sampling frequency
% fc = carrier frequency
% parameters = 2x5 vector:
%       pause_f_l attack_l sustain_l release_l pause_b_l
%       pause_f_r attack_r sustain_r release_r pause_b_r
% dp = phase shift of right channel in microseconds
% env_min = minimum value of envelope
% env_max = maximum value of envelope
% flank_type = type of flank (only 'sin2' right now)
% is_reference = boolean. if true, dp is added in both channels to the
%                sustain time
% dp_location = 1 to delay attack
%               2 to delay sustain
function out = ramp_mod_ms_nopause(len,fs,fc,parameters,dp,env_min,env_max,flank_type,is_reference,dp_location)



if(is_reference==1)
    dp=0;
end

signal=sin_tone(len,fs,fc,0);

if size(parameters)~=[2,5]
    error('Parameter vector has wrong dimensions. Must be 2x5.');
end

if (parameters(1,1)<dp)
    error('Frontal pause must be > delay!')
end


% return length of envelope in samples

% convert paramters to samples
parameters=round((parameters/1e6)*fs);
dp=round((dp/1e6)*fs);


% switch dp_location
%     case 1
%         pause_f_len_l=parameters(1,1)+dp_r;
%         attack_len_l=parameters(1,2);
%         sustain_len_l=parameters(1,3)+dp; % add phase difference here
%         release_len_l=parameters(1,4);
%         pause_b_len_l=parameters(1,5);
%
%         pause_f_len_r=parameters(2,1)+dp+dp_r; % add phase difference here
%         attack_len_r=parameters(2,2);
%         sustain_len_r=parameters(2,3);
%         release_len_r=parameters(2,4);
%         pause_b_len_r=parameters(2,5);
%     case 2
%         pause_f_len_l=parameters(1,1);
%         attack_len_l=parameters(1,2);
%         sustain_len_l=parameters(1,3);
%         release_len_l=parameters(1,4);
%         pause_b_len_l=parameters(1,5)+dp+dp_r; % add phase difference here
%
%         pause_f_len_r=parameters(2,1);
%         attack_len_r=parameters(2,2);
%         sustain_len_r=parameters(2,3)+dp; % add phase difference here
%         release_len_r=parameters(2,4);
%         pause_b_len_r=parameters(2,5)+dp_r;
%     otherwise
%         error('I don´t know what to do with this dp_location');
% end

pause_f_len_l=parameters(1,1);
attack_len_l=parameters(1,2);
sustain_len_l=parameters(1,3);
release_len_l=parameters(1,4);
pause_b_len_l=parameters(1,5);

pause_f_len_r=parameters(2,1);
attack_len_r=parameters(2,2);
sustain_len_r=parameters(2,3)-(dp); % shorten the hold time for right envelope by phase difference
release_len_r=parameters(2,4);
pause_b_len_r=parameters(2,5);

% generate envelope window
if(flank_type=='sin2')
    % phase difference pause for right channel
    dp_pause=ones(1,dp)*env_min;
    % left channel    
    pause_f_ramp_l=ones(1,pause_f_len_l)*env_min;
    attack_ramp_l=env_min+(env_max-env_min)*sin(linspace(0,pi/2,attack_len_l)).^2;
    sustain_ramp_l=ones(1,sustain_len_l)*env_max;
    release_ramp_l=env_min+(env_max-env_min)*sin(linspace(pi/2,0,release_len_l)).^2;
    pause_b_ramp_l=ones(1,pause_b_len_l)*env_min;

    % right channel
    pause_f_ramp_r=ones(1,pause_f_len_r)*env_min;
    attack_ramp_r=env_min+(env_max-env_min)*sin(linspace(0,pi/2,attack_len_r)).^2;
    sustain_ramp_r=ones(1,sustain_len_r)*env_max;
    release_ramp_r=env_min+(env_max-env_min)*sin(linspace(pi/2,0,release_len_r)).^2;
    pause_b_ramp_r=ones(1,pause_b_len_r)*env_min;
    
    % front pause is added to the back of the signal to have all
    % stimuli start with the signal right away

    if(dp_location==1)
        ramp_l=[attack_ramp_l sustain_ramp_l release_ramp_l pause_b_ramp_l pause_f_ramp_l];
        ramp_r=[dp_pause attack_ramp_r sustain_ramp_r release_ramp_r pause_b_ramp_r pause_f_ramp_r];
    else
        ramp_l=[ pause_f_ramp_l attack_ramp_l sustain_ramp_l release_ramp_l pause_b_ramp_l];
        ramp_r=[pause_f_ramp_r dp_pause attack_ramp_r sustain_ramp_r release_ramp_r pause_b_ramp_r ];
    end
  
end

% flip the envelope if sustain is to be delayed
if(dp_location==2)
    ramp_r=flipdim(ramp_r,2);
    ramp_l=flipdim(ramp_l,2);
    % swap channels
    ramp_r_temp=ramp_r;
    ramp_r=ramp_l;
    ramp_l=ramp_r_temp;

end

ramp_len_l=length(ramp_l);
ramp_len_r=length(ramp_r);

% save single envelope cycle as mat file
%global counter;
%if(is_reference==0)
%filename_ramp=sprintf('env_single_cond%0.2d_tref1.mat',counter)
%envelope=[ramp_l' ramp_r'];
%save(filename_ramp,'envelope')
%end



% plot one period of the envelope
%global counter;
%figure;plot(ramp_l,'b');title(counter);hold on;plot(ramp_r,'r');hold off;

% save binaural ramp data for plotting conditions
%  global counter;
%  if(is_reference==0)
%      outmatrix=[(((1:length(ramp_l))/fs)*1000)' ramp_l' ramp_r'];
%       filename=sprintf('envelope_%d.dat',counter);
%       save(filename,'outmatrix','-ascii','-tabs');
% end
%
%  global counter;
%  if(is_reference==0)
%      plotramp_l=repmat(ramp_l,5,1);
%      plotramp_r=repmat(ramp_r,5,1);
%      plotvector=circshift([plotramp_l' circshift(plotramp_r',dp)],-dp);
%      outmatrix=[(((1:length(plotramp_l))/48000)*1000)' plotvector(:,1) plotvector(:,2)];
%      filename=sprintf('envelope_%d.dat',counter);
%      save(filename,'outmatrix','-ascii','-tabs');
%  end

% global counter;
% if(is_reference==0)
%      plotvector=[ramp_l' ramp_r'];
%      outmatrix=[(((1:(length(ramp_l)*10))/48000)*1000)' repmat(plotvector(:,1),10,1) repmat(plotvector(:,2),10,1)];
%      filename=sprintf('envelope_%d.dat',counter);
%      save(filename,'outmatrix','-ascii','-tabs');
% end
% get number of windows that fit into signal length
envelope_nr_l=ceil(length(signal)/ramp_len_l);
envelope_nr_r=ceil(length(signal)/ramp_len_r);

% generate ramp signal with the signal length (i.e. copy&paste)
ramp_l=repmat(ramp_l,1,envelope_nr_l);
%ramp_l(length(signal)+1:end)=[];
ramp_l=ramp_l';

%rms_l=rms(ramp_l)
%rms_r=rms(ramp_r)
%faktordb=20*log10(rms_r/rms_l)

ramp_r=repmat(ramp_r,1,envelope_nr_r);
%ramp_r(length(signal)+1:end)=[];
ramp_r=ramp_r';

% % save envelope
% global counter;
% if(is_reference==0)
% filename_ramp=sprintf('env_cond%0.2d_tref1.mat',counter)
% envelope=[ramp_l ramp_r];
% save(filename_ramp,'envelope')
% end

% apply random diotic phase shift
phase_shift=ceil(rand*ramp_len_l);
ramp_l=circshift(ramp_l,phase_shift);
ramp_r=circshift(ramp_r,phase_shift);

% trim envelope if it too long
if(size(ramp_l,1)>size(signal,2))
    ramp_l(1:size(ramp_l,1)-size(signal,2))=[];
end
if(size(ramp_r,1)>size(signal,2))
    ramp_r(1:size(ramp_r,1)-size(signal,2))=[];
end

% plot the envelope
%global counter;
%figure;plot(ramp_l,'b');title(counter);hold on;plot(ramp_r,'r');hold off;

signal=[signal' signal'];
ramp =[ramp_l ramp_r];
out = signal .* ramp;
out = normalize(out,env_max);

% plot the whole signal
%figure;plot(out);

