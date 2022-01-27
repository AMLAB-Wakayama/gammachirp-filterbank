%
%       test AsymFuncInOut
%       Toshio IRINO
%       Created:   14 Aug 2021 from GCFBv230
%       Modified:  14 Aug 2021
%       Modified:  15 Aug 2021 ーーー    GCFBv230_framebaseはACFではなくexp(c thetha)を直接使っている。
%       Modified:  17 Aug 2021 using Fr1query -- NOT Fp1
%       Modified:  28 Aug 2021 v231
%       Modified:  12 Oct  2021 v231
%       Modified:  27 Jan 2022  v231 minor change StartupGCFB;
%
%
%
clear
clf
StartupGCFB;
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
DirFig = [DirProg '/Fig/'];

fs   = 48000;
GCparam.fs  = fs;
GCparam.FRange  = [100 12000]; % 8000 Hzまでカバーするため、あえて広く取る
GCparam.NumCh = 100;
[GCparam, GCresp] = GCFBv231_SetParam(GCparam);  %MakeAsymCmpFiltersV2の計算に必要

FagList = [125 250 500 1000 2000 4000 8000]; % plot Faudgram ---> it will choose the closest Fr1.
PindBList = [-30:10:120];
CmprsHlthList = [1:-0.1:0];
% CmprsHlthList = [1, 2/3, 1/2, 1/3, 0];  % for WHIS setting

for nFag = 1:length(FagList)
    Fr1query = FagList(nFag);
    HL0Cch = HL2PinCochlea(Fr1query,0);  % HL 0 dB at Cochlear Input
    tic
    for nCmprsHlth = 1:length(CmprsHlthList)
        CmprsHlth = CmprsHlthList(nCmprsHlth);
        [AFoutdB1, IOfuncdB1] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1query,CmprsHlth,PindBList);
        if CmprsHlth == 1
            IOfuncdB_HL0 = interp1(PindBList,IOfuncdB1,HL0Cch);
            plot([-30 120],[0 0],'-k',PindBList,PindBList,':k');
            hold on
        end
        Rslt.IOfuncdB(nFag,nCmprsHlth,:) = IOfuncdB1 - IOfuncdB_HL0;
        Rslt.AbsThrdB(nFag,nCmprsHlth) = interp1(squeeze(Rslt.IOfuncdB(nFag,nCmprsHlth,:)),PindBList,0);
        
        subplot(4,2,nFag)
        plot(PindBList,squeeze(Rslt.IOfuncdB(nFag,nCmprsHlth,:)),'-')
        hold on;
        grid on;
        % text(-10,110,[int2str(Fr1query)  ' Hz']);
        xlabel('Input level (dB)');
        ylabel('Output level re. Abs. Thrsh. (dB)');
        axis([min(PindBList)-5, max(PindBList)+5, min(PindBList)-5, max(PindBList)+5])
        axis([-10 110 30 110])
        axis([-10 110 -20 70])
    end
    ax = axis;
    text(10,ax(2)-20,[int2str(Fr1query)  ' Hz']);
    drawnow
  toc
end

Rslt.FagList = FagList;
Rslt.PindBList = PindBList;
Rslt.CmprsHlthList = CmprsHlthList;
NameFig = [DirFig '/Fig_IOfunc_AsymFunc_AbsThr'];
save(NameFig,'Rslt');
printi(2,0);
print(NameFig,'-depsc','-tiff');

Rslt.AbsThrdB'   % WHIS用



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Check inverse function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Check inverse functions of GCFBv230_AsymFuncInOut.m');
fs   = 48000;
GCparam.fs  = fs;
GCparam.FRange  = [100 12000]; % 8000 Hzまでカバーするため、あえて広く取る
GCparam.NumCh = 100;
[GCparam, GCresp] = GCFBv231_SetParam(GCparam);  %MakeAsymCmpFiltersV2の計算に必要


PindB = 10;
Fr1 = 100;
CmprsHlth = 1;
[AFoutdB, IOfuncdB] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1,CmprsHlth,PindB);
AFoutdB
IOfuncdB

[PindBinv_IOfunc] = GCFBv231_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1, CmprsHlth,IOfuncdB);
ErrordB_IOfunc =  20*log10(rms(PindB-PindBinv_IOfunc)/PindB)
toc
PinVals = [PindB, PindBinv_IOfunc]

%%% 
CmprsHlth05 = 0.5;
[PindBinv_IOfunc05] = GCFBv231_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1, CmprsHlth05,IOfuncdB);
[AFoutdB, IOfuncdB_1] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1,CmprsHlth05,PindBinv_IOfunc05)
[IOfuncdB IOfuncdB_1 PindB PindBinv_IOfunc05]


%% %%%%
% Trash
%%%%%%
%         for nPindB = 1:length(PindBList)  ループ不要
%             PindB = PindBList(nPindB);
%             [AFoutdB, IOfuncdB] = GCFBv230_AsymFuncInOut(GCparam,GCresp,Fr1query,CmprsHlth,PindB);
%             AFoutdBPindB(nPindB) = AFoutdB;
%             IOfuncdBPindB(nPindB) = IOfuncdB;
%         end
