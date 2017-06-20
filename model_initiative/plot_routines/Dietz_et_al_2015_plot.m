function Dietz_et_al_2015_plot(sub_experiment)

load(['Dietz_et_al_2015_pointerILDs_Experiment_',num2str(sub_experiment),'.mat']);

disp('This plot shows all modeled conditions, i.e. more than tested experimentally.')
disp('Therefore, the format differs from the paper')
disp('In all 3 experiments there are likely 2 conditions with identical results plotted on top of each other.')
disp('Sorry for not having a legend relating shape to color at this stage.')
disp('Different offsets correspond to different test ILDs (-5 0 +5 dB).')

testITDs=[0 .2 .6 1 1.4 2];

figure;
hold on
for n=1:size(pointerILD,3)
    plot(testITDs,squeeze(pointerILD(:,:,n))','x-')
end
set(gca,'ygrid','on','Visible','on','XTick',testITDs,'xlim',[0 2.1])
xlabel('ITD (ms)')
ylabel('pointer ILD [dB]')

