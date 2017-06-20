% as used in Dietz et al. 2013 JASA and 2015 JASA-EL

function out = same_loudness_ild(in,ild_dB)
% positiv ILD = right channel louder
out(:,1) = in(:,1)*2/(1+10^+(ild_dB/20));
out(:,2) = in(:,2)*2/(1+10^-(ild_dB/20));