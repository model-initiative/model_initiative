% ramp_mod_ms - true ITD
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
function out = ramp_mod_ms_alt3_nopause(len,fs,fc,parameters,dp,env_min,env_max,flank_type,is_reference)

if(is_reference==1)
    dp=0;
end

signal=sin_tone(len,fs,fc,0);

if size(parameters)~=[2,5]
    error('Parameter vector has wrong dimensions. Must be 2x4.');
end

% return length of envelope in samples

% convert paramters to samples
parameters=round((parameters/1e6)*fs);
dp=round((dp/1e6)*fs);


% switch dp_location
%     case 1
%         pause_f_len_l=parameters(1,1)+dp_r;
%         attack_len_l=parameters(1,2);
%         sustain_len_l=parameters(1,3); % add phase difference here
%         release_len_l=parameters(1,4);
%         pause_b_len_l=parameters(1,5)+dp;
% 
%         pause_f_len_r=parameters(2,1)+dp+dp_r; % add phase difference here
%         attack_len_r=parameters(2,2);
%         sustain_len_r=parameters(2,3);
%         release_len_r=parameters(2,4);
%         pause_b_len_r=parameters(2,5);
%     case 2
%         pause_f_len_l=parameters(1,1);
%         attack_len_l=parameters(1,2);
%         sustain_len_l=parameters(1,3); % add phase difference here
%         release_len_l=parameters(1,4);
%         pause_b_len_l=parameters(1,5)+dp_r;
% 
%         pause_f_len_r=parameters(2,1); % add phase difference here
%         attack_len_r=parameters(2,2);
%         sustain_len_r=parameters(2,3);
%         release_len_r=parameters(2,4);
%         pause_b_len_r=parameters(2,5)+dp_r+dp;
%     otherwise
%         error('I don´t know what to do with this dp_location');
% end

         pause_f_len_l=parameters(1,1);
         attack_len_l=parameters(1,2);
         sustain_len_l=parameters(1,3); % add phase difference here
         release_len_l=parameters(1,4);
         pause_b_len_l=parameters(1,5);
 
         pause_f_len_r=parameters(2,1); % add phase difference here
         attack_len_r=parameters(2,2);
         sustain_len_r=parameters(2,3);
         release_len_r=parameters(2,4);
         pause_b_len_r=parameters(2,5);

% generate envelope window
if(flank_type=='sin2')
    % left channel
    pause_f_ramp_l=ones(1,pause_f_len_l)*env_min;
    attack_ramp_l=env_min+(env_max-env_min)*sin(linspace(0,pi/2,attack_len_l)).^2;
    sustain_ramp_l=ones(1,sustain_len_l)*env_max;
    release_ramp_l=env_min+(env_max-env_min)*sin(linspace(pi/2,0,release_len_l)).^2;
    pause_b_ramp_l=ones(1,pause_b_len_l)*env_min;
    ramp_l=[attack_ramp_l sustain_ramp_l release_ramp_l pause_b_ramp_l pause_f_ramp_l ];
    % right channel
    pause_f_ramp_r=ones(1,pause_f_len_r)*env_min;
    attack_ramp_r=env_min+(env_max-env_min)*sin(linspace(0,pi/2,attack_len_r)).^2;
    sustain_ramp_r=ones(1,sustain_len_r)*env_max;
    release_ramp_r=env_min+(env_max-env_min)*sin(linspace(pi/2,0,release_len_r)).^2;
    pause_b_ramp_r=ones(1,pause_b_len_r)*env_min;
    ramp_r=[attack_ramp_r sustain_ramp_r release_ramp_r pause_b_ramp_r pause_f_ramp_r];
end

ramp_len_l=length(ramp_l);
ramp_len_r=length(ramp_r);

if(ramp_len_l~=ramp_len_r)
    sprintf('Caution, envelopes have different length!')
end

% save single envelope cycle as mat file
%global counter;
%if(is_reference==0)
%filename_ramp=sprintf('env_single_cond%0.2d_tref1.mat',counter)
%envelope=[ramp_l' ramp_r'];
%save(filename_ramp,'envelope')
%end


% quick matlab plot
%global counter;
%plotvector=circshift([ramp_l' circshift(ramp_r',dp)],-dp);
%xvec=(1:length(ramp_r))/48000*1000;
%figure;plot(xvec,plotvector(:,1),'b');hold on;plot(xvec,plotvector(:,2),'r');hold off;title(counter);

% save binaural ramp data for plotting conditions in gnuplot
% global counter;
% if(is_reference==0)
%      plotvector=circshift([ramp_l' circshift(ramp_r',dp)],-dp);
%      outmatrix=[(((1:(length(ramp_l)*20))/48000)*1000)' repmat(plotvector(:,1),20,1) repmat(plotvector(:,2),20,1)];
%      filename=sprintf('envelope_%d.dat',counter);
%      save(filename,'outmatrix','-ascii','-tabs');
% end

% get number of complete cycles that fit into signal length
envelope_nr_l=ceil(length(signal)/ramp_len_l);
envelope_nr_r=ceil(length(signal)/ramp_len_r);

% save ramp data for plotting
%outmatrix=[((1:length(ramp))/fs*1000)' ramp'];
%filename=sprintf('ramp_%d',cputime);
%save(filename,'outmatrix','-ascii','-tabs');


% generate ramp signal with the signal length
ramp_l=repmat(ramp_l,1,envelope_nr_l);
%ramp_l(length(signal)+1:end)=[];
ramp_l=ramp_l';

ramp_r=repmat(ramp_r,1,envelope_nr_r);
%ramp_r(length(signal)+1:end)=[];
ramp_r=ramp_r';

% get binaural, shift right channel
ramp_r=[zeros(dp,1);ramp_r(1:size(ramp_r,1)-dp,1)];

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

%figure;plot(ramp(:,1));
%hold on;plot((sin(2*pi*(0:len-1)*fm/2/fs).^2)','r');
%figure;plot(ramp(:,1)-(sin(2*pi*(0:len-1)*fm/2/fs).^2)');
%sinus=(sin(2*pi*(0:len-1)*fm/2/fs).^2);
%plot_spec(sinus,48000);
%figure;plot_spec(ramp(:,1),48000);
signal=[signal' signal'];
ramp =[ramp_l ramp_r];
out = signal .* ramp;
out = normalize(out,env_max);
% let signal start nicely
%out = circshift(out,-dp);
%figure;plot(out);

