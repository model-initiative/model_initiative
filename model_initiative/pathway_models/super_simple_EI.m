function pathway_out = super_simple_EI(wave,noise_level)
% simple exemplary binaural pathway model
wave = wave + noise_level.* randn(size(wave)); % add internal noise
pathway_out.ei= diff(wave,[],2); % channel 2 - channel 1