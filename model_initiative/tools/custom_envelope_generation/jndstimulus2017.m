% makes target and diotic reference from the 10 experiments described in 
% Klein-Hennig et al. JASA 2011 Table 1

function [tuser, tref1] = jndstimulus2017(experiment,par,itd,noise_masker,target_ild)

rand('twister',sum(100*clock));

fc=4000; % carrier frequency
noise_level=-5;
fs=48000;
intervallen = 28800;
level = 60;

% parameters = 2x5 vector:
%       pause_f_l attack_l sustain_l release_l pause_b_l
%       pause_f_r attack_r sustain_r release_r pause_b_r

switch experiment
    case 1 % attack
        parameters=repmat([8750,par,8750,1250,0],2,1);
        temp_tref1=ramp_mod_ms_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1,1);
        temp_tuser=ramp_mod_ms_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0,1);
    case 2 % sustain
        parameters=repmat([8750,1250,par,1250,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);
    case 3 % decay
        parameters=repmat([8750,par,8750,1250,0],2,1); % second param becomes decay
        temp_tref1=ramp_mod_ms_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1,2);
        temp_tuser=ramp_mod_ms_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0,2);
    case 4 % pause
        parameters=repmat([par,1250,8750,1250,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);
    case 5 % level (set later)
        parameters=repmat([0,10000,0,10000,0],2,1);
        level = par;
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);   
    case 6
        disp('specify 6.1 for SAM or 6.2 for PSW')
    case 6.1 % fm (SAM)
        parameters=repmat([0,par,0,par,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);
    case 6.2 % fm (PSW)
        parameters=repmat([par,1250,par,1250,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);
    case 7
        disp('specify 7.1 for SAM or 7.2 for PSW')
    case 7.1 % dc offset (SAM)
        parameters=repmat([0,10000,0,10000,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0+par,1+par,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0+par,1+par,'sin2',0);
    case 7.2 % dc offset (PSW)
        parameters=repmat([8750,1250,8750,1250,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0+par,1+par,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0+par,1+par,'sin2',0);
    case 8 % temporal asym (par=1: steep attack; par=2: shallow attack, steep decay)
        if par == 1
            parameters=repmat([10000,1250,0,18750,0],2,1);
        elseif par == 2
            parameters=repmat([10000,18750,0,1250,0],2,1);
        elseif par == 3 % only Dietz et al. 2015
            parameters=repmat([8750,1250,8750,1250,0],2,1);
        end
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);
    case 9
        disp('transposed tone currently not implemented')    
    case 10 % attack full waveform
        parameters=repmat([8750,par,8750,1250,0],2,1);
        temp_tref1=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',1);
        temp_tuser=ramp_mod_ms_alt3_nopause(24000,48000,fc,parameters,itd,0,1,'sin2',0);
    otherwise
        condition
        error('Condition does not exist or I just don''t know what to do with it');
end

sine_parameters=[0,intervallen/2,0,intervallen/2,0;0,intervallen/2,0,intervallen/2,0];
sine=ramp_mod_ms_alt3_nopause_noshift(intervallen,fs,fc,sine_parameters,itd,0,1,'sin2',1);
rms_amsinus=rms(sine(:,1));

% generate masker
temp_tref1=[zeros(2400,2);temp_tref1;zeros(2400,2)];
temp_tuser=[zeros(2400,2);temp_tuser;zeros(2400,2)];
mask_l_tuser=lpmasknoise(intervallen,200,1000,fs);
mask_r_tuser=lpmasknoise(intervallen,200,1000,fs);
mask_l_tref1=lpmasknoise(intervallen,200,1000,fs);
mask_r_tref1=lpmasknoise(intervallen,200,1000,fs);
mask_tuser=[mask_l_tuser mask_r_tuser];
mask_tref1=[mask_l_tref1 mask_r_tref1];

% set masker level here
normalize(mask_tuser);
normalize(mask_tref1);
mask_tuser=mask_tuser*(10^(noise_level/20));
mask_tref1=mask_tref1*(10^(noise_level/20));

% set target ILD (for Dietz et al 2015) and make positive ITDs right leading
tuser=fliplr(same_loudness_ild(temp_tuser,target_ild)); 
tref1=temp_tref1;

% apply masker window
window_len=0.05;
mask_window_len=round(window_len*fs);
mask_hann_window = repmat(hannfl(intervallen,mask_window_len,mask_window_len),1,2);
mask_tuser = mask_tuser .* mask_hann_window;
mask_tref1 = mask_tref1 .* mask_hann_window;

% save envelopes as matlab files
% filename_tref1=sprintf('envelope_cond%0.2d_tref1.mat',counter)
% filename_tuser=sprintf('envelope_cond%0.2d_tuser.mat',counter)
% env_tref1=abs(hilbert(tref1,intervallen));
% env_tuser=abs(hilbert(tuser,intervallen));
% save(filename_tref1,'env_tref1')
% save(filename_tuser,'env_tuser')
% wavwrite(tuser,fs,32,filename_tuser)
% end

% apply signal window
window_len=0.125;
signal_window_len=round(window_len*fs);
signal_window = repmat(hannfl(intervallen-4800,signal_window_len,signal_window_len),1,2);
tuser(2401:end-2400,:) = tuser(2401:end-2400,:) .* signal_window;
tref1(2401:end-2400,:) = tref1(2401:end-2400,:) .* signal_window;

% add masking noise
if(noise_masker==1)
    tuser=tuser+mask_tuser;
    tref1=tref1+mask_tref1;
end

% set signal to rms .00003 for 0 dB SPL
tuser=tuser/rms_amsinus * .00003;
tref1=tref1/rms_amsinus * .00003;

% set level
tuser = tuser * 10^(level/20);
tref1 = tref1 * 10^(level/20);
