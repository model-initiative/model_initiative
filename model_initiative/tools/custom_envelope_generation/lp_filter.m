% lp_filter - apply low pass filter to signal
%
% order = order of filter
% cutoff = cutoff frequency
% f_sam = sampling frequency
% signal = signal to be filtered
function out = lp_filter(order,cutoff,f_sam,signal)

fNorm = cutoff / (f_sam/2);
[b,a] = butter(order, fNorm, 'low');
% freqz(b,a,128,f_sam);
out = filter(b, a, signal);
