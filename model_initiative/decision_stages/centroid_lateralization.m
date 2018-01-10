function response=centroid_lateralization(cross_correlogram,response_type_is_IID)

% cross_correlogram: Akeroyd Toolbox format
% response_type: 0=ITD otherwise IID

response=mccgramcentroid_BT(cross_correlogram{1,1},0);       

if response_type_is_IID
    IIDScale=11.70;
    IIDScale=IIDScale/1.1671; %Increasing the new predictions by about a factor of 1.17 resulted in the minimum rms deviation between the old and new predictions.
    response=response./IIDScale;
end

