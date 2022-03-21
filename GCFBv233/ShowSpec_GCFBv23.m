%
%       Show example Spectrogram  using GCFBv231
%       Toshio IRINO
%       Created:   20 Jan 2022 from testGCFBv231
%       Modified:  20 Jan 2022 
%       Modified:  27 Jan 2022  using EqlzGCFB2Rms1at0dB
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
%
%
clear
% close all
DirProg = fileparts(which(mfilename)); % Directory of this program
DirFig = [DirProg '/Fig/'];

% startup directory setting
StartupGCFB;
[Snd,fs] = audioread('Snd_Hello123.wav');

LenSnd = length(Snd);
Tsnd = LenSnd/fs;
disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);

GCparam = []; % reset all
GCparam.fs     = fs;
GCparam.NumCh  = 100;
GCparam.FRange = [100, 6000];

%GCparam.OutMidCrct = 'No';
% GCparam.OutMidCrct = 'ELC';
GCparam.OutMidCrct = 'FreeField';

GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
GCparam.DynHPAF.StrPrc = 'frame-base';


SigSPL = 65;
Snd =  Eqlz2MeddisHCLevel(Snd(:)',SigSPL);  % normalization:  conventional version is all right.
CompressionHealth = 0.5;
%CompressionHealth = 1;
CompressionHealth = 0;

for SwNHHL = [1:3]
    %%%% GCFB %%%%

    if SwNHHL == 1
        GCparam.HLoss.Type = 'NH';
    elseif SwNHHL == 2
        GCparam.HLoss.Type = 'HL3';  %70 yr
        GCparam.HLoss.CompressionHealth = CompressionHealth; 
    elseif SwNHHL == 3
        GCparam.HLoss.Type = 'HL2'; % 80yr
        GCparam.HLoss.CompressionHealth = CompressionHealth;
    else 
        % GCparam.HLoss.Type = 'HL0'; % manual setting
        %GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 12 28 39] +5;  % HL4+5dB
    end
    tic
    [dcGCframe, scGCsmpl,GCparam,GCresp] = GCFBv23x(Snd,GCparam);
    tm = toc;
    disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' num2str(tm/Tsnd,4) ' times RealTime.']);
    disp(' ');
    disp(['Compression health: ' sprintf('%5.3f, ', GCparam.HLoss.CompressionHealth)]);
    MeanCompressionHealth =  mean(GCparam.HLoss.CompressionHealth);
    disp(['Mean(CompressionHealth) = ' num2str(round(MeanCompressionHealth*100)/100)]);

    %%%%%%%%
    %% GCFB re. absolute threshold 0dB --> rms 1
    %%%%%%%
    % StrFloor = 'NoiseFloor'; 
    StrFloor = 'ZeroFloor';
    GCoutReAT = EqlzGCFB2Rms1at0dB(dcGCframe,StrFloor);

    %%%%%%%%
    %% Plot results
    %%%%%%%%
    [NumCh,LenFrame] = size(GCoutReAT);
    tms = (0:LenFrame-1)/GCparam.DynHPAF.fs; % 
    if SwNHHL == 1
        subplot(4,1,1)
        plot((0:LenSnd-1)/fs,Snd);  % waveform
        xlabel('Time (sec)')
        ylabel('Amp.')
    end
    subplot(4,1,SwNHHL+1)
    AmpImg = 15;
    image(tms, 1:NumCh, AmpImg*GCoutReAT);
    xlabel('Time (sec)')
    ylabel('Channel')
    set(gca,'YDir','normal');
    str = [GCparam.HLoss.Type ', SPL = ' int2str(SigSPL) ' (dB)'];
    text(0.1,90, str,'interpreter','none','color','white');

end

try
    ReSubPlot(4,1,0); % cleanup subplot (not provided)
end
NameFig = [DirFig '/Fig_SpecExample_NH70yr80yr_OH' ...
    int2str(MeanCompressionHealth*100)];
printi(3,0,1.2);
% print(NameFig,'-depsc','-tiff'); % heavy for ppt
print(NameFig,'-dpng'); 

