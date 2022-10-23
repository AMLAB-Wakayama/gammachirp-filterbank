%
%       Dynamic Compressive Gammachirp Filterbank
%       Toshio IRINO
%       Created:   6 Sep 2003
%       Modified:  7 Jun 2004
%       Modified:  12 Jul 2004  (PpgcEstShiftERB)
%       Modified:  14 Jul 2004  (LinPpgc)
%       Modified:  4  Aug 2004  (introducing GCresp)
%       Modified:  16 Aug 2004  (ExpDecayVal)
%       Modified:  31 Aug 2004  (introducing GCFBv2_SetParam)
%       Modified:  8  Sep 2004 (TTS. tidy up the names. 2.00 -> 2.01)
%       Modified:  10 Sep 2004 (Normalization at Level estimation path)
%       Modified:  7 Oct 2004   (c2val is level dependent 2.02)
%       Modified:  22 Oct 2004  (level estimation  2.03)
%       Modified:  8 Nov 2004   (error detection of SndIn)
%       Modified:  30 Nov 2004  (c2val control)
%       Modified:  23 May 2005  (v205. Pc == average of two input, RMS2dBSPL,
%   			 Fast filtering when 'fix' : under construction)
%       Modified:  24 May 2005  (v205 Mod in LinLvl1 =..., LvldB= ...)
%       Modified:   3 Jun 2005  (v205)
%       Modified:   1 Jun 2005  (v205, GCparam.GainCmpnstdB)
%       Modified:  14 Jul 2005  (v205, GCparam.LvlEst.RefdB, Pwr, Weight)
%       Modified:  15 Sep 2005  (v205, rename GCparam.LvlRefdB --> GainRefdB)
%       Modified:   7 Apr 2006  (v206, Compensation of Group delay OutMidCrct)
%       Modified:  16 Apr 2006  (v206, Minimum phase OutMidCrct: NoGD-cmpnst)
%       Modified:  27 Jun 2006  (v206, GCresp.GainFactor)
%       Modified:  22 Dec 2006  (v207, speed up for 'fix' condition)
%       Modified:   7 Jan 2007  (v207, output GCresp.Fp2 for 'fix' condition)
%       Modified:  19 Jan 2007  (v207, GCparam.Ctrl: 'static'=='fixed')
%       Modified:   5 Aug 2007  (v207, GCresp.GainFactor --> vector)
%       Modified:  19 Dec 2011  (v208, non-sample-by-sample coefficient update)
%       Modified:  18 Dec 2012  (v208, no AF-HP update in Level-estimation path)
%       Modified:  19 Dec 2012  (v208, clean up level-estimation path)
%       Modified:  25 Nov 2013  (v209, checked, Add option 'level-estimate')
%       Modified:   3 Dec 2013  (v209, Add GCparam.LvlEst.* recording)
%       Modified:  29 Jan 2015  (v209, nDisp  = fix(LenSnd/10); % display 10 times per Snd )
%       Modified:  18 Apr 2015  (v209, Check function names)
%       Modified:  18 Apr 2015  (v210, include GCresp in GCFBv210_SetParam )
%       Modified:  26 Apr 2015  (v210, def. LevelScGCFBdB for static cGC, delete tic.)
%       Modified:  23 Jan  2017 (v210,  No version change. Modified GammaChirp.m --- freqz 2^nextpow2() for consistency to C version. (RMS differene is only about 0.03%).)
%       Modified:    5 Dec 2018  (v211,  Just modify the version number without any software modification in the main. )
%       Modified:    6 May 2020  (for checking processing speed, tic/toc comments)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  22 May 2020  (v230, introduction of GC Hearing Loss　 --- See function GCFBv230_HearingLoss)
%       Modified:  24 May 2020  (v230, AbsThreshold == Output 0dB)
%       Modified:  24 Jul  2020   (v230, IO function)
%       Modified:  26 Jul  2020   (v230, modified)
%       Modified:  22 Jan 2021   (v230, NormIOfunc_CmpnstTerm)
%       Modified:  27 Feb 2021  (v230, output modified , dcGCout & scGCsmpl )
%       Modified:  13 Aug 2021  (v230, output modified , [dcGCout, scGCsmpl, GCparam, GCresp, pGCframe, scGCframe] )
%       Modified:  17 Aug 2021  (v230, output modified , GCresp.pGCframe, GCresp.scGCframeにした。出力は[dcGCout, scGCsmpl, GCparam, GCresp] )
%       Modified:  26 Aug 2021  v231
%       Modified:  29 Aug 2021  v231
%       Modified:    3 Sep 2021  v231 some tests
%       Modified:  11 Sep 2021  v231 some tests
%       Modified:    7 Oct 2021  v231 debug IOfunction errors
%       Modified:  25 Oct 2021 v231 introducing  MkFilterField2Cochlea
%       Modified:  27 Jan 2022  v231 minor change StartupGCFB;
%       Modified:  27 Jan 2022  v231 introducing GCparam.OutMidCrct = 'EarDrum'; 
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func + modifed EqlzMeddisHCLevel
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
%       Modified:    8 Oct 2022  v234 Debug in GCFBv23_HearingLoss
%       Modified:  23 Oct 2022  v234 Minor modification display every 50 ch
%
%
% function [dcGCout, scGCsmpl, GCparam, GCresp] = GCFBv234(SndIn,GCparam)
%      INPUT:   Snd:    Input Sound
%                   GCparam:  Gammachirp parameters
%                   GCparam.fs:     Sampling rate          (48000)
%                   GCparam.NumCh:  Number of Channels     (100)
%                   GCparam.FRange: Frequency Range of GCFB:  default [100 6000]
%                                                specifying asymptotic freq. of passive GC (Fr1)
%
%      OUTPUT: 
%              dcGCout:  Dynamic Compressive GammaChirp Filter Output    (Either sample or frame)
%              scGCsmpl:  Static Compressive GammaChirp Filter Output   (Always sample output)
%              Ppgc:    power at the output of passive GC
%              GCparam: GCparam values
%              GCresp : GC response result
%              pGCframe: pGC frame --  empty when sample-by-sample
%              scGCframe: scGC frame --  empty when sample-by-sample
%
% Note
%   1)  This version is completely different from GCFB v.1.04 (obsolete).
%       We introduced the "compressive gammachirp" to accomodate both the
%       psychoacoustical simultaneous masking and the compressive
%       characteristics (Irino and Patterson, 2001). The parameters were
%       determined from large dataset (See Patterson, Unoki, and Irino, 2003.)
%
%
% References:
%  Irino,T. and Unoki,M.:  IEEE ICASSP98, pp.3653-3656, May 1998.
%  Irino,T. and Patterson,R.D. :  JASA, Vol.101, pp.412-419, 1997.
%  Irino,T. and Patterson,R.D. :  JASA, Vol.109, pp.2008-2022, 2001.
%  Patterson,R.D., Unoki,M. and Irino,T. :  JASA, Vol.114,pp.1529-1542,2003.
%  Irino,T. and and Patterson,R.D. : IEEE Trans.ASLP, Vol.14, Nov. 2006.
%
% Level setting: See Eqlz2MeddisHCLevel
% rms(s(t)) == sqrt(mean(s.^2)) == 1   --> 30 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 10  --> 50 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 100 --> 70 dB SPL
%
%
function [dcGCout, scGCsmpl, GCparam, GCresp] = GCFBv234(SndIn,GCparam)

disp(['-------------------- ' mfilename ' --------------------' ]);
% startup directory setting
StartupGCFB;

%%%% Handling Input Parameters %%%%%
if nargin < 2
    StrHelp = ['help ' mfilename];   eval(StrHelp);
end
[nc, LenSnd] = size(SndIn);
if nc ~= 1
    error('Check SndIn. It should be 1 ch (Monaural) and  a single row vector.' );
end

[GCparam, GCresp] = GCFBv23_SetParam(GCparam);  %
fs          = GCparam.fs;
NumCh = GCparam.NumCh;
Tstart   = clock;

%%%%% Outer-Mid Ear Compensation %%%%
if strcmp(upper(GCparam.OutMidCrct),'NO') == 0
    disp(['*** Outer/Middle Ear correction (minimum phase) : ' GCparam.OutMidCrct ' ***']);
    [CmpnstOutMid, ParamF2C] = MkFilterField2Cochlea(GCparam.OutMidCrct,fs,1);   
    % new 25 Oct 2021
    % [FIRCoef, Param] = MkFilterField2Cochlea(StrCrct,fs,SwFwdBwd,SwPlot) % (1) forward  (-1) backward
    %
    % conventional setting 
    % CmpnstOutMid = OutMidCrctFilt(GCparam.OutMidCrct,fs,0,2); % 2) minimum phase
    % 1kHz: -4 dB, 2kHz: -1 dB, 4kHz: +4 dB (ELC)
    % Now we use Minimum phase version of OutMidCrctFilt (modified 16 Apr. 2006).
    % No compensation is necessary.  16 Apr. 2006
    % for inverse filer,  use OutMidCrctFilt('ELC',fs,0,1);    
    Snd = filter(CmpnstOutMid,1,SndIn);
    GCparam.Field2Cochlea = ParamF2C;
else
    GCparam.Field2Cochlea = 'No Outer/Middle Ear correction';
    disp(['*** ' GCparam.Field2Cochlea ' ***']);
    Snd = SndIn;
end


%%%%% Gammachirp  %%%
disp('*** Gammmachirp Calculation ***');

if strncmp(GCparam.Ctrl,'sta',3) == 1
    % 'Fast processing for linear cGC gain at GCparam.LeveldBscGCFB';
    %%% for HP-AF %%%
    LvldB = GCparam.LeveldBscGCFB;
    GCresp.LvldB  = LvldB;
    fratVal = GCresp.frat0Pc + GCresp.frat1val.*(LvldB - GCresp.PcHPAF);  %GCresp.frat0Pc：　HPAFの中心音圧からの計算。
    Fr2val = fratVal.* GCresp.Fp1(:);
    GCresp.Fr2 = Fr2val;
    [ACFcoefFixed] = MakeAsymCmpFiltersV2(fs,Fr2val,GCresp.b2val,GCresp.c2val);
    
else % HP-AF for dynamic-GC level estimation path. 18 Dec 2012 Checked
    GCresp.LvldB  = []; % initialize
    Fr2LvlEst = GCparam.LvlEst.frat * GCresp.Fp1(:);
    % default GCparam.LvlEst.frat=1.08  (GCFBv208_SetParam(GCparam))
    % --> Linear filter for Level estimation
    % [ACFcoefFixed] = MakeAsymCmpFiltersV2(fs,Fr2LvlEst,GCparam.LvlEst.b2, GCparam.LvlEst.c2);

    % 26 Jul 2020   Introduction of CompressionHealth
    c2val_CmprsHlth = GCparam.HLoss.FB_CompressionHealth.* GCparam.LvlEst.c2;
    [ACFcoefFixed] = ...
        MakeAsymCmpFiltersV2(fs,Fr2LvlEst,GCparam.LvlEst.b2, c2val_CmprsHlth);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Passive Gammachirp * Fixed HP-AF for level estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pGCsmpl   = zeros(NumCh, LenSnd); % passive GC
scGCsmpl  = zeros(NumCh, LenSnd); % static cGC
Ppgc          = zeros(NumCh, LenSnd);
cGCoutLvlEst = zeros(NumCh, LenSnd);

disp('--- Channel-by-channel processing of static filter ---');
for nch=1:NumCh    %%%%%%%  Channel-by-channel processing of static filter
    %%%  passive gammachirp  %%%
    pgc = GammaChirp(GCresp.Fr1(nch),fs,GCparam.n,GCresp.b1val(nch),GCresp.c1val(nch),0,'','peak'); % pGC
    pGCsmpl(nch,1:LenSnd)=fftfilt(pgc,Snd);       % fast fft based filtering
    
    %%% Fixed HP-AF filtering for level setting %%%
    % Note(13 May 2020):  4 times of second-order filtering is
    %  comparable to 1 time 8th-order filtering in processing time.
    GCsmpl1 = pGCsmpl(nch,:);
    for Nfilt = 1:4  % loop 
        GCsmpl1 = filter(ACFcoefFixed.bz(nch,:,Nfilt), ACFcoefFixed.ap(nch,:,Nfilt), GCsmpl1);
    end
     scGCsmpl(nch,:) = GCsmpl1; % static compressive GC output : sample-by-sample
    
    if strncmp(GCparam.Ctrl,'sta',3) == 1
        if nch == 1,  StrGC = 'Static (Fixed) Compressive-Gammachirp'; end;
        GCresp.Fp2(nch) = Fr1toFp2(GCparam.n,GCresp.b1val(nch),GCresp.c1val(nch),  ...
            GCresp.b2val(nch),GCresp.c2val(nch), fratVal(nch),GCresp.Fr1(nch));
        if nch == NumCh % at the last channel --> make it a column vector
            GCresp.Fp2 = GCresp.Fp2(:);
        end
    else
        if nch == 1, StrGC = 'Passive-Gammachirp*Fixed HP-AF = Level estimation filter'; end;
    end
    
    if nch == 1 || rem(nch,50)==0  % 20ch --> 50ch  23 Oct 22
        disp([StrGC ': ch #' num2str(nch) ' / #' num2str(NumCh) ...
            '.    elapsed time = ' num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
    end
    
end % nch = 1:NumCh   %%%%%%%  Channel-by-channel processing of static filter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Filtering of  Dynamic HP-AF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strncmp(GCparam.Ctrl,'dyn',3) == 1  % Dynamic
    if strncmp(GCparam.DynHPAF.StrPrc,'sample',5) == 1
        if  strncmp(GCparam.HLoss.Type,'NH',2) ~= 1
            warning(['The output of GCFBv23_SampleBase has not been checked for ' GCparam.HLoss.Type]);
        end
        [dcGCsmpl,  GCresp] = GCFBv23_SampleBase(pGCsmpl, scGCsmpl, GCparam, GCresp);
        cGCout = dcGCsmpl;   % Sample output
        %
     elseif strncmp(GCparam.DynHPAF.StrPrc,'frame',5) == 1
        [dcGCframe, GCresp] = GCFBv23_FrameBase(pGCsmpl, scGCsmpl, GCparam, GCresp);
        cGCout  = dcGCframe; % Frame output
    else
        error('Specify "GCparam.DynHPAF.StrPrc" properly: "sample" or "frame" ');
    end
elseif  strncmp(GCparam.Ctrl,'sta',3) == 1  
   cGCout = scGCsmpl;
else
    error('Specify GCparam.Ctrl properly');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Signal path Gain Normalization at Reference Level (GainRefdB)
%  for static & dynamic filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~,LenOut] = size(cGCout);
if isnumeric(GCparam.GainRefdB) == 1  % classic model until GCFBv220
    % v220までと同様で、HLossは入れない。前との互換性確認／入れてもAbsThreshold設定がなければ使いにくい。
    fratRef = GCresp.frat0Pc + GCresp.frat1val.*(GCparam.GainRefdB - GCresp.PcHPAF);
    cGCRef = CmprsGCFrsp(GCresp.Fr1,fs,GCparam.n,GCresp.b1val,GCresp.c1val,fratRef,GCresp.b2val,GCresp.c2val);
    GCresp.GainFactor = 10^(GCparam.GainCmpnstdB/20)*cGCRef.NormFctFp2;  % compensationも入る。
    GCresp.cGCRef = cGCRef;
    
    dcGCout = (GCresp.GainFactor*ones(1,LenOut)).*cGCout;  % output name dcGCout
    
elseif strcmp(GCparam.GainRefdB,'NormIOfunc') == 1  % introducing HLoss

    GainFactor= 10.^(-(GCparam.HLoss.FB_AFgainCmpnstdB)/20);   % HL0dB, HL val dBを一致させるため
    %  2021/10/7 間違いと思ってチェック。 
    %   GainFactor= 10.^(-GCparam.HLoss.FB_NHgainCmpnstdB/20);    
    % NHの固定gainだけをここでは補正。HLのはこの方向での補正はしない。HL_IHC（横軸方向）で補正すべき。2021/10/7
    % ---> 2021/10/8、これではダメで、元の計算が正解であることがわかった。これ以外ない。
    %  蝸牛が健全ならIOfunctionも入力音圧に対し同じ位置。それに対してIHCの減衰が入って閾値に至る。
    %  注意すべき点は、圧縮特性がある場合、 HL_IHC (→方向：入力で見た場合)よりも、
    %   Loss_IHC （ ↓ 方向：変換損失）の方が小さくて実現する。
    %
    
    dcGCout = (GainFactor*ones(1,LenOut)).*cGCout;
    %  rms 0dBは、MeddisIHCLevelで30dB SPLに相当   17 Aug 2021
    %  従来のGCFBや入力信号とのcompativilityのため、このまま出力。
    % ---> rms　0dBでSPL0dBにしたい場合、GCparam.MeddisIHCLevel_RMS0dB_SPLdBを用いて補正すること。
    
else
    error('Set GCparam.GainRefdB properly');
end

end

