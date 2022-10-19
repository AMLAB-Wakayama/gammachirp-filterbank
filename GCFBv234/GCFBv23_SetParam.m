 %
%       Setting Default Parameters for GCFBv2xx
%       Toshio IRINO
%       Created:   31 Aug 2004
%       Modified:  9  Nov 2004  
%       Modified:  31 May 2005
%       Modified:  1  Jul 2005
%       Modified:  8  Jul 2005  (bug fix in b2)
%       Modified:  13 Jul 2005  ( GCparam.LvlEst.frat = 1.08)
%       Modified:  14 Jul 2005  ( adding GCparam.LvlEst.RefdB, Pwr, Weight)
%       Modified:  16 Jul 2005  ( GCparam.LvlEst.LctERB = 1.5)
%       Modified:  15 Sep  2005  (v205, rename GCparam.LvlRefdB --> GainRefdB)
%       Modified:   7 Apr 2006  (v206, Compensation of Group delay OutMidCrct)
%       Modified:  26 Jun 2006  (v206, checking b1, c1 parameters.)
%       Modified:  23 Dec 2006  (v207, renamed from v206. 'dyn[amic]')
%       Modified:  19 Jan 2007  (v207, GCparam.Ctrl: 'sta[tic]'=='fix[ed]')
%       Modified:  19 Dec 2011  (v208, non-sample-by-sample coefficient update)
%       Modified:  25 Nov 2013  (v209, introducing 'lev[el-estimation]')
%       Modified:  18 Apr 2015  (v209, Check function names)
%       Modified:  18 Apr 2015  (v210, include GCresp in GCFBv210_SetParam )
%       Modified:  26 Apr 2015  (v210, intro. LeveldBscGCFB, default NumCh 75 --> 100. )
%       Modified:    5 Dec 2018  (v211,  No software modification in the main. Just adding another m-files.)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  22 May 2020  (v230, introduction of GC Hearing Loss)
%       Modified:  26 Jul 2020  (v230, modified some comments)
%       Modified:  25 Jan 2021 (v230, No 'sta[tic]'=='fix[ed]'  allowed anymore )
%       Modified:  11 Feb 2021 (v230, GCparam.Fr1 = Fr1(:);)
%       Modified:  28 Feb 2021 (v230, GCparam.Ctrl = 'dynamic'; default　)
%       Modified:  13 Aug 2021 (v230, error('GCFB may not work when max(FreqRange)*3 > fs. --- Set fs properly.');　)
%       Modified:  28 Aug 2021  v231, no change in function
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
%       Modified:    8 Oct 2022  v234 Debug in GCFBv23_HearingLoss
%
% function GCparam = GCFBv2xx_SetParam(GCparam)
%  INPUT:  GCparam:  Your preset gammachirp parameters
%           GCparam.fs:     Sampling rate          (48000)
%           GCparam.NumCh:  Number of Channels     (75)
%           GCparam.FRange: Frequency Range of GCFB [100 6000]
%                           specifying asymptotic freq. of passive GC (Fr1)
%           GCparam.Ctrl: 'sta[tic]'=='fix[ed]' / 'dyn[amic]'=='tim[e-varying]'
%        
%  OUTPUT: GCparam: GCparam values
%
%  Reference:
%  Patterson, R.D., Unoki, M. and Irino, T. :  JASA, Vol.114,pp.1529-1542,2003.
%
function [GCparam, GCresp] = GCFBv23_SetParam(GCparam)


%%%% Handling Input Parameters %%%%%
if isfield(GCparam,'fs') == 0, GCparam.fs = [];  end
if length(GCparam.fs) == 0  
        GCparam.fs  = 48000; 
end

if isfield(GCparam,'OutMidCrct') == 0, GCparam.OutMidCrct = []; end
if length(GCparam.OutMidCrct) == 0 
	GCparam.OutMidCrct  = 'ELC';
%%% if no OutMidCrct is not necessary, specify GCparam.OutMidCrct = 'no'; 
end

if isfield(GCparam,'NumCh') == 0,  GCparam.NumCh = [];   end
if length(GCparam.NumCh) == 0 
	% GCparam.NumCh  = 75;
	GCparam.NumCh  = 100; % default value changed 26 Apr 2015
end
if isfield(GCparam,'FRange') == 0,  GCparam.FRange = [];   end
if length(GCparam.FRange) == 0 
	GCparam.FRange  = [100 6000];
end

if GCparam.FRange(2)*3 > GCparam.fs    % fs should be at least 3 times of max FRange  13 Aug 12
    disp(GCparam)
    disp('GCFB may not work properly when max(FreqRange)*3 > fs. ');
    disp('---> Set fs properly.   OR  If you wish to continue as is, press RETURN > ');
    pause
end

%%%%% Gammachirp  parameters %%%
if isfield(GCparam,'n') == 0,  GCparam.n = [];   end
if length(GCparam.n) == 0 
         GCparam.n = 4;                 % default gammatone & gammachirp
end

%%% convention 

if isfield(GCparam,'b1') == 0,  GCparam.b1 = [];   end
if length(GCparam.b1) == 0          % b1 becomes two coeffs. in v210 (18 Apr. 2015)
         GCparam.b1 = [1.81, 0];     % frequency independent by 0 % 18 Apr. 2015
end
if length(GCparam.b1) == 1
         GCparam.b1(2) = 0;          % frequency independent by 0
end
if isfield(GCparam,'c1') == 0,  GCparam.c1 = [];   end
if length(GCparam.c1) == 0         % c1 becomes two coeffs. in v210 (18 Apr. 2015)
         GCparam.c1 = [-2.96, 0];    % frequency independent by 0 
end
if length(GCparam.c1) == 1
         GCparam.c1(2) = 0;          % frequency independent by 0 
end
if isfield(GCparam,'frat') == 0,  GCparam.frat = [];   end
if length(GCparam.frat) == 0
         GCparam.frat = [0.466, 0; 0.0109, 0];                 
end

if isfield(GCparam,'b2') == 0,  GCparam.b2 = [];   end
if length(GCparam.b2) == 0 
        GCparam.b2 = [2.17, 0; 0,0];   % no level-dependency  (8 Jul 05)
end
if isfield(GCparam,'c2') == 0,  GCparam.c2 = [];   end
if length(GCparam.c2) == 0
  % GCparam.c2 = [2.20, 0; 0,0]; %v203: no level-dependency; no freq-dependency
  % GCparam.c2 = [1.98, 0; 0.0088, 0];  % == v203
  % GCparam.c2 = [2.0, 0; 0.010, 0];   % no freq-dependecy: level-dependent
                                     % for simplicity v204
  %  GCparam.c2 = [2.0, 0; 0.030, 0];  % 26 May 05 (NG! since Pc == mean value) 
  % GCparam.c2 = [2.1, 0; 0.010, 0];  % 27 May 05 (1 dB worse than 2.0 0.010 )
  % GCparam.c2 = [2.0, 0; 0.015, 0];  % 31 May 05 (much worse than 2.0 0.010 )
  % GCparam.c2 = [2.0, 0; 0.007, 0];  % 1 Jun 05 (OK! almost the same as 1st draft)
  GCparam.c2 = [2.20, 0; 0, 0];   %  3 Jun 05 . It is good!
end
if isfield(GCparam,'Ctrl') == 0,  GCparam.Ctrl = [];   end
if length(GCparam.Ctrl) == 0,     GCparam.Ctrl = 'dynamic'; end  % default dynamic 28 Feb 2021
if strncmp(GCparam.Ctrl,'fix',3), GCparam.Ctrl = 'static'; end
if strncmp(GCparam.Ctrl,'tim',3), GCparam.Ctrl = 'dynamic'; end


if strncmp(GCparam.Ctrl,'sta',3) ~= 1 && strncmp(GCparam.Ctrl,'dyn',3) ~= 1 ...
 && strncmp(GCparam.Ctrl,'lev',3) ~= 1
  error(['Specify GCparam.Ctrl:  "static", "dynamic", or "level(-estimation)" ' ...
         ' (old version "fixed"/"time-varying") ']);
end

if isfield(GCparam,'GainCmpnstdB') == 0,  GCparam.GainCmpnstdB = [];   end
if length(GCparam.GainCmpnstdB) == 0
  GCparam.GainCmpnstdB  = -1;  % in dB. when LvlEst.c2==2.2, 1 July 2005
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Parameters for level estimation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('GCparam.PpgcRef') == 1 || exist('GCparam.LvlRefdB') == 1  
  disp('The parameter "GCparam.PpgcRef" is obsolete.');
  disp('The parameter "GCparam.LvlRefdB" is obsolete.');
  error('Please change it to GCparam.GainRefdB.'); 
end

if isfield(GCparam,'GainRefdB') == 0,  GCparam.GainRefdB = [];   end
if length(GCparam.GainRefdB) == 0
         % GCparam.GainRefdB = 50;  % reference Ppgc level for gain normalization used in v221 and before
         GCparam.GainRefdB = 'NormIOfunc';    % New default v230  23 May 2020 --> 25 Jul 2020
end

if isfield(GCparam,'LeveldBscGCFB') == 0,  GCparam.LeveldBscGCFB = [];   end 
if length(GCparam.LeveldBscGCFB) == 0
         GCparam.LeveldBscGCFB = 50;  % use it as default for  static-compressive GCFB (scGCFB)
end

if isfield(GCparam,'LvlEst') == 0,  GCparam.LvlEst = [];   end

if isfield(GCparam.LvlEst,'LctERB') == 0,  GCparam.LvlEst.LctERB = [];   end
if length(GCparam.LvlEst.LctERB) == 0
      % GCparam.LvlEst.LctERB = 1.0;  
      % Location of Level Estimation pGC relative to the signal pGC in ERB
      % see testGC_LctERB.m for fitting result. 10 Sept 2004
       GCparam.LvlEst.LctERB = 1.5;   % 16 July 05
end


if isfield(GCparam.LvlEst,'DecayHL') == 0, GCparam.LvlEst.DecayHL=[]; end
if length(GCparam.LvlEst.DecayHL) == 0
        %%% GCparam.LvlEst.DecayHL = 1; % half life in ms,  Mar 2005
        GCparam.LvlEst.DecayHL = 0.5; % 18 July 2005
        %%% Original name was PpgcEstExpHL
        %%% Interesting findings on 12 Jul 04 
        %%% GCparam.PpgcEstExpHL = 2;  % seems to produce distortion product
        %%% GCparam.PpgcEstExpHL = 5;  % original value without any info.
        %%% Resonable value:
        %%% GCparam.LvlEst.DecayHL = 1; % It is the best in the forward masking
end

if isfield(GCparam.LvlEst,'b2') == 0, GCparam.LvlEst.b2=[]; end
if length(GCparam.LvlEst.b2) == 0
     % GCparam.LvlEst.b2 = 1.5;
     % GCparam.LvlEst.b2 = 2.01;          % = b2 bug!
     GCparam.LvlEst.b2 = GCparam.b2(1,1); % = b2   8 July 2005
end

if isfield(GCparam.LvlEst,'c2') == 0, GCparam.LvlEst.c2=[]; end
if length(GCparam.LvlEst.c2) == 0
     % GCparam.LvlEst.c2 = 2.7;
     % GCparam.LvlEst.c2 = 2.20;  % = c2
     GCparam.LvlEst.c2 = GCparam.c2(1,1); % = c2
end

if isfield(GCparam.LvlEst,'frat') == 0, GCparam.LvlEst.frat=[]; end
if length(GCparam.LvlEst.frat) == 0
    % GCparam.LvlEst.frat = 1.1;  %  when b=2.01 & c=2.20
    GCparam.LvlEst.frat = 1.08;   %  peak of cGC ~= 0 dB (b2=2.17 & c2=2.20)
end

if isfield(GCparam.LvlEst,'RMStoSPLdB')==0, GCparam.LvlEst.RMStoSPLdB=[]; end
if length(GCparam.LvlEst.RMStoSPLdB) == 0
    GCparam.LvlEst.RMStoSPLdB = 30;   %  1 rms == 30 dB SPL for Meddis HC level
    GCparam.MeddisHCLevel_RMS0dB_SPLdB = 30;   %  1 rms == 30 dB SPL for Meddis HC level
    % わかりやすい名前に。17 Aug 21 -- どちらも同様に使える。
end

if isfield(GCparam.LvlEst,'Weight')==0, GCparam.LvlEst.Weight=[]; end
if length(GCparam.LvlEst.Weight) ==0
    GCparam.LvlEst.Weight = 0.5;  
end

if isfield(GCparam.LvlEst,'RefdB')==0, GCparam.LvlEst.RefdB=[]; end
if length(GCparam.LvlEst.RefdB) < 2
    GCparam.LvlEst.RefdB = 50;  % 50 dB SPL
end

if isfield(GCparam.LvlEst,'Pwr')==0, GCparam.LvlEst.Pwr=[]; end
if length(GCparam.LvlEst.Pwr) < 2
    GCparam.LvlEst.Pwr = [ 1.5, 0.5 ];  % Weight for pGC & cGC 
end

% new 19 Dec 2011
if isfield(GCparam,'NumUpdateAsymCmp')==0, GCparam.NumUpdateAsymCmp=[]; end
if length(GCparam.NumUpdateAsymCmp) < 1
    % GCparam.NumUpdateAsymCmp = 3;  % update every 3 sample (== 3*GCFBv207)
    GCparam.NumUpdateAsymCmp = 1;  % sample-by-sample (== GCFBv207)
end


%% %%%%%%%%%%%%%%%%%%%%%%%
% new 13 May 2020    Sample-by-sample or Frame-base processing
%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(GCparam,'DynHPAF')==0, GCparam.DynHPAF=''; end
if isfield(GCparam.DynHPAF,'StrPrc')==0, GCparam.DynHPAF.StrPrc=''; end
if length(GCparam.DynHPAF.StrPrc) < 1
     GCparam.DynHPAF.StrPrc = 'sample-by-sample';  % default for backward compativility
     %%%   GCparam.DynHPAF.StrPrc = 'frame-based';
end

if strncmp(GCparam.DynHPAF.StrPrc,'frame',5) == 1    % 16 May 2020
      GCparam.DynHPAF.Tframe  = 0.001;  % 1ms   <-- 5 msよりも良い
      % Not Use:   GCparam.DynHPAF.Tframe  = 0.0005;  % 1msと変わらない。安定のため1ms採用。
      GCparam.DynHPAF.Tshift    = 0.0005;  % 0.5ms   fs = 2000;  <-- 1 msよりも精度高い
      % Not Use:  GCparam.DynHPAF.Tshift    = 0.00025;  %  0.5msと変わらない。サンプリング周波数4000Hz
      GCparam.DynHPAF.LenFrame  = fix(GCparam.DynHPAF.Tframe*GCparam.fs);  % 整数に: 44.1kHzの時困るので
      GCparam.DynHPAF.LenShift    = fix(GCparam.DynHPAF.Tshift*GCparam.fs); % 整数に
      GCparam.DynHPAF.Tframe      = GCparam.DynHPAF.LenFrame/GCparam.fs;      % 整数から計算しなおし。
      GCparam.DynHPAF.Tshift         = GCparam.DynHPAF.LenShift/GCparam.fs;        % 整数から計算しなおし。
      GCparam.DynHPAF.fs              = 1/GCparam.DynHPAF.Tshift;  % サンプリング周波数
      GCparam.DynHPAF.NameWin  = 'hanning';
      StrWinFunc = [GCparam.DynHPAF.NameWin '(' int2str(GCparam.DynHPAF.LenFrame) ')'];
      GCparam.DynHPAF.ValWin      = eval(StrWinFunc);     
      GCparam.DynHPAF.ValWin       = GCparam.DynHPAF.ValWin/sum(GCparam.DynHPAF.ValWin); % normalization
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    GCresp 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Fr1, ERBrate1]  = EqualFreqScale('ERB',GCparam.NumCh,GCparam.FRange);
GCparam.Fr1    = Fr1(:);   % 以降の分析で頻繁に必要になるので、GCparam.Fr1だけはここでもset. この値は一意に決まるのでGCparamでもOK。
GCresp.Fr1       = Fr1(:);
GCresp.ERBspace1 = mean(diff(ERBrate1));
[ERBrate ERBw]   = Freq2ERB(GCresp.Fr1);
[ERBrate1kHz ERBw1kHz] = Freq2ERB(1000);
GCresp.Ef = ERBrate(:)/ERBrate1kHz - 1;

OneVec = ones(GCparam.NumCh,1);
GCresp.b1val = GCparam.b1(1)*OneVec + GCparam.b1(2)*GCresp.Ef; 
GCresp.c1val = GCparam.c1(1)*OneVec + GCparam.c1(2)*GCresp.Ef;

GCresp.Fp1 = Fr2Fpeak(GCparam.n,GCresp.b1val,GCresp.c1val,GCresp.Fr1);

GCresp.b2val = GCparam.b2(1,1)*OneVec + GCparam.b2(1,2)*GCresp.Ef;
GCresp.c2val = GCparam.c2(1,1)*OneVec + GCparam.c2(1,2)*GCresp.Ef; 

% New parameters for HPAF    23 May 2020
GCresp.frat0val = GCparam.frat(1,1)*OneVec + GCparam.frat(1,2)*GCresp.Ef;
GCresp.frat1val = GCparam.frat(2,1)*OneVec + GCparam.frat(2,2)*GCresp.Ef; 

GCresp.PcHPAF = ( 1 - GCresp.frat0val)./GCresp.frat1val;    % center level for HPAF
GCresp.frat0Pc = GCresp.frat0val + GCresp.frat1val.*GCresp.PcHPAF;
% See testHPAF_Ctrl_Cmprs
% Pc = (1 - GCparam.frat(1,1))/GCparam.frat(2,1);  % center of HPAF   だいたい50dB
% frat0Pc = GCparam.frat(1,1) + GCparam.frat(2,1)*Pc;
% frat = frat0Pc + CompressionHealth*GCparam.frat1val*(PsdB-Pc);  %中心からの係数変化


%% %%%%%%%%%%%%%%%%%%%%%%%
%  GC Hearing Loss 
%%%%%%%%%%%%%%%%%%%%%%%%%
[GCparam] = GCFBv23_HearingLoss(GCparam,GCresp);

% for debug
% [GCparam] = GCFBv23_HearingLoss_v233(GCparam,GCresp); disp('--- Old version used in v233 ---') 


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Set Params Estimation circuit                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keep LvlEst params  3 Dec 2013
ExpDecayVal    = exp(-1/(GCparam.LvlEst.DecayHL*GCparam.fs/1000)*log(2)); % decay exp.
NchShift       = round(GCparam.LvlEst.LctERB/GCresp.ERBspace1);
NchLvlEst      = min(max(1, (1:GCparam.NumCh)'+NchShift),GCparam.NumCh);  % shift in NumCh [1:NumCh]
LvlLinMinLim   = 10^(-GCparam.LvlEst.RMStoSPLdB/20); % minimum should be 0 dBSPL
LvlLinRef      = 10.^(( GCparam.LvlEst.RefdB - GCparam.LvlEst.RMStoSPLdB)/20); 

GCparam.LvlEst.ExpDecayVal  = ExpDecayVal;
GCparam.LvlEst.ERBspace1    = GCresp.ERBspace1;
GCparam.LvlEst.NchShift     = NchShift;
GCparam.LvlEst.NchLvlEst    = NchLvlEst;
GCparam.LvlEst.LvlLinMinLim = LvlLinMinLim;
GCparam.LvlEst.LvlLinRef    = LvlLinRef;



return
