%
%      Calculation of Smoothed spectrogram (from GCFB)
%      Toshio IRINO
%      Created:    1 Nov 2011
%      Modified:   1 Nov 2011
%      Modified:  20 Feb 2012 % checked
%      Modified:  21 Sep 2014 % checked 
%      Modified:  23 Sep 2014 % introducing Selection of Method 
%
%
%     Example of the usage: 
%         Snd = Snd(:)';
%         Snd = Eqlz2MeddisHCLevel(Snd,GCFBparam.SndSPL);
%         [cGCout, pGCout, GCparam, GCresp] = GCFBv207(Snd,GCparam);
%         
%         or 
%         SmthPwrSpec = CalSmoothSpec(cGCout.^2,GCFBparam);
%
function [SmoothSpec, FBparam] = CalSmoothSpec(FBout,FBparam)

    fs = FBparam.fs;
    if isfield(FBparam,'Method') == 0, 
        FBparam.Method = 1; % default setting
    end;
    
    %% selection of Method
    if FBparam.Method == 1,      % default setting
        FBparam.Tshift  = 0.005; % 5 ms from HTK MFCC
        FBparam.Nshift  = FBparam.Tshift*fs;
        FBparam.Twin    = 0.025; % 25 ms from HTK MFCC
        FBparam.Nwin    = FBparam.Twin*fs;
        FBparam.TypeWin = 'hamming'; % hamming window from HTK MFCC
        
    elseif   FBparam.Method == 2, 
        FBparam.Tshift  = 0.005; % 5 ms 
        FBparam.Nshift  = FBparam.Tshift*fs;
        FBparam.Twin    = 0.010; % 10 ms window size
        FBparam.Nwin    = FBparam.Twin*fs;
        FBparam.TypeWin = 'hanning'; % hanning
    else
        error('Specify FBparam.Method : 1 or 2');
    end;
    eval(['FBparam.Win = ' FBparam.TypeWin '(FBparam.Nwin);']);
    FBparam.Win     = FBparam.Win/sum(FBparam.Win); % Normalized
    FBparam.TypeSmooth = ['Temporal Smoothing with a ' FBparam.TypeWin ' window'];
 
    %% calculation
    [NumCh, LenSnd] = size(FBout);
    for nch = 1:NumCh
       [ValFrame, nSmplPt] = SetFrame4TimeSequence(...
             FBout(nch,:),FBparam.Nwin,FBparam.Nshift);
       if nch == 1,
            LenFrame   = size(ValFrame,2);
            SmoothSpec = zeros(NumCh,LenFrame);
       end;
       ValFrameWin = FBparam.Win(:)'*ValFrame;
       SmoothSpec(nch,:) = ValFrameWin;
    end;

    FBparam.temporalPositions = (0:LenFrame-1)*FBparam.Tshift;
    
return
    
           
 