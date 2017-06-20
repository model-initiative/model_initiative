function response=largest_residual(pathway_out)
% simple detector for interaural decorrelation
% input is from EI stage

for n = 1: length(pathway_out)
	residual(n) = mean(mean(abs(pathway_out{n}.ei)));
end

[dummy_value, response] = max(residual);

  