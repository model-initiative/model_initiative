% code from Les Berstein with small modifications by Mathias Dietz

function pointerIID = Bernstein_Trahiotis_2012

global model_framework

fs=81920;

cf=4000;
mf=[32 64 128 256];
n=[1 8];
m=[0.25 0.5 0.75 1.0];
delay=1e-6*[0 200 400 600 800 1000];
IID=[-8:4:8];
duration=.3;
npts=round(duration.*fs);
a=.05;

srate=1/fs;

pointerIID=zeros(length(mf),length(n),length(m),length(delay),length(IID));
counter = 0;

for q=1:length(mf)
%EXPONENT LOOP BEGINS HERE
% model may need a-priori knowledge on modulation frequency
csvwrite( [model_framework.iopath 'a_priori.csv'],mf(q))
disp(['writing stimulus paramter to disk for model: f_mod = ' num2str(mf(q)) ' Hz']);
for e=(1:length(n));
  t=0:srate:((npts-1)*srate);
 %MOD DEPTH LOOP BEGINS HERE
 for im=(1:length(m));
  %ITD LOOP BEGINS HERE
  for j=1:length(delay)
      tl=t-delay(j)/2;
      tr=t+delay(j)/2;
   % IID loop begins here
   for iidindx=1:length(IID);
       
       % generate L/R raised sine stimuli with ITD and IID
       stim(:,1)=a.*(sin(2.*pi.*cf.*tl)).*[2.*m(im).*(((1-cos(2.*pi.*mf(q).*tl))./2).^n(e)-0.5)+1].*10.^((IID(iidindx)/2)./20);
       stim(:,2)=a.*(sin(2.*pi.*cf.*tr)).*[2.*m(im).*(((1-cos(2.*pi.*mf(q).*tr))./2).^n(e)-0.5)+1].*10.^(-(IID(iidindx)/2)./20);
       
       % write to disk model_framework path defined in here
        audiowrite([model_framework.iopath 'interval_1.wav'],stim,fs);
        
        counter = counter + 1;
        disp(['condition: ' num2str(counter) ' of 960']);
                
        % wait for model to write "choice.dat"
        go = 0;
        while ~go
            go = exist([model_framework.iopath 'detector_out.csv'], 'file');
            pause(.02)
        end

        % grab the response
        pointerIID(q,e,im,j,iidindx) = csvread([model_framework.iopath 'detector_out.csv']);
        delete( [model_framework.iopath 'detector_out.csv'] )
              
   end; %OF IID LOOP   
  end; %OF ITD LOOP
 end; %OF MODDEPTH LOOP
 end; %OF exponents LOOP   
end; %OF MF LOOP  

csvwrite([model_framework.iopath, 'finished.txt'],'')
save([model_framework.datapath, 'Bernstein_Trahiotis_2012_pointerILDs'], 'pointerIID', 'delay', 'IID','mf','m','n')
