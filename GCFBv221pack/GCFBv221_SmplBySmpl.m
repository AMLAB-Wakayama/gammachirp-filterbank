%
%       Sample by Sample processing of HP-AF of dcGCFB
%       Toshio IRINO
%       Created:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%
%       See  main  GCFB2xx
%
% Sample by Sample processing

%%%%% Initial settings %%%%%%%%%%%%%%%
% nDisp          = 20*fs/1000; % display every 20 ms
nDisp               = fix(LenSnd/10); % display 10 times per Snd 29 Jan 2015
cGCout           = zeros(NumCh,LenSnd);
GCresp.Fr2     = zeros(NumCh,LenSnd);
GCresp.fratVal = zeros(NumCh,LenSnd);
GCresp.Fp2     = []; % No output
LvldB               = zeros(NumCh,LenSnd);
LvlLinPrev       = zeros(NumCh,2);

%%%%% Sample-by-sample processing %%%%%%%
disp('--- Sample-by-sample processing ---');
Tstart = clock;
for nsmpl=1:LenSnd
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Level estimation circuit                                          %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Modified:  24 May 05
    % half wave rectification first using max(??,0)
    LvlLin(1:NumCh,1) = ...
        max([max(pGCout(GCparam.LvlEst.NchLvlEst,nsmpl),0), LvlLinPrev(:,1)*GCparam.LvlEst.ExpDecayVal]')';
    LvlLin(1:NumCh,2) = ...
        max([max(cGCoutLvlEst(GCparam.LvlEst.NchLvlEst,nsmpl),0), LvlLinPrev(:,2)*GCparam.LvlEst.ExpDecayVal]')';
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
    fratVal = GCparam.frat(1,1) + GCparam.frat(1,2)*GCresp.Ef(:) + ...
        (GCparam.frat(2,1) + GCparam.frat(2,2)*GCresp.Ef(:)).*LvldB(:,nsmpl);
    Fr2Val = GCresp.Fp1(:).*fratVal;
    
    GCparam.NumUpdateAsymCmp = 1;
    if rem(nsmpl-1, GCparam.NumUpdateAsymCmp) == 0 % update periodically
        [ACFcoef] = MakeAsymCmpFiltersV2(fs,Fr2Val,GCresp.b2val,GCresp.c2val);
    end;
    
    if nsmpl == 1,
        [dummy,ACFstatus] =  ACFilterBank(ACFcoef,[]);  % initiallization
    end;
    
    [SigOut,ACFstatus] = ACFilterBank(ACFcoef,ACFstatus,pGCout(:,nsmpl));
    cGCout(:,nsmpl) = SigOut;
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
