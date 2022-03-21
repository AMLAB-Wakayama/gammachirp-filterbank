%
%       Show Bandwidth of GCFBv233 as a function of Compression Health
%       Toshio IRINO
%       Created:   24 Oct 2021  (from testGCFBv231)
%       Modified:  24 Oct 2021
%       Modified:     8 Nov 2021
%       Modified:  27 Jan 2022  v231 minor change StartupGCFB;
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
%
%        Note: Compression health  (==  OHC health : non-use anymore)
%
clear
close all
% close all

% startup directory setting
StartupGCFB;

%%%% Stimuli : a simple pulse train %%%%
fs = 48000;
Tp = 0.20; % = 200 (ms) 100 Hz pulse train
Snd = [zeros(1,100), 1, zeros(1,Tp*fs-1)];
LenSnd = length(Snd);
Tsnd = LenSnd/fs;

SigSPL = 60; % any level is all right --- just looking into the linear filter
Snd =  Eqlz2MeddisHCLevel(Snd,SigSPL);

%%%% GCFB %%%%
GCparam = []; % reset all
GCparam.fs     = fs;
GCparam.NumCh  = 100;
GCparam.FRange = [100, 8000];
GCparam.FRange = [100, 12000];

GCparam.OutMidCrct = 'No';
GCparam.Ctrl = 'dynamic';
GCparam.DynHPAF.StrPrc = 'frame-base';
% GCparam.DynHPAF.StrPrc = 'sample';
Marker1 = {'x-','*-','o--','^--'};

Fr1queryList = [1000 4000];
for nFr1query = 1:length(Fr1queryList) % for comfirmation of none-freq-dependency
    Fr1query = Fr1queryList(nFr1query);
    figure(1)
    GCparam.HLoss.Type = 'NH';
    [dcGCframe, scGCsmpl,GCparam,GCresp] = GCFBv23x(Snd,GCparam);
    [dummy, nChFr1] = min(abs(GCparam.Fr1-Fr1query));
    [ERBw, Fpeak, BW_3dB, BW_10dB] =  Filter2ERB(scGCsmpl(nChFr1,:),fs);
    ERBw_NH = ERBw;
    Fpeak_NH = Fpeak;
    [ERBNrate, ERBNwidth] = Freq2ERB(Fr1query);

    GCparam.HLoss.Type = 'HL0'; % manual setting
    GCparam.HLoss.HearingLeveldB = 50*ones(1,7); % 50 dB  does not to limit the compression health
    CmprsHlthList = [0:0.2:1];  % Compression health 
    for nCmprsHlth = 1:length(CmprsHlthList)
        GCparam.HLoss.CompressionHealth = CmprsHlthList(nCmprsHlth);
        [dcGCframeHL, scGCsmplHL,GCparamHL,GCrespHL] = GCFBv23x(Snd,GCparam);
        [ERBw, Fpeak, BW_3dB, BW_10dB] =  Filter2ERB(scGCsmplHL(nChFr1,:),fs);
        ERBw_HL(nCmprsHlth) = ERBw;
        Fpeak_HL(nCmprsHlth)  = Fpeak;
    end

    ERBw_HL
    figure(2)
    nM = (nFr1query-1)*2+1;
    plot (CmprsHlthList, ERBw_HL./ERBw_NH,char(Marker1(nM)), ...
        CmprsHlthList, ERBw_HL./ERBNwidth,char(Marker1(nM+1)));
    %  ...    CmprsHlthList, Fpeak_HL./Fpeak_NH,'x-.')
    xlabel('Compression health \alpha')
    ylabel('Relative bandwidth')
    grid on
    legend('ERBw re. ERBw_{GC-NH}','ERBw re. ERBw_N'); %' ,'interpreter','none')
    hold on

end
legend('ERBw/ERBw_{GC-NH} (1kHz)','ERBw/ERBw_N (1kHz)','ERBw/ERBw_{GC-NH} (4kHz)','ERBw/ERBw_N (4kHz)'); %' ,'interpreter','none')

NameFig = ['./Fig/Fig_Bandwidth_CmprsHealth'];
printi(3,0,0.8);
print(NameFig,'-depsc','-tiff');

