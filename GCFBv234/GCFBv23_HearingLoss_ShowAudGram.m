%
%       Show Audiogram of GCFBv230_HearingLoss
%       Irino T.,
%       Created:   9 Sep 21  from testGCFBv231_HearingLoss
%       Modified:   9 Sep 21
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%
%     data from [GCparam] = GCFBv23_HearingLoss(GCparam, GCresp);
%
function [NameFig] = GCFBv23_HearingLoss_ShowAudGram(GCparam)


NameFig = ['Fig_AudGram_'  GCparam.HLoss.Type ...
    '_CmprsHlth' num2str(min(GCparam.HLoss.CompressionHealth))];

LogFag = log2(GCparam.HLoss.FaudgramList);
plot(LogFag,zeros(size(GCparam.HLoss.FaudgramList)),'x-');
hold on;
plot(LogFag,-GCparam.HLoss.PinLossdB_ACT,'*--');
plot(LogFag,-GCparam.HLoss.PinLossdB_PAS,'^--');
plot(LogFag,-GCparam.HLoss.HearingLeveldB,'o-');
plot(LogFag,-GCparam.HLoss.PinLossdB_ACT_Init,':');
set(gca,'Xtick', LogFag)
set(gca,'XtickLabel',GCparam.HLoss.FaudgramList)
for nFag = 1: length(GCparam.HLoss.FaudgramList)
    text(log2(GCparam.HLoss.FaudgramList(nFag)),-GCparam.HLoss.PinLossdB_ACT(nFag)+3, ...
        sprintf('%4.2f',GCparam.HLoss.CompressionHealth(nFag)),'HorizontalAlignment','center')
end

legend('NH','HLossdB_ACT','HLossdB_PAS','HearingLevel','HLossdB_ACT_Init',...
    'Location','SouthWest','interpreter','none');

grid on;
axis([log2([100 10000]) -80 10])
set(gca,'YTickLabel', [80:-10:-10]);
title(['Audiogram (ACT & PAS Loss): ' GCparam.HLoss.Type ],'interpreter','none');
xlabel('Frequency (Hz)');
ylabel('Hearing Level (dB) ');

end



% plot(log2(GCparam.Fr1), -GCparam.HLoss.FB_PinLossdB_PAS,'--')



