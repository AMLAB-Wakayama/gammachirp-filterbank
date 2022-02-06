%
%       Show Audiogram of GCFBv230_HearingLoss
%       Irino T.,
%       Created:   9 Sep 21  from testGCFBv231_HearingLoss
%       Modified:   9 Sep 21
%
%     data from [GCparam] = GCFBv231_HearingLoss(GCparam, GCresp);
%
function [NameFig] = GCFBv230_HearingLoss_ShowAudGram(GCparam)


NameFig = ['Fig_AudGram_'  GCparam.HLoss.Type ...
    '_CmprsHlth' num2str(min(GCparam.HLoss.CompressionHealth))];

LogFag = log2(GCparam.HLoss.FaudgramList);
plot(LogFag,zeros(size(GCparam.HLoss.FaudgramList)),'x-');
hold on;
plot(LogFag,-GCparam.HLoss.PinLossdB_OHC,'*--');
plot(LogFag,-GCparam.HLoss.PinLossdB_IHC,'^--');
plot(LogFag,-GCparam.HLoss.HearingLeveldB,'o-');
plot(LogFag,-GCparam.HLoss.PinLossdB_OHC_Init,':');
set(gca,'Xtick', LogFag)
set(gca,'XtickLabel',GCparam.HLoss.FaudgramList)
for nFag = 1: length(GCparam.HLoss.FaudgramList)
    text(log2(GCparam.HLoss.FaudgramList(nFag)),-GCparam.HLoss.PinLossdB_OHC(nFag)+3, ...
        sprintf('%4.2f',GCparam.HLoss.CompressionHealth(nFag)),'HorizontalAlignment','center')
end

legend('NH','HLossdB_OHC','HLossdB_IHC','HearingLevel','HLossdB_OHC_Init',...
    'Location','SouthWest','interpreter','none');

grid on;
axis([log2([100 10000]) -80 10])
set(gca,'YTickLabel', [80:-10:-10]);
title(['Audiogram (OHC & IHC Loss): ' GCparam.HLoss.Type ],'interpreter','none');
xlabel('Frequency (Hz)');
ylabel('Hearing Level (dB) ');

end



% plot(log2(GCparam.Fr1), -GCparam.HLoss.FB_PinLossdB_IHC,'--')



