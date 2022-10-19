%
%       Frame-based processing of HP-AF of dcGCFB
%       Toshio IRINO
%       Created:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:  14 May 2020  (for checking processing speed)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  24 May 2020  (introduction of cGCfxFrame narrow filter)
%       Modified:  26 Jul 2020  (v230, modified some comments)
%       Modified:  27 Feb 2021  (v230, fucntion)
%       Modified:  13 Aug 2021 (v230, 3rd output argument pGCframe -->  scGCframe)
%       Modified:  15 Aug 2021 (v230,AmpNormAFG using GCparam.IOfuncPinEqPoutdB)
%       Modified:  17 Aug 2021  (v230, output modified , GCresp.LvldBframe, GCresp.pGCframe, GCresp.scGCframe, )
%       Modified:  28 Aug 2021  v231 no change in function
%       Modified:   3 Sep  2021  v231 some tests
%       Modified:  17 Sep 2021  renamed NumFrame --> LenFrame,  LenFrame--> LenWin  as  defined in SetFrame4TimeSequence
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       
%
% function [dcGCframe, GCresp] = GCFBv230_FrameBase(pGCsmpl, scGCsmpl, GCparam, GCresp)
%      INPUT:  pGCsmpl:    passive GC sample
%                   scGCsmpl:  static cGC sample
%                   GCparam: 
%                   GCresp:
%
%      OUTPUT: 
%              dcGCframe:  frame level output of dcGC-FB
%              GCresp : 
%              pGCframe:  frame level output of pGC-FB
%              scGCframe:  frame level output of static compressive GC-FB
%
% Frame-based processing
%     See CalSmoothSpec.m / SetFrame4TimeSequence
%
function [dcGCframe, GCresp] = GCFBv23_FrameBase(pGCsmpl, scGCsmpl, GCparam, GCresp)

ExpDecayFrame = GCparam.LvlEst.ExpDecayVal.^(GCparam.DynHPAF.LenShift);
[NumCh, LenSnd] = size(pGCsmpl);
disp('--- Frame base processing ---');
Tstart = clock;

NfrqRsl = 1024*2;  % normalization用に周波数特性を算出しておく
c2val_CmprsHlth = GCparam.HLoss.FB_CompressionHealth.* GCparam.LvlEst.c2;
scGCresp = CmprsGCFrsp(GCparam.Fr1,GCparam.fs,GCparam.n,GCresp.b1val,GCresp.c1val, ...
                                        GCparam.LvlEst.frat,GCparam.LvlEst.b2,c2val_CmprsHlth,NfrqRsl);

    
for nch = 1:NumCh
    %%%%%%%%%
    % signal path
    %%%%%%%%%
    % pGC only
    [pGCframeMtrx, nSmplPt] = SetFrame4TimeSequence(...
        pGCsmpl(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    [LenWin, LenFrame] = size(pGCframeMtrx);
    % cGC level estimation filter -- This BW is narrower than that of pGC.
    % roughly at Pgc == 50
     [scGCframeMtrx, nSmplPt] = SetFrame4TimeSequence(...
        scGCsmpl(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    % [LenWin, LenFrame] = size(scGCframeMtrx);
    if nch == 1,
        pGCframe         = zeros(NumCh,LenFrame);
        LvldBframe      = zeros(NumCh,LenFrame);
        fratFrame         = zeros(NumCh,LenFrame);
        AsymFuncGain = zeros(NumCh,LenFrame);
        dcGCframe         = zeros(NumCh,LenFrame);
    end;
    
    pGCframe(nch,1:LenFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(pGCframeMtrx.^2));  % weighted mean
    scGCframe(nch,1:LenFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(scGCframeMtrx.^2));  % weighted mean
   
    %%%%%%%%%
    % level estimation path     %  Level estimation from HIsimFastGC.m  -->  modified
    %%%%%%%%%
    [LvlLin1FrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        pGCsmpl(GCparam.LvlEst.NchLvlEst(nch),:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    LvlLin1Frame = sqrt(GCparam.DynHPAF.ValWin(:)'*(LvlLin1FrameMtrx.^2));  % weighted mean
    
    [ LvlLin2FrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        scGCsmpl(GCparam.LvlEst.NchLvlEst(nch),:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    LvlLin2Frame = sqrt(GCparam.DynHPAF.ValWin(:)'*(LvlLin2FrameMtrx.^2));
    
    for nFrame = 1:LenFrame-1  % Compensation of decay constant, GCparam.LvlEst.ExpDecayVal not in HIsimFastGC.m 
        LvlLin1Frame(nFrame+1) = max(LvlLin1Frame(nFrame+1),  LvlLin1Frame(nFrame)*ExpDecayFrame);
        LvlLin2Frame(nFrame+1) = max(LvlLin2Frame(nFrame+1),  LvlLin2Frame(nFrame)*ExpDecayFrame);
    end;
    
    LvlLinTtlFrame = GCparam.LvlEst.Weight * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin1Frame/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(1) ...
        + (1 - GCparam.LvlEst.Weight) * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin2Frame/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(2);
    
    % level monitored 4 Sep 2021　　--- 特に変ではなかった。

    CmpnstHalfWaveRectify = -3;      % Cmpensation of  a halfwave rectification which was used in "sample-by-sample."
    LvldBframe(nch,1:LenFrame) = 20*log10( max(LvlLinTtlFrame,GCparam.LvlEst.LvlLinMinLim) ) ...
        + GCparam.LvlEst.RMStoSPLdB + CmpnstHalfWaveRectify;     % GCparam.LvlEst.RMStoSPLdB == 30 dB Meddis HC level
    
    [AFoutdB, IOfuncdB, GCparam] = GCFBv23_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
                       GCparam.HLoss.FB_CompressionHealth(nch), LvldBframe(nch,:));
    AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB)/20);  % default
         
    scGCframe1 = scGCresp.NormFctFp2(nch) * scGCframe(nch,:); 
    % normalization:  scGCframeのpeakが周波数に関わらず0dBとなるように 5 Sep 21
    % 周波数応答で、Fp2がmaxとなる（そのような周波数をFp2)。そのpeakを一定にする。Fr1と異なるが、近いのでよしとする。
    % GammaChirp.mのやり方を踏襲　26 Aug 21
    %  plot(20*log10(scGCresp.NormFctFp2)) --  -3 dB ~ + 1 dB　たいした補正量ではない。
    
    dcGCframe(nch,1:LenFrame) = AsymFuncGain(nch,:) .*scGCframe1;
    
    if nch == 1 || rem(nch,20)==0
        disp(['Frame-based HP-AF: ch #' num2str(nch) ' / #' num2str(NumCh) ...
            '.    elapsed time = ' num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
        
       %% DEBUG_MODE
       % Level estimationに関しては問題なし。ーー　確認　28 Aug 2021
       % [nch mean(LvldBframe(nch,:)), max(LvldBframe(nch,:))]
       % plot( LvldBframe(nch,:) )
       %
    end
    
end

% Data 引き渡し用
GCresp.LvldBframe = LvldBframe; % Level情報はここに入っている。
GCresp.pGCframe   = pGCframe;   % pGCframe
GCresp.scGCframe  = scGCframe;  % scGCframe
GCresp.fratFrame   = fratFrame;
GCresp.AsymFuncGain = AsymFuncGain;

return;


