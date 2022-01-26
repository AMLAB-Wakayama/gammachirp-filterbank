%
%      Test GCFBv211 spectrogram (for GCFBpack)
%      Toshio IRINO
%      Created:    5 Dec 2018   from testGCFBv211.m
%      Modified:   5 Dec 2018  (v211)
%      Modified:   9 Dec 2018  (using CalSmoothSpec.m)
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
        
        %%
        GCFBparam.fs  = fs; % using default. See inside CalSmoothSpec.m for parameters
        [AudSpec GCFBparam] = CalSmoothSpec(max(cGCout,0),GCFBparam);
        
        subplot(length(SigSPLlist),1,SwSPL);
        MaxAudSpec(SwDySt, SwSPL) = max(max(AudSpec));
        disp(MaxAudSpec)
        if SwDySt  == 1
            AmpImg = (64*1.2)/49;  % normalized by max value. It is a data specific value. Please change it.
        else
            AmpImg = (64*1.2)/166;
        end;
        image(AmpImg*AudSpec)
        %  imagesc(AudSpec);
        set(gca,'YDir','normal');
        title(['GCFB control = "' GCparam.Ctrl '";  Signal Level = ' ...
            int2str(SigSPL) ' dB SPL']);
        
        drawnow
    end;
end;



%% %%%%%%%%%%%%%%%%%%%%%
% Trash %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
	% without using %CalSmoothSpec
	%        
	%% Auditory Spectrogram
        % [NumCh, LenGCout] = size(cGCout);
        % cGCrect = max(cGCout,0); % rectified version
        % LenFrame = 0.020*fs;  % 20 ms
        % LenFrameShift = 0.010*fs; % 10 ms
        % WinFunc = hamming(LenFrame);
        % for nch = 1:NumCh
        %     FrameMtrx = SetFrame4TimeSequence(cGCrect(nch,:),LenFrame,LenFrameShift);
        %     AudSpec(nch,:) = WinFunc(:)'*FrameMtrx;
        % end;
        
        
