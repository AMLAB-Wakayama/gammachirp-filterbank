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
%       Modified:  27 Jan 2022 v231  using EqlzGCFB2Rms1at0dB for plot
%       Modified:   6  Feb 2022  v231 introducing GCparam.OutMidCrct = 'EarDrum'; 
%       Modified:   6  Mar 2022  v232 modifed EqlzMeddisHCLevel & renamed  GCFBv231_func --> GCFBv23_func 
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
%
%
% clear
% close all

% startup directory setting
StartupGCFB;

[SndSrc, fs] = audioread('Snd_Hello123.wav');
SndSrc = SndSrc(:)'; % row vector
LenSnd = length(SndSrc);
Tsnd = LenSnd/fs;
disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);


SndSPLdBList = [40:20:80];
SndSPLdBList = [60];

SwEqlzMds = 1; % convetional
SwEqlzMds = 2; % new feature

cnt = 0;
for SwDySt =  1%:2 % 1 % only dynamic
    %figure(SwDySt);
    
    for SwSPL = 1:length(SndSPLdBList)
        cnt = cnt+1;
        SndSPLdB = SndSPLdBList(SwSPL);

        if SwEqlzMds == 1
            % You do not need to calibrate the sound level in advance.
            % You'd better use the other one if you know the digital level and SPL.
            SndEqM = Eqlz2MeddisHCLevel(SndSrc,SndSPLdBList);    
        else
            % You need to know the sound level using reference DigitalRms1SPLdB.
            % You can use precise definition of sound level.
            DigitalRms1SPLdB = 90;
            SndDigitalLeveldB = SndSPLdB - DigitalRms1SPLdB;
            SndSrc = 10^(SndDigitalLeveldB/20) * SndSrc/rms(SndSrc);
            SndEqM = Eqlz2MeddisHCLevel(SndSrc,[],DigitalRms1SPLdB);    
        end
        
        %%%% GCFB %%%%
        GCparam = []; % reset all
        GCparam.fs     = fs;
        GCparam.NumCh  = 100;
        GCparam.FRange = [100, 6000];
        
        %GCparam.OutMidCrct = 'No';
        GCparam.OutMidCrct = 'ELC';
        GCparam.OutMidCrct = 'FreeField';
        % GCparam.OutMidCrct = 'EarDrum'; %	introduced  6 Feb 22  
        
        if SwDySt == 1, GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
        else    GCparam.Ctrl = 'static'; % or 'fixed'
        end
        
        GCparam.DynHPAF.StrPrc = 'frame-base';
        % GCparam.DynHPAF.StrPrc = 'sample';
        
        GCparam.HLoss.Type = 'NH';
        [dcGCframe, scGCsmpl,GCparam,GCresp] = GCFBv233(SndEqM,GCparam);

        % GCparam.HLoss.Type = 'HL0'; % manual setting
        %GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 12 28 39] +5;  % HL4+5dB
        GCparam.HLoss.Type = 'HL3';
        GCparam.HLoss.CompressionHealth = 0.5;
        tic
        [dcGCframeHL, scGCsmplHL,GCparamHL,GCrespHL] = GCFBv23x(SndEqM,GCparam);

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
        [GCEMLoss, EMparam] = GCFBv23_EnvModLoss(dcGCframeHL,GCparam,EMparam);
        Telapse_rdct(cnt) = toc;
        
        %% %%%%%
        % Analysis of modulation filterbank
        %%%%%%%%
        [GCEMframe, AnaEMparam] = GCFBv23_AnaEnvMod(dcGCframeHL,GCparam);
        

        %%%%%%%%
        %% Plot results
        %%%%%%%
        figure;
        % normazliation  (rms 1 == 0dB )  relative to Absolute threshold 0dB
        dcGCframe     = EqlzGCFB2Rms1at0dB(dcGCframe);  
        dcGCframeHL = EqlzGCFB2Rms1at0dB(dcGCframeHL);  
        GCEMLoss = EqlzGCFB2Rms1at0dB(GCEMLoss);

        amp = 6;
        subplot(3,1,1)
        image(amp*dcGCframe);
        set(gca,'YDir','normal');
        title(['NH SPL = ' int2str(SndSPLdB) ' (dB)'])
        
        subplot(3,1,2)
        image(amp*dcGCframeHL);
        set(gca,'YDir','normal');
        title(GCparamHL.HLoss.Type,'interpreter','none')

        subplot(3,1,3)
        image(amp*GCEMLoss);
        set(gca,'YDir','normal');
        title([GCparamHL.HLoss.Type ' + TMTF reduction '],'interpreter','none')
        drawnow

    end
end
        
nf = gcf;
figure(nf.Number+1)
cnt = 0;
for nSlice = [100:50:250]
    cnt = cnt +1;
    subplot(2,2,cnt);
    
    nchAll = 1:GCparam.NumCh;
    plot(nchAll, dcGCframe(nchAll,nSlice),nchAll, dcGCframeHL(nchAll,nSlice),'--',nchAll, GCEMLoss(nchAll,nSlice),'-.');
end



%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%

%%%% Stimuli : a simple pulse train %%%%
% This is an example of conventional method of Eqlz2MeddisHCLevel
%
% Tp = 0.020; % = 10 (ms) 100 Hz pulse train
% Snd1 = [1, zeros(1,Tp*fs-1)];
% Snd1 = [zeros(1,100), 1, zeros(1,Tp*fs-1)];
% Snd = [];
% Tsnd = 0.1; % sec
% Tsnd = 0.2; % sec
% %Tsnd = 1; % sec
% 
% for nnn = 1:Tsnd/Tp,
%     %for nnn = 1:3,
%     Snd = [Snd1 Snd];
% end
% rng(123);
% Snd = randn(1,Tsnd*fs);
% 
% 

