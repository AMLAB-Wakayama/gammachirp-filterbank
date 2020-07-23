%
%       Frame base processing of HP-AF of dcGCFB
%       Toshio IRINO
%       Created:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:  14 May 2020  (for checking processing speed)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  24 May 2020  (introduction of cGCfxFrame narrow filter)
%
%       See  main  GCFB2xx
%
% Frame Base processing
%     See CalSmoothSpec.m / SetFrame4TimeSequence
%

ExpDecayFrame = GCparam.LvlEst.ExpDecayVal.^(GCparam.DynHPAF.LenShift);

for nch = 1:NumCh
    %%%%%%%%%
    % signal path
    %%%%%%%%%
     pGCoutKeep = pGCout;
    [pGCframeMtrx, nSmplPt] = SetFrame4TimeSequence(...
        pGCout(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    [LenFrame, NumFrame] = size(pGCframeMtrx);
    % cGC level estimation filter -- This BW is narrower than that of pGC.
    % roughly at Pgc == 50
     [cGCfxFrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        cGCoutLvlEst(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    [LenFrame, NumFrame] = size(pGCframeMtrx);
    if nch == 1,
        pGCframe         = zeros(NumCh,NumFrame);
        LvldBFrame      = zeros(NumCh,NumFrame);
        fratFrame         = zeros(NumCh,NumFrame);
        AsymFuncGain = zeros(NumCh,NumFrame);
        cGCframe         = zeros(NumCh,NumFrame);
    end;
        
    pGCframe(nch,1:NumFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(pGCframeMtrx.^2));  % weighted mean
    cGCfxFrame(nch,1:NumFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(cGCfxFrameMtrx.^2));  % weighted mean
    
    %%%%%%%%%
    % level estimation path     %  Level estimation from HIsimFastGC.m  -->  modified
    %%%%%%%%%
    [LvlLin1FrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        pGCout(GCparam.LvlEst.NchLvlEst(nch),:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    LvlLin1Frame = sqrt(GCparam.DynHPAF.ValWin(:)'*(LvlLin1FrameMtrx.^2));  % weighted mean
    
    [ LvlLin2FrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        cGCoutLvlEst(GCparam.LvlEst.NchLvlEst(nch),:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    LvlLin2Frame = sqrt(GCparam.DynHPAF.ValWin(:)'*(LvlLin2FrameMtrx.^2));
    
    for nFrame = 1:NumFrame-1  % Compensation of decay constant, GCparam.LvlEst.ExpDecayVal not in HIsimFastGC.m 
        LvlLin1Frame(nFrame+1) = max(LvlLin1Frame(nFrame+1),  LvlLin1Frame(nFrame)*ExpDecayFrame);
        LvlLin2Frame(nFrame+1) = max(LvlLin2Frame(nFrame+1),  LvlLin2Frame(nFrame)*ExpDecayFrame);
    end;

    LvlLinTtlFrame = GCparam.LvlEst.Weight * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin1Frame/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(1) ...
        + (1 - GCparam.LvlEst.Weight) * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin2Frame/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(2);
    
    CmpnstHalfWaveRectify = -3;   % Halfwave rectification was used in "sample-by-sample."
    LvldBFrame(nch,1:NumFrame) = 20*log10( max(LvlLinTtlFrame,GCparam.LvlEst.LvlLinMinLim) ) ...
        + GCparam.LvlEst.RMStoSPLdB + CmpnstHalfWaveRectify;
    fratFrame(nch,1:NumFrame) = GCparam.frat(1,1) + GCparam.frat(1,2)*GCresp.Ef(nch) + ...
        (GCparam.frat(2,1) + GCparam.frat(2,2)*GCresp.Ef(nch))*LvldBFrame(nch,:);
    
   %%%%%%%%%
    % Gain calculation from the idea in HIsimFastGC.m
    % frat --> Gain   50dB RefdB
    %%%%%%%%%
    %  forigin = GCresp.Fr1(nch); % filter center frequency -- closer than Fp1
    Fp1 = GCresp.Fp1(nch);  % this is from the original definition.  What we wish to know is the gain.
    Fr2  = fratFrame(nch,:) * Fp1; % NH
    [dummy ERBwFr2] = Freq2ERB(Fr2);
    
    AmpNormAFG = 1;   % it is the most simple.    noise case: ErrdB = -5.8 dB  
    %%%  v220Ç≈ÇÕ -- AmpNormAFG = 1.3;   %   pulse train ErrdB = -8.6851 Å@Å@noise case:Å@ErrdB = -5.4127
    AsymFuncGain(nch,1:NumFrame) = ...
        AmpNormAFG*exp(GCresp.c2val(nch)*atan2(Fp1 - Fr2,GCresp.b2val(nch)*ERBwFr2));  
    %AsymFuncGain = min(AsymFuncGain,10); % Limiting maximum is not necessary.   exp(2.2*pi/2)=31

    % cGCframe(nch,1:NumFrame) = AsymFuncGain(nch,:).*pGCframe(nch,:); % The bandwidth is too wide.
    cGCframe(nch,1:NumFrame) = AsymFuncGain(nch,:).*cGCfxFrame(nch,:); % using  fixed cGC filter output. narrower BW
    
    if nch == 1 | rem(nch,20)==0
        disp(['Frame base HP-AF: ch #' num2str(nch) ' / #' num2str(NumCh) ...
            '.    elapsed time = ' num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
    end;
    
end;
cGCout = cGCframe;
pGCout = pGCframe;
GCresp.LvldB = LvldBFrame;
GCresp.frat = fratFrame;
GCresp.AsymFuncGain = AsymFuncGain;

return;

%% %%%%%%%%%%
% Trash
%%%%%%%%%%%%

    % AmpNormAFG = 1/exp(c2val*pi/2); <-- exp(2.2*pi/2)=31 (maximum amlitude)
    % AmpNormAFG = 1; % magic number  ErrdB = -7.82 dB 
    %AmpNormAFG = 1.3; % magic number:   pulse train  ErrdB = -8.96 dB 
    % AmpNormAFG = 1.4; % magic number:    pulse train ErrdB =  -8.67 dB
    % AmpNormAFG = 1.5; % magic number:  pulse train ErrdB =  -8.07 dB
    % AmpNormAFG = 1.28; % magic number  pulse train  ErrdB = -8.99 dB peak matched
