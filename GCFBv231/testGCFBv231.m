%
%       Test GCFBv230 (for GCFBpack)
%       Toshio IRINO
%       Created:   22 May 2020 (for v230)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  22 May 2020  (v230, introduction of GC Hearing Loss)
%       Modified:  21 Jan 2021  (v230)
%       Modified:  25 Jan 2021  (v230)
%       Modified:  10 Feb 2021  (v230, introduction of GCFBv230_EnvModLoss)
%       Modified:  28 Aug 2021 v231
%       Modified:   2 Sep 2021 v231
%
%
clear
% close all

% startup directory setting
StartupGCFB

%%%% Stimuli : a simple pulse train %%%%
fs = 48000;
Tp = 0.020; % = 10 (ms) 100 Hz pulse train
Snd1 = [1, zeros(1,Tp*fs-1)];
Snd1 = [zeros(1,100), 1, zeros(1,Tp*fs-1)];
Snd = [];
Tsnd = 0.1; % sec
Tsnd = 0.2; % sec
%Tsnd = 1; % sec

for nnn = 1:Tsnd/Tp,
    %for nnn = 1:3,
    Snd = [Snd1 Snd];
end
rng(123);
Snd = randn(1,Tsnd*fs);

LenSnd = length(Snd);
Tsnd = LenSnd/fs;
disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);

SigSPList = [40:20:80];
SigSPList = [60];


cnt = 0;
for SwDySt =  1%:2 % 1 % only dynamic
    %figure(SwDySt);
    
    for SwSPL = 1:length(SigSPList)
        figure(SwSPL)
        cnt = cnt+1;
        SigSPL = SigSPList(SwSPL);
        Snd =  Eqlz2MeddisHCLevel(Snd,SigSPL);
        
        %%%% GCFB %%%%
        GCparam = []; % reset all
        GCparam.fs     = fs;
        GCparam.NumCh  = 100;
        GCparam.FRange = [100, 6000];
        
        %GCparam.OutMidCrct = 'No';
        GCparam.OutMidCrct = 'ELC';
        GCparam.OutMidCrct = 'FreeField';
        
        if SwDySt == 1, GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
        else    GCparam.Ctrl = 'static'; % or 'fixed'
        end;
        
        GCparam.DynHPAF.StrPrc = 'frame-base';
        % GCparam.DynHPAF.StrPrc = 'sample';
        
        GCparam.HLoss.Type = 'NH';
        [dcGCframe, scGCsmpl,GCparam,GCresp] = GCFBv231(Snd,GCparam);

        % GCparam.HLoss.Type = 'HL0'; % manual setting
        %GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 12 28 39] +5;  % HL4+5dB
        GCparam.HLoss.Type = 'HL3';
        GCparam.HLoss.CompressionHealth = 0.5;
        tic
        [dcGCframeHL, scGCsmplHL,GCparamHL,GCrespHL] = GCFBv231(Snd,GCparam);
        % GCparamHL.HLoss.Type
        % GCparamHL.HLoss.HearingLeveldB
        tm = toc;
        disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' num2str(tm/Tsnd,4) ' times RealTime.']);
        disp(' ');
        cnt = cnt+1;
        Telapse(cnt) = tm;
        
        %% %%%%%%
        % Reduction of TMTF
        %%%%%%%%
        EMparam = [];
        EMparam.ReducedB = 5;
        EMparam.Fcutoff = 128;
        [GCEMLoss, EMparam] = GCFBv231_EnvModLoss(dcGCframeHL,GCparam,EMparam);
        Telapse_rdct(cnt) = toc;
        
        %% %%%%%
        % Analysis of modulation filterbank
        %%%%%%%%
        [GCEMframe, AnaEMparam] = GCFBv231_AnaEnvMod(dcGCframeHL,GCparam);
        
        
        %%%%%%%%
        %% Plot results
        %%%%%%%%
        amp = 200;
        subplot(3,1,1)
        image(amp*max(dcGCframe,0));
        set(gca,'YDir','normal');
        title(['NH SPL = ' int2str(SigSPL) ' (dB)'])
        
        subplot(3,1,2)
        image(amp*max(dcGCframeHL,0));
        set(gca,'YDir','normal');
        title(GCparamHL.HLoss.Type,'interpreter','none')

        subplot(3,1,3)
        image(amp*max(GCEMLoss,0));
        set(gca,'YDir','normal');
        title([GCparamHL.HLoss.Type ' + TMTF reduction '],'interpreter','none')
   
    end;
end;    
        
nf = gcf;
figure(nf.Number+1)
cnt = 0;
for nSlice = [100:50:250],
    cnt = cnt +1;
    subplot(2,2,cnt);
    
    nchAll = 1:GCparam.NumCh;
    plot(nchAll, dcGCframe(nchAll,nSlice),nchAll, dcGCframeHL(nchAll,nSlice),'--',nchAll, GCEMLoss(nchAll,nSlice),'-.');
end;


