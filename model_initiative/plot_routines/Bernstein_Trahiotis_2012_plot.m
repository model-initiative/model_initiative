figure;

y=[0.1 0.54];
x=0.1:.1:.5;
cols = 2;

for q=1:size(pointerIID,1)
%EXPONENT LOOP BEGINS HERE
for e= 1:size(pointerIID,2)
  %MOD DEPTH LOOP BEGINS HERE
 for im= 1:size(pointerIID,3)
  
    axes('position',[mod(q-1,cols)*.45+im*.1 floor((q-1)/cols)*-.45+e*.2+.35 0.1 0.2],'box','on')
    plot(0:.2:1,squeeze(pointerIID(q,size(pointerIID,2)-e+1,im,:,:)))
    if e == 1
        set(gca,'Visible','on','XTick',[0 .2 .4 .6 .8 1],'xlim',[-.1 1.1])
        xlabel('ITD')
    else
        set(gca,'Visible','on','XTick',[0 .2 .4 .6 .8 1],'xlim',[-.1 1.1],'XTickLabel',{'','','','','','',''})
    end
    if im == 1
        ylabel('ILD [dB]')
        set(gca,'YTick',-20:5:30,'ylim',[-21 31])
    else
        set(gca,'YTick',-20:5:30,'ylim',[-21 31],'YTickLabel',{'','','','','','','','','','','','',''},'ylim',[-21 31])
    end
    
    %text(0.3,15,'text')
 end
end
end
