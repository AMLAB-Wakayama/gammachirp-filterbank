%
%       Plot GCFBv231
%       IRINO T.
%       Created:   22 Jan 2021  from testGCFBv230
%       Modified:  22 Jan 2021  (renamed from testGCFBv230_plotIO_fcAll)
%       Modified:  16 Aug 2021 (プログラム確認。OK。)
%       Modified:  29 Aug 2021  v231
%       Modified:  11 Oct 2021  v231
%       Modified:  31 Dec 2021  modified subplot 
%       Modified:  27 Jan 2022  v231 minor change StartupGCFB;
%
%
%
clear
figure(1); clf;
figure(2); clf;

StartupGCFB;
DirProg = fileparts(which(mfilename)); % このプログラムがあるところ
DirFig = [DirProg '/Fig/'];

%%%% GCFB parameter setting %%%%
fs = 48000;
GCparam = []; % reset all
GCparam.fs     = fs;
GCparam.NumCh  = 100;
GCparam.FRange = [100, 12000];

GCparam.OutMidCrct = 'No';  %cochlear inputを見るときは、ELCをいれないこと。
%NG:  GCparam.OutMidCrct = 'ELC';  %ELCは、通常の外界の音　ーーー　今回は入出力関係のみ
% GCparam.OutMidCrct = 'FreeField';  just for check

StrOMC = '';
StrXlabel = 'Cochlea input (dB)';
if strcmp(upper(GCparam.OutMidCrct),'NO') == 0
    StrOMC = ['_' GCparam.OutMidCrct];
    StrXlabel = [GCparam.OutMidCrct ' level (dB)'];
end

GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
GCparam.DynHPAF.StrPrc = 'frame-base';

Param.fcList = [125 250 500 1000 2000 4000 8000];
 nTargetfcList = 1:length(Param.fcList);
%nTargetfcList = 2:length(Param.fcList);  % 250 ~ 8000 Hz for paper
% nTargetfcList = [6 7]; 

Param.SPLdBlist = [-10:10:100];
%Param.SPLdBlist = [-20:20:100];
% Param.SPLdBlist = [-40:20:100]; %%% <--- 
Param.TypeList = {'NH','HL2'};  %NHをreferenceとしてplot
% Param.TypeList = {'NH','HL3'};  %NHをreferenceとしてplot

% sound condition
Tsnd = 0.25; % sec  silenceの分を長めにとって影響を少なくする。
zz = zeros(1,0.050*fs);  % 50 ms silence

ColorList1 = colororder('default');
% ColorList = ColorList1([1 5 4 2],:);
% StrLineList = {'-','--','-.','-.'};
% ColorList = ColorList1([5 3 1 2],:);
% StrLineList = {'-','--','-','-.'};
ColorList = ColorList1([1 5 4 3 ],:);
StrLineList = {'-','--','-.','--'};



for nType = 1:length(Param.TypeList)
    GCparam.HLoss.Type = char(Param.TypeList(nType));
    StrLine = '--';
    SwHL = 1;
    Param.CmprsHlthList = [1, 0.5, 0];
    if strcmp(GCparam.HLoss.Type,'NH') == 1
        SwHL = 0;
        Param.CmprsHlthList = 1;
    end

    for nfc =  nTargetfcList  %%%%%
        fc = Param.fcList(nfc);
        SndOrig = sin(2*pi*fc*(0:Tsnd*fs-1)/fs);
        TW = TaperWindow(length(SndOrig),'han',0.005*fs); % 5ms taper
        SndOrig = [zz, TW(:)'.*SndOrig, zz];
        
        Tsnd = length(SndOrig)/fs;
        disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);
        
        for nCmprsHlth = 1:length(Param.CmprsHlthList)
            CmprsHlth = Param.CmprsHlthList(nCmprsHlth);
            StrLine = char(StrLineList(nCmprsHlth));
            

            for nSPL = 1:length(Param.SPLdBlist)
                SPLdB = Param.SPLdBlist(nSPL);
                Snd =  Eqlz2MeddisHCLevel(SndOrig,SPLdB);
                
                GCparam.HLoss.CompressionHealth = CmprsHlth; %
                
                %%%% GCFB exec %%%%
                tic
                [cGCframe, pGCframe,GCparamOut,GCresp] = GCFBv231(Snd,GCparam);
                tm = toc;
                disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
                    num2str(tm/Tsnd,4) ' times RealTime.']);
                disp(' ');
                
                % 20*log10(max(max(cGCframe)))
                figure(1);
                subplot(3,4,nSPL)
                [~, nChFr1] = min(abs(fc-GCresp.Fr1));
                nRange = max(1,min(100,nChFr1+(-5:10)));
                MeancGCframedB = 20*log10(mean(cGCframe,2));
                MeancGCframedB = MeancGCframedB + GCparamOut.MeddisIHCLevel_RMS0dB_SPLdB; % MeddisIHCの補正
                [MaxGCframedB(nSPL), nCh1] =  max(MeancGCframedB(nRange)); %　excitation pattenの最大値
                nChPeak = nRange(nCh1);  %範囲内の最大ch
                plot(1:GCparam.NumCh, MeancGCframedB,nChPeak*[1 1],MaxGCframedB(nSPL)+[-20 20])
                xlabel('Channel');
                ylabel('Level (dB)');
                axis([0 100 -60 80]);
                drawnow
            end
            
            figure(2);
            if length(nTargetfcList) >= 7
                subplot(4,2,nfc);
            else
                subplot(2,3,nfc-min(nTargetfcList)+1);
            end
            if strcmp(GCparam.HLoss.Type,'NH') == 1
                n100dB = find(Param.SPLdBlist==100);
                plot([0 100], MaxGCframedB(n100dB) - [100 0],'k:' ,[-10 110],[0 0],'k-')
                hold on;
                Rslt.HL0Cch(nfc) = HL2PinCochlea(fc,0);
                plot(Rslt.HL0Cch(nfc), 0, 'k^');
                plot(Rslt.HL0Cch(nfc)*[1 1], [-5 4], 'k:');
                % text(Rslt.HL0Cch(nfc),5,['HL0@C='  num2str(Rslt.HL0Cch(nfc))],'Rotation',90);
                text(Rslt.HL0Cch(nfc),5,['HL 0 dB'],'Rotation',90); 
            end
            plot(Param.SPLdBlist,MaxGCframedB, char(StrLineList(nCmprsHlth+SwHL)),'Color',ColorList(nCmprsHlth+SwHL,:))
            % NG  plot(Param.SPLdBlist,MaxGCframedB-valATHLval(nfc), StrLine, [0 100], [0 100]-50,'k:' ,[-10 110],[0 0],'k-')
            % NG plot(Param.SPLdBlist,MaxGCframedB, StrLine, [0 100], [0 100]-50,'k:',[-10 110],[0 0],'k-')            
            axis([-5 105 -20 60]);
            %axis([-45 105 -100 60]);  %%% <--- 
            set(gca,'XTick', [0:20:100]);
            set(gca,'YTick', [-100:10:100]);
            % grid on;
            hold on;
            xlabel(StrXlabel);
            ylabel('Output re. Abs. Thrsh. (dB)');
            title([GCparamOut.HLoss.Type  ':  ' int2str(fc) ' (Hz) '],'interpreter','none');
            
            Rslt.GCIOfunc(nType,nfc,nCmprsHlth,:) = MaxGCframedB;
            % Rslt.HLxMaxGC(nType,nfc,nCmprsHlth) = interp1(MaxGCframedB,Param.SPLdBlist,0);
            Rslt.AbsThrVal(nType,nfc,nCmprsHlth) = interp1(MaxGCframedB,Param.SPLdBlist,0);
            
            Rslt.HLxCch(nfc) = Rslt.HL0Cch(nfc) + GCparamOut.HLoss.HearingLeveldB(nfc);
            Rslt.DiffHLx(nType,nfc,nCmprsHlth) = Rslt.AbsThrVal(nType,nfc,nCmprsHlth) - Rslt.HLxCch(nfc);

            if CmprsHlth == 1  % 書くのは最初の一回で十分
                if  mean(Rslt.HL0Cch(nfc)-Rslt.HLxCch(nfc)) ~= 0  % 同じ時は書く必要なし == HL0と同じ値
                    plot(Rslt.HLxCch(nfc), 0, 'ko');
                    plot(Rslt.HLxCch(nfc)*[1 1], [-5 19], 'k:');
                    %                    text(Rslt.HLxCch(nfc),21,['HLx@C='  num2str(Rslt.HLxCch(nfc))],'Rotation',90);
                    text(Rslt.HLxCch(nfc),21,['HL ' int2str(GCparamOut.HLoss.HearingLeveldB(nfc)) ' dB'],'Rotation',90);
                else
                    text(60,55, [int2str(fc) ' Hz']);
                    % text(50,55, [int2str(fc) ' Hz'],'HorizontalAlignment','center');
                end
            end
        end
        % GCparamOut.HLoss.FB_PinLossdB_OHC
        % GCparamOut.HLoss.FB_PinLossdB_IHC
    end
    % [Rslt.DiffHLx(nfc,nCmprsHlth); GCparamOut.HLoss.HLval_PinCochleadB; GCparamOut.HLoss.AFgainCmpnstdB ]
    
    Rslt.Param = Param;
    NameFig = [DirFig 'Fig_IOfunc_ExctPtn_' GCparamOut.HLoss.Type StrOMC];
    save(NameFig,'Rslt');
    
end

%% plot all
if length(nTargetfcList) >= 7
    printi(3,0,[2,2,25,40]);
else
    printi(3,0,[2,2,25,14]);
    try ReSubPlot(2,3,0); end  % for paper
end
print(NameFig,'-depsc','-tiff');


