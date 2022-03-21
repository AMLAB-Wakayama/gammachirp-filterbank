%
%       Calculate Absolute threshold by Compression Health  GCFBv231  for  WHIS_GUI
%       IRINO T.
%       Created:   11 Oct 2021  from PlotIOfunc_GCFBv231.m
%       Modified:  11 Oct 2021  v231
%       Modified:  27 Jan 2022  v231 minor change StartupGCFB;
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
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

GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
GCparam.DynHPAF.StrPrc = 'frame-base';

Param.fcList = [125 250 500 1000 2000 4000 8000];
nTargetfcList = 1:length(Param.fcList);
%nTargetfcList = [6];
Param.SPLdBlist = [0:5:100];

Param.TypeList = {'NH'};  %NHをreferenceとしてplot
Param.CmprsHlthList = [1, 2/3, 0.5, 1/3, 0];
%    Param.CmprsHlthList = [1, 0.5, 0];
    % Param.CmprsHlthList = [0.5];

% sound condition
Tsnd = 0.25; % sec  silenceの分を長めにとって影響を少なくする。
zz = zeros(1,0.050*fs);  % 50 ms silence


for nType = 1:length(Param.TypeList)
    GCparam.HLoss.Type = char(Param.TypeList(nType));
    StrLine = '--';
    SwHL = 1;
    
    for nfc =  nTargetfcList  %%%%%
        fc = Param.fcList(nfc);
        SndOrig = sin(2*pi*fc*(0:Tsnd*fs-1)/fs);
        TW = TaperWindow(length(SndOrig),'han',0.005*fs); % 5ms taper
        SndOrig = [zz, TW(:)'.*SndOrig, zz];
        
        Tsnd = length(SndOrig)/fs;
        disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);
        
        for nCmprsHlth = 1:length(Param.CmprsHlthList)
            CmprsHlth = Param.CmprsHlthList(nCmprsHlth);
            
            for nSPL = 1:length(Param.SPLdBlist)
                SPLdB = Param.SPLdBlist(nSPL);
                Snd =  Eqlz2MeddisHCLevel(SndOrig,SPLdB);
                
                GCparam.HLoss.CompressionHealth = CmprsHlth; %
                
                %%%% GCFB exec %%%%
                tic
                [cGCframe, pGCframe,GCparamOut,GCresp] = GCFBv23x(Snd,GCparam);
                tm = toc;
                disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
                    num2str(tm/Tsnd,4) ' times RealTime.']);
                disp(' ');
                
                % 20*log10(max(max(cGCframe)))
                figure(1);              
                % subplot(3,4,nSPL)
                subplot(4,6,nSPL)
                [~, nChFr1] = min(abs(fc-GCresp.Fr1));
                nRange = max(1,min(100,nChFr1+(-5:10)));
                MeancGCframedB = 20*log10(mean(cGCframe,2));
                MeancGCframedB = MeancGCframedB + GCparamOut.MeddisHCLevel_RMS0dB_SPLdB; % MeddisHCの補正
                % MeancGCframedB = MeancGCframedB + LossdBConst; % もとに戻す分
                [MaxGCframedB(nSPL), nCh1] =  max(MeancGCframedB(nRange)); %　excitation pattenの最大値
                nChPeak = nRange(nCh1);  %範囲内の最大ch
                plot(1:GCparam.NumCh, MeancGCframedB,nChPeak*[1 1],MaxGCframedB(nSPL)+[-20 20])
                xlabel('Channel');
                ylabel('Level (dB)');
                axis([0 100 -60 80]);
                drawnow
            end
            
            GCparamOut.HLoss.HLval_PinCochleadB 
            GCparamOut.HLoss.PinLossdB_ACT        
            GCparamOut.HLoss.PinLossdB_PAS         
            
            figure(2);
            subplot(4,2,nfc);
            if strcmp(GCparam.HLoss.Type,'NH') == 1
                n100dB = find(Param.SPLdBlist==100);
                plot([0 100], MaxGCframedB(n100dB) - [100 0],'k:' ,[-10 110],[0 0],'k-')
                if CmprsHlth == 1
                    MaxGCframedB_CH1 = MaxGCframedB(n100dB);
                    Diff_MaxGCframedB_CH1 = 0;
                else
                    Diff_MaxGCframedB_CH1 = MaxGCframedB(n100dB)-MaxGCframedB_CH1;
                end
                hold on;
                Rslt.HL0Cch(nfc) = HL2PinCochlea(fc,0);
                plot(Rslt.HL0Cch(nfc), 0, 'k^');
                plot(Rslt.HL0Cch(nfc)*[1 1], [-5 4], 'k:');
                % text(Rslt.HL0Cch(nfc),5,['HL0@C='  num2str(Rslt.HL0Cch(nfc))],'Rotation',90);
                text(Rslt.HL0Cch(nfc),5,['HL 0 dB'],'Rotation',90);
            end
            
            OutputLevel = MaxGCframedB-Diff_MaxGCframedB_CH1;
            Rslt.AbsThrVal(nfc,nCmprsHlth) = interp1(OutputLevel,Param.SPLdBlist,0);
            plot(Param.SPLdBlist,OutputLevel)
            axis([-5 105 -20 60]);
            set(gca,'XTick', [0:10:100]);
            set(gca,'YTick', [-100:10:100]);
            grid on;
            hold on;
            xlabel('Cochlear Input (dB)');
            ylabel('Output re. Abs. Thrsh. (dB)');
            title([GCparamOut.HLoss.Type  ':  ' int2str(fc) ' (Hz) '],'interpreter','none');
            
            Rslt.GCIOfunc(nfc,nCmprsHlth,:) = MaxGCframedB;
            
            
        end % for nCmprsHlth = 1:length(Param.CmprsHlthList)
        % GCparamOut.HLoss.FB_PinLossdB_ACT
        % GCparamOut.HLoss.FB_PinLossdB_PAS
        
    end %  nfc =  nTargetfcList  %%%%%
    
    
end

Rslt.AbsThrVal

Rslt.Param = Param;
NameFig = [DirFig '/Fig_IOfunc_ExctPtn_AbsThr_' GCparamOut.HLoss.Type];
save(NameFig ,'Rslt');
printi(2,0);
print(NameFig,'-depsc','-tiff');


