function van_de_Par_Kohlrausch_1999_user

global def
global work
global set


% make S+N. At this stage 70 dB SPL (fixed noise level) corresponds to a digital RMS = .01
% make single channel N
% different strategy than in paper but should effectively be the  same
noise1 = bpnoise(def.intervallen,set.target_frequency-work.exppar1/2,set.target_frequency+work.exppar1/2,def.samplerate).* set.window /100;
noise2 = bpnoise(def.intervallen,set.target_frequency-work.exppar1/2,set.target_frequency+work.exppar1/2,def.samplerate).* set.window /100;
noise3 = bpnoise(def.intervallen,set.target_frequency-work.exppar1/2,set.target_frequency+work.exppar1/2,def.samplerate).* set.window /100;
% make single channel S
tone = sin(2*pi*(1:def.intervallen)/def.samplerate*set.target_frequency)' * sqrt(2) .* set.tone_window /100;
% mix N and S
tref1 = [noise1 noise1*set.N_S_phase(1)];
tref2 = [noise2 noise2*set.N_S_phase(1)];
tuser = [noise3 noise3*set.N_S_phase(1)] + ...
    [tone tone*set.N_S_phase(2)]*10^(work.expvaract/20);

% pre-, post- and pausesignals (all zeros)
presig = zeros(def.presiglen,2);
postsig = zeros(def.postsiglen,2);
pausesig = zeros(def.pauselen,2);

% make required fields in work
work.signal = [tuser(:,1) tuser(:,2) tref1(:,1) tref1(:,2) tref2(:,1) tref2(:,2)];	% left = right (diotic) first two columns holds the test signal (left right)
work.presig = presig;											% must contain the presignal
work.postsig = postsig;											% must contain the postsignal
work.pausesig = pausesig;										% must contain the pausesignal
% eof