%
%       Sample by Sample processing of HP-AF of dcGCFB
%       Toshio IRINO
%       Created:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  27 Feb 2021  (v230, fucntion --> GCFBv230_SampleBase)
%       Modified:  28 Aug 2021  v231 no change in function
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%
% function [dcGCframe, GCresp] = GCFBv23_SmpleBase(pGCsmpl, scGCsmpl, GCparam, GCresp)
%      INPUT:  pGCsmpl:    passive GC sample
%                   scGCsmpl:  static cGC sample
%                   GCparam: 
%                   GCresp:
%
%      OUTPUT: 
%              dcGCframe:  frame level output of dcGC-FB
%              GCresp : 
%              pGCframe:  frame level output of pGC-FB
%
function [cGCsmpl,  GCresp] = GCFBv23_SampleBase(pGCsmpl, scGCsmpl, GCparam, GCresp)

%%%%% Initial settings %%%%%%%%%%%%%%%
% nDisp          = 20*fs/1000; % display every 20 ms
fs = GCparam.fs;
[NumCh, LenSnd] = size(pGCsmpl);
nDisp               = fix(LenSnd/10); % display 10 times per Snd 29 Jan 2015
cGCsmpl           = zeros(NumCh,LenSnd);
GCresp.Fr2     = zeros(NumCh,LenSnd);
GCresp.fratVal = zeros(NumCh,LenSnd);
GCresp.Fp2     = []; % No output
LvldB               = zeros(NumCh,LenSnd);
LvlLinPrev       = zeros(NumCh,2);

%%%%% Sample-by-sample processing %%%%%%%
disp('--- Sample base (sample-by-sample) processing ---');
Tstart = clock;
for nsmpl=1:LenSnd
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Level estimation circuit                                          %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Modified:  24 May 05
    LvlLin(1:NumCh,1) = ...
        max([max(pGCsmpl(GCparam.LvlEst.NchLvlEst,nsmpl),0), LvlLinPrev(:,1)*GCparam.LvlEst.ExpDecayVal]')';
    LvlLin(1:NumCh,2) = ...
        max([max(scGCsmpl(GCparam.LvlEst.NchLvlEst,nsmpl),0), LvlLinPrev(:,2)*GCparam.LvlEst.ExpDecayVal]')';
    LvlLinPrev = LvlLin;
    
    %%%%% Modified: 14 July 05
    LvlLinTtl = GCparam.LvlEst.Weight * ...
        GCparam.LvlEst.LvlLinRef.*(LvlLin(:,1)/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(1) ...
        + ( 1 - GCparam.LvlEst.Weight ) * ...
        GCparam.LvlEst.LvlLinRef.*(LvlLin(:,2)/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(2);
    
    LvldB(:,nsmpl) = 20*log10( max(LvlLinTtl,GCparam.LvlEst.LvlLinMinLim) ) ...
        + GCparam.LvlEst.RMStoSPLdB;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% Signal path                      %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Filtering High-Pass Asym. Comp. Filter
    %fratVal = GCparam.frat(1,1) + GCparam.frat(1,2)*GCresp.Ef(:) + ...
    %   GCparam.HLoss.FB_CompressionHealth.*(GCparam.frat(2,1) + GCparam.frat(2,2)*GCresp.Ef(:)).*LvldB(:,nsmpl);
    fratVal = GCresp.frat0Pc +GCparam.HLoss.FB_CompressionHealth.* GCresp.frat1val ...
                   .*( LvldB(:,nsmpl) - GCresp.PcHPAF);
    Fr2Val = GCresp.Fp1(:).*fratVal;
    
    GCparam.NumUpdateAsymCmp = 1;
    if rem(nsmpl-1, GCparam.NumUpdateAsymCmp) == 0 % update periodically
        [ACFcoef] = MakeAsymCmpFiltersV2(fs,Fr2Val,GCresp.b2val,GCresp.c2val);
    end;
    
    if nsmpl == 1,
        [dummy,ACFstatus] =  ACFilterBank(ACFcoef,[]);  % initiallization
    end;
    
    [SigOut,ACFstatus] = ACFilterBank(ACFcoef,ACFstatus,pGCsmpl(:,nsmpl));
    cGCsmpl(:,nsmpl) = SigOut;
    GCresp.Fr2(:,nsmpl) = Fr2Val;
    GCresp.fratVal(:,nsmpl) = fratVal;
    % Derivation of GCresp.Fp2 is too time consuming.
    % please use CalFp2GCFB.m
    
    if nsmpl==1 | rem(nsmpl,nDisp)==0,
        %%% [  20*log10([max(LvlLin(:,1)) max(LvlLin(:,2)) max(LvlLinTtl) ])...
        %%%  + GCparam.LvlEst.RMStoSPLdB      max(LvldB(:,nsmpl))]
        disp(['Dynamic Compressive-Gammachirp: Time ' int2str(nsmpl/fs*1000) ...
            '(ms) / ' int2str(LenSnd/fs*1000) '(ms).  elapsed time = ' ...
            num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
    end;
end; % for nsmpl=1:LenSnd

GCresp.LvldB  = LvldB;

return;
