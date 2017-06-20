function afc_plot(expname,modelname,sub_experiment,dataType)

% generic plot script for many experiments done with AFC. 
% No specific formatting

fontsize = 15;
if isempty(sub_experiment)
    subExString = '';
else
    subExString = ['_', num2str(sub_experiment)];
end
model_result_file_name = [expname, '_ModelInitiative_', modelname,subExString, '.dat'];

results = load(model_result_file_name);

number_of_exppars = size(results,2)-2;

conditions1 = unique(results(:,1));
if number_of_exppars==2
    conditions2 = unique(results(:,2));
    for k = 1:length(conditions1)
        for l = 1:length(conditions2)
            IDX = find(results(:,1)== conditions1(k) & results(:,2)== conditions2(l));
            valMat(:,k,l) = results(IDX,3);
            variMat(:,k,l) = results(IDX,4);
        end
    end
elseif number_of_exppars==1
    for k = 1:length(conditions1)
        IDX = find(results(:,1)== conditions1(k));
        valMat(:,k) = results(IDX,2);
        variMat(:,k) = results(IDX,3);
    end
    conditions2 = 0;
end


% this filters out terminated runs and sets value to termination_value
valMat(variMat < 1e-9) = inf;

maxFinite = max(max(valMat(isfinite(valMat))));
minFinite = min(min(valMat(isfinite(valMat))));
for n = 1 : length(conditions2)
    figure(n)
    title(['condition ' num2str(conditions2(n))])
    errorbar(conditions1,mean(squeeze(valMat(:,:,n))),std(squeeze(variMat(:,:,n))));
    set(gca,'Fontsize',fontsize)
    ylim([minFinite maxFinite])

    switch dataType
        case 'ITD'
            set(gca,'YScale','log')
            ylabel('threshold ITD')
        otherwise
            ylabel(dataType)
    end
end