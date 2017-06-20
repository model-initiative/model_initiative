function pathway_out = no_decision_stage(pathway_out)
% do nothing but make sure output is not a cell

if isa(pathway_out,'cell')==1
		pathway_out=cell2mat(pathway_out);
end