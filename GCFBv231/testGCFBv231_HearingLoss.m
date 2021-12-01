%
%       test GCFBv230_HearingLoss
%       Irino T.,
%       Created: 21 May 20
%       Modified: 21 May 20
%       Modified: 22 May 20
%       Modified: 19 Jul 20
%       Modified:  24 Jan 2021 (InternalCmpnstLeveldB = -7, FactCmpnst --> OK)
%       Modified:  28 Aug 2021 v231
%
%

%%%% Stimuli : a simple pulse train %%%%
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
DirFig = [DirProg '/Fig/'];

if exist('GCresp') == 0
    testGCFBv231
end;

figure(1); clf
GCparam.HLoss.Type = 'NH';
GCparam.HLoss.Type = 'HL2';

CHlist = [1 0.5 0];
for nCH = 1:length(CHlist)
    GCparam.HLoss.CompressionHealth = CHlist(nCH);
    
    tic;
    [GCparam] = GCFBv231_HearingLoss(GCparam, GCresp);
    toc;
    % GCparam.HLoss
    subplot(2,2,nCH)
    [NameFig] =  GCFBv231_HearingLoss_ShowAudGram(GCparam);
    
end

NameFig
printi(3,0,2);
print([DirFig  NameFig '_All' ] ,'-depsc','-tiff');
%% %%%
%
%%%%%%%%

% [GCparam.HLoss.CompressionHealth_SetVal; GCparam.HLoss.CompressionHealth]
%GCparam.HLoss.InputdB_At_AbsThreshold
%GCparam.HLoss.HL0_SPLdB
%GCparam.HLoss.GainMidEar
% 
% figure(1); clf
% plot(log2(GCparam.HLoss.FaudgramList),zeros(size(GCparam.HLoss.FaudgramList)),'x-');
% hold on;
% plot(log2(GCparam.HLoss.FaudgramList),-GCparam.HLoss.HLossdB_OHC,'*--');
% plot(log2(GCparam.HLoss.FaudgramList),-GCparam.HLoss.HLossdB_IHC,'^--');
% plot(log2(GCparam.HLoss.FaudgramList),-GCparam.HLoss.HearingLeveldB,'o-');
% plot(log2(GCparam.HLoss.FaudgramList),-GCparam.HLoss.HLossdB_OHC_Init,':');
% 
% plot(log2(GCresp.Fr1), -GCparam.HLoss.FB_HLossdB_IHC,'--')
% set(gca,'Xtick', log2(GCparam.HLoss.FaudgramList))
% %aa = get(gca,'Xtick')
% set(gca,'XtickLabel',GCparam.HLoss.FaudgramList)
% for nFag = 1: length(GCparam.HLoss.FaudgramList)
%     text(log2(GCparam.HLoss.FaudgramList(nFag)),-GCparam.HLoss.HLossdB_OHC(nFag)+3, ...
%         num2str(GCparam.HLoss.CompressionHealth(nFag)),'HorizontalAlignment','center')
% end
% grid on;
% title('Audiogram & Gain');
% xlabel('Frequency (Hz)');
% ylabel('Gain (== -HL) (dB) ');
% axis([log2([100 10000]) -80 10])
% 
% legend('NH','HLossdB_OHC','HLossdB_IHC','HearingLevel','HLossdB_OHC_Init','FB_HLossdB_IHC',...
%     'Location','SouthWest','interpreter','none');
% 
% drawnow
% printi(3,0,2);
% print([DirFig, 'Fig_AudGram_GCresp_'  GCparam.HLoss.Type ...
%     '_CmprsHlth' num2str(min(GCparam.HLoss.CompressionHealth)) '.eps'] ,'-depsc','-tiff');
% 


% %% %%%%
% %  NHのCmprsHlthに対する変化
% %%%%%%%
% [NumFag, NumLeveldB, NumCmprs] = size(GCparam.HLoss.OutputdB);
% NumCmprsPlot = 1:NumCmprs;
% if NumCmprs > 100  % 0.01ステップの場合、見にくいので間引く
%     NumCmprsPlot = 1:10:101;
% end;
% figure(2); clf
% for nFag = 1:NumFag% 比較のため8000 Hzを除く。NumFag  
%     % subplot(3,3,nFag)
%     subplot(4,2,nFag)
%     x = GCparam.HLoss.InputdB;
%     y = squeeze(GCparam.HLoss.OutputdB(nFag,:,NumCmprsPlot));
%     plot(x,y,x,zeros(size(x)),'-')
%     text(65, 55, [sprintf('%3.1f', GCparam.HLoss.OutputdB_For_Normalize(nFag)) ' (dB)']);
%     hold on;
%     z = GCparam.HLoss.InputdB_At_AbsThreshold(nFag,NumCmprsPlot);
%     plot(z,zeros(size(z)),'x');
%     HL0 = GCparam.HLoss.InputdB_At_AbsThreshold(nFag,1);
%     plot(HL0,0,'o')
%     text(HL0, 5,['HL0='  sprintf('%3.1f', HL0)],'Rotation',90);
%     %text(HL0-5, 20, [sprintf('%3.1f', HL0) ' (dB)']);
%     grid on;
%     xlabel('Input (dB)');
%     ylabel('Output (dB)');
%     axis([-5 105 -20 60])
%     title(['IO function at ' num2str(GCparam.HLoss.FaudgramList(nFag)) ' Hz']);
% end;
% 
% 
% printi(2,0);
% print([DirFig, 'Fig_IOfunc_GCresp_NH_CmprsHlth.eps'],'-depsc','-tiff');
% 



