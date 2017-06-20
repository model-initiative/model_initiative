% sin_tone.m - generates monaural sine tone with various parameters:
%
% len      = signal length in samples
% f_sam    = sampling frequency
% f_car    = signal frequency
% dp_car   = signal phase delay [-pi,pi]

%% ------------------------------------------------------------------------
function out = sin_tone(len,f_sam,f_car,dp_car)
%len=len/f_sam;
%t_per_sample=len/f_sam;
out=sin(2*pi*(0:len-1)*f_car/f_sam+dp_car);