% from Les Bernstein with minor code modifications by Mathias Dietz

function cross_correlogram = Bernstein_Trahiotis_crosscor_2012(stim,samplefreq_hz)
global model_framework
ptauFreq=csvread([model_framework.iopath 'a_priori.csv']); % uses a-priori knowledge. Alternatively f_mod can be extracted from the simulus but this is easier.
disp('Note: this model requires the binaural toolbox (Akeroyd 2001) in the path')

%% convert to Akeroyd-Wave format
mstim = mwavecreate(stim(:,1), stim(:,2), samplefreq_hz,0);

%% actual model
stimcorrel_temp=mcorrelogram_x(2000,8000,4,-2000,2000,'shear_hif','cp',mstim,0);
stimcorrel=mccgramdelayweight_hitest(stimcorrel_temp,'shear',ptauFreq,0);
%Find the IID
IIDmeasured=10.*log10(sum(stimcorrel.powerleft)./sum(stimcorrel.powerright));
%Nonlinear processing magnifies IID by factor of three, so divide;
IIDmeasured=IIDmeasured/3;
cross_correlogram=mccgramIIDweight(stimcorrel,IIDmeasured,0);