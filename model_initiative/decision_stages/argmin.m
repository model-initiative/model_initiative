function response = argmin(pathway_out)
% only for pathway_out = scalar value
% select interval with smallest value

if isa(pathway_out,'cell')==1
		pathway_out=cell2mat(pathway_out);
end
[min_value, response] = min(pathway_out);

