%
%      Test GCFBv211 spectrogram (for GCFBpack)
%      Toshio IRINO
%      Created:    5 Dec 2018   from testGCFBv211.m
%      Modified:    5 Dec 2018  (v211)
%
%
clear
close all

%%%% Stimuli : a simple pulse train %%%%
fs = 48000;
SigSPLlist = 60;
%
%      Test GCFBv211 (for GCFBpack)
%      Toshio IRINO
%      Created:   15 Sep 2005 (for v205)
%      Modified:   7 Apr 2006 (v206, Compensation of Group delay OutMidCrct)
%      Modified:  23 Dec 2006 (v207, 'dynamic' rather than 'time-varying')
%      Modified:  18 Mar 2007 (check. modifying title)
%      Modified:  25 Jul 2007 (GCresp)
%      Modified:   5 Aug 2007 (Elapsed time)
%      Modified:  26 Jun 2013
%      Modified:  25 Nov 2013 (v209)
%      Modified:  18 Apr 2015 (v210, include GCresp in GCFBv210_SetParam )
%      Modified:  13 May 2015 (v210, debug & comparison)
%      Modified:    5 Dec 2018  (v211,  No software modification in the main. remove 209.)
%
%
clear
close all

Mfn = which(eval('mfilename')); % directory of this m-file
DirSnd= [ fileparts(Mfn) '/'];
NameSnd = 'Snd_konnichiwa.wav';
SigSPLlist = [40 60 80];

cnt = 0;
for SwDySt = [2 1]
    figure(SwDySt);
    
    for SwSPL = 1:length(SigSPLlist)
        SigSPL = SigSPLlist(SwSPL);
        [Snd, fs] = audioread([DirSnd NameSnd]);
        Snd =  Eqlz2MeddisHCLevel(Snd(:)',SigSPL);  % Sound should be a row vector.
        Tsnd = length(Snd)/fs;
        
        %%%% GCFB %%%%
        GCparam = []; % reset all
        GCparam.fs     = fs;
        GCparam.NumCh  = 100;
        GCparam.FRange = [100, 6000];
        
        %GCparam.OutMidCrct = 'No';
        GCparam.OutMidCrct = 'ELC';

        
        if SwDySt == 1, GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
        else    GCparam.Ctrl = 'static'; % or 'fixed'
        end;
        
        tic
        [cGCout, pGCout, GCparam, GCresp] = GCFBv211(Snd,GCparam);
        tm = toc;
        disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
            num2str(tm/Tsnd,4) ' times RealTime.']);
        disp(' ');
        
        %% Auditory Spectrogram
        [NumCh, LenGCout] = size(cGCout);
        cGCrect = max(cGCout,0); % rectified version
        LenFrame = 0.020*fs;  % 20 ms
        LenFrameShift = 0.010*fs; % 10 ms
        WinFunc = hamming(LenFrame);
        for nch = 1:NumCh
            FrameMtrx = SetFrame4TimeSequence(cGCrect(nch,:),LenFrame,LenFrameShift);
            AudSpec(nch,:) = WinFunc(:)'*FrameMtrx;
        end;
        
        subplot(length(SigSPLlist),1,SwSPL);
        MaxAudSpec(SwDySt, SwSPL) = max(max(AudSpec));
        disp(MaxAudSpec)
        if SwDySt  == 1
            AmpImg = (64*1.2)/2.60e4;  % normalized by max value
        else
            AmpImg = (64*1.2)/8.38e4;
        end;
        image(AmpImg*AudSpec)
        %  imagesc(AudSpec);
        set(gca,'YDir','normal');
        title(['GCFB control = "' GCparam.Ctrl '";  Signal Level = ' ...
            int2str(SigSPL) ' dB SPL']);
        
        drawnow
    end;
end;
