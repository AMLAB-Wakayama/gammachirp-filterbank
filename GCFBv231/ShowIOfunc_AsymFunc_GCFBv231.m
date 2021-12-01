%
%       Plot AsymFunc IOfunction for explaining HL_OHC + HL_IHC
%       Toshio IRINO
%       Created:   13 Sep 2021
%       Modified:  13 Sep 2021
%       Modified:    5 Oct 2021
%       Modified:    6 Oct 2021
%       Modified:    8 Oct 2021
%       Modified:  30 Oct 2021
%       Modified:  10 Nov 2021
%       Modified:  11 Nov 2021
%
%
%
clear
clf
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
DirFig = [DirProg '/Fig/'];

fs   = 48000;
GCparam.fs  = fs;
GCparam.FRange  = [100 12000]; % 8000 Hzまでカバーするため、あえて広く取る
GCparam.NumCh = 100;
[GCparam, GCresp] = GCFBv231_SetParam(GCparam);  %MakeAsymCmpFiltersV2の計算に必要

Fr1query = 4000;
PindBList = [-10:5:120];
CmprsHlthList = [1, 0.5];
BiasAbsThrdB = 48.5;
% HL_IHC = 20;
Loss_IHC = 10.5;
C=colororder('default');
colororder(C([1, 2, 4],:))
StrMarker = {'-','--','-.'};
tic
for nCmprsHlth = 1:length(CmprsHlthList)
    CmprsHlth = CmprsHlthList(nCmprsHlth);
    [AFoutdB, IOfuncdB] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1query,CmprsHlth,PindBList);
    
    plot(PindBList,IOfuncdB-BiasAbsThrdB,char(StrMarker(nCmprsHlth)),'LineWidth',1.5)
    hold on;
    if CmprsHlth < 1
        plot(PindBList,IOfuncdB-BiasAbsThrdB-Loss_IHC,char(StrMarker(3)),'LineWidth',1.5)
    end
    % grid on;
    % text(-10,110,[int2str(Fr1query)  ' Hz']);
end
HLx = 45; % HL = 45 dB
AbsThrHL0dB = HL2PinCochlea(Fr1query,0)   % == HL2PinCochlea(1000,0)
AbsThrHLxdB = AbsThrHL0dB +HLx;  
AbsThrOHCLoss = 32.2;

plot([-10 120],[0 0],'-k', PindBList,PindBList-BiasAbsThrdB,':k');
plot(AbsThrHL0dB, 0, 'k^');
text(AbsThrHL0dB,4,['HL 0 dB'],'Rotation',90);
plot(AbsThrHLxdB, 0, 'ko');
text(AbsThrHLxdB,-17,['HL ' int2str(HLx) ' dB'],'Rotation',90);
axis([-10 110 -20 60])
axis([-5 105 -20 60])
xlabel('Cochlear input (dB)');
ylabel('Output re. Abs. Thrs. (dB)');

%%% 
% Labels
%%%
text(41,22,'c_2^{(NH)}','Rotation',5);
text(43,12,'c_2^{(HL)}','Rotation',27);
plot(AbsThrHL0dB*[1 1],[-2 3],'k-')
plot(AbsThrOHCLoss*[1 1],[-2 3],'k-')
plot(AbsThrHLxdB*[1 1],[-2 3],'k-')
% using arrow
% https://jp.mathworks.com/matlabcentral/fileexchange/278-arrow
addpath([getenv('HOME') '/m-file/PDS/arrow/']); %
arrow([AbsThrHL0dB,1.5],[AbsThrOHCLoss, 1.5],'Width',1)
text(15.5,5,'HL_{OHC}');
arrow([AbsThrOHCLoss, 1.5],[AbsThrHLxdB, 1.5],'Width',1)
text(36,5,'HL_{IHC}');
arrow([58, 15.5],[58, 5],'Width',1)
text(59.5,12.8,'L_{IHC}');
arrow([AbsThrOHCLoss, -16.5],[AbsThrOHCLoss, 0],'Width',1)
text(AbsThrOHCLoss+1,-13,'G_{OHC}');


%%%%%%
NameFig = [DirFig '/Fig_IOfunc_AsymFunc_HL_OHC_IHC'];
printi(3,0,0.9);
print(NameFig,'-depsc','-tiff');


