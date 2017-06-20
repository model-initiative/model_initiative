% lp_filter - apply low pass filter to signal
%
% order = order of filter
% clow = lower cutoff frequency
% chigh = upper cutoff frequency
% cutoff = cutoff frequency
% f_sam = sampling frequency
% signal = signal to be filtered
function out = bp_filter(order,clow,chigh,f_sam,signal)

fNorm = [clow chigh] / (f_sam/2);
[b,a] = butter(order, fNorm);
%freqz(b,a,128,f_sam);
out = filter(b, a, signal);
