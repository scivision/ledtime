function updatelineplot(figh,NumLED,fps,tn,sec,booldata,simbool,DataPoints,tnisamp,...
                       rawylim,camsimoffset,showMeasBool,showMeasRaw)


figure(figh),clf(figh)
for ipl = 1:length(NumLED)
    ax = subplot(length(NumLED),1,ipl);
    if showMeasBool
        line(tn,booldata(:,ipl),'color','b')
        line(tn,simbool(:,ipl),'color','r')
    end
    if showMeasRaw
       ax = plotyy(tn,DataPoints(:,ipl),1:fps,simbool(:,ipl));
       if ~isempty(rawylim), set(ax(1),'ylim',rawylim), end
       set(ax(2),'ylim',[-0.01,1.01])
       ylabel(ax(2),['sim. LED ',int2str(NumLED(ipl))])
    end
    %plot sample locations
    for ismp = 1:length(tnisamp{ipl})
%                 ct = isampoffs{ipl}(ismp); % index of this second that sample was taken at
         ct = tnisamp{ipl}(ismp);
         line([ct,ct],[0,1],'color','r','parent',ax(2))
    end


    ylabel(ax(1),['meas. LED ',int2str(NumLED(ipl))])
end
xlabel(['sample index from t=',num2str(sec)])
annotation('textbox',[0.4,0.95,0.3,0.05],...
           'string',['ledOffset=',int2str(camsimoffset)],...
           'HorizontalAlignment','center')

end %function