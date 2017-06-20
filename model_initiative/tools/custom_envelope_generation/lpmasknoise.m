% distmasknoise - generate noise with a white noise/pink noise transition
%
% len = signal duration in samples
% pedge = transition frequency white/pink
% lnotch = cutoff frequency for lowpass filter
% fs = sampling frequency
function out = lpmasknoise(len,pedge,lnotch,fs)

white_noise=bpnoise(len,0,fs/2,fs);

in=white_noise;

len=length(in);
lenh=fix(len/2);

% check if len/2 is even
if lenh == len/2
   even=1;
else
   even=0;
end

% fft of signal
tmp=fft(in);

% only positive frequencies are interesting
tmp=tmp(1:lenh+1,1);

% vector containing frequencies / 100 ... what for?
filt=(0:lenh)' /100;

% something that was commented when i got here
% pow=-1*ones(lenh+1,1);

% starting position
pos=ceil(pedge*len/fs);      	%index of 20 Hz

% generate filter
filt(1,1)=1;
filt=sqrt(1./filt);% .^ pow;

% set everything below starting position to zero
filt(1:pos,1)=filt(pos+1,1);

% multiply with filter
tmp=tmp .* filt;

% do something magical to prepare inverse fft
swap=tmp(2:lenh-even+1);
swap=flipud(conj(swap));
tmp=[tmp;swap];

% back to time domain
out=real(ifft(tmp));

%pink_noise=out; pink(bpnoise(len,pedge+1,fs/2,fs),fs);
%tmp=white_noise+pink_noise;

out=lp_filter(5,lnotch,fs,out);