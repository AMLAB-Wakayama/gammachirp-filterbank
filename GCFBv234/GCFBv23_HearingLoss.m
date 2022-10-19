%
%      Calculate GC Hearing Loss from GCFBv230
%       Irino, T.
%       Created:  21 May 2020
%       Modified: 21 May 2020
%       Modified: 22 May 2020
%       Modified: 23 May 2020
%       Modified: 18 Jul 2020 %コメント加え　nCH--> nCmprsHlth
%       Modified: 19 Jul 2020 %cにcompression healthをかけるように。（いままで、fratにCompressionHealthをかけていた）
%       Modified:  24 Jul 2020  (IO function)
%       Modified:  26 Jul 2020  (full debug)
%       Modified:  23 Jan 2021 (Modification started)
%       Modified:  24 Jan 2021 (InternalCmpnstLeveldB = -7, FactCmpnst --> OK)
%       Modified:  10 Feb 2021 (HLval_ManualSet)
%       Modified:  17 Aug 2021 using Fr1query = Fag   ( NOT Fp1)
%       Modified:  25 Aug 2021 v231 前面書き換えTable--> interp1
%       Modified:  29 Aug 2021 v231
%       Modified:   1 Sep 2021  v231 debug  HL_OHC+HL_IHC
%       Modified:   7 Oct  2021  v231 checking IOfunction errors
%       Modified:   7 Oct  2021  v231 OK for IOfunction
%       Modified:   5 Nov  2021 v231  Switch for perform SetHeaingLoss  solely
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:   8 Sep  2022  v234  compativility of NH and HL0 [0 0 0 0 0 0 0]
%       Modified:  19 Oct  2022  v234  minor debug
%
%    function [GCparam] = CalGCHearingLoss(GCparam,GCresp)
%            INPUT:    Necessary: GCparam.HLoss.FaudgramList, --.HearingLevel, --.CompressionHealth
%                           GCresp.Fp1
%           OUTPUT:  GCparam.HLoss :  PinLossdB_PAS, PinLossdB_ACT, FB_PinLossdB_PAS ...
%
% Note:  21 May 2020
%             仮定:  pGCはNHでもHI listenerでも常に同じ。違うのはHP-AFのところのみ。
%
%
function [GCparam] = GCFBv23_HearingLoss(GCparam,GCresp)

[GCparam] = SetHearingLoss(GCparam); %ここで、Hearing Lossの設定をしている。下に関数有り。
if nargin < 2
    disp(['--- ' mfilename ': Setting default hearing loss parameter and return. ---'])
    return; 
end

%%%%%%%%%%%%%%%%%%%%%%
%% setting parameters of hearing loss %%%%
GCparam.HLoss.CompressionHealth_InitVal = GCparam.HLoss.CompressionHealth;  %　初期値をkeep
% GCparam.HLoss.CompressionHealthはaudiogramにより変更あり

% Tableを使わずに算出
LenFag = length(GCparam.HLoss.FaudgramList);
for nFag = 1:LenFag
    Fr1query = GCparam.HLoss.FaudgramList(nFag);
    HL0_PinCochleadB(nFag) = HL2PinCochlea(Fr1query,0);  % cochlear Input Level に変換。　Compensation of MidEar Trans. Func.
    CompressionHealth    = GCparam.HLoss.CompressionHealth(nFag);
    [dummy, HL0_IOfuncdB_CH1] = GCFBv23_AsymFuncInOut(GCparam,GCresp,Fr1query,1,HL0_PinCochleadB(nFag));
    PindB_ACTreduction                = GCFBv23_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CompressionHealth,HL0_IOfuncdB_CH1);
    
    PinLossdB_ACT(nFag)  =  PindB_ACTreduction - HL0_PinCochleadB(nFag);   % HLossdBは正の数
    PinLossdB_ACT_Init(nFag)  = PinLossdB_ACT(nFag);   % inital value of ACT Loss
    PinLossdB_PAS(nFag)    = max(GCparam.HLoss.HearingLeveldB(nFag) - PinLossdB_ACT(nFag),0);  % Boundary setting 0以下にならない
    
    % NH以外で、下限にあたった場合、ACTのPinLossdB_ACTを再計算。
    % if PinLossdB_PAS(nFag) == 0  %  && GCparam.HLoss.HearingLeveldB(nFag) > 0
    % Note: 8 Sep 22
    % NHに近い時、これも条件として、不都合。PinLossdB_PAS(nFag) が0ではなく、+eps*100になることもあり。
    % 例えば、普通行わないが、HL0 [0 0 0 0 0 0 0]で、CompressionHealth= 0.5としていたら、1.0に補正する必要あり。

    if PinLossdB_PAS(nFag) < eps*10^4     % もし補正されていたら、全般に変更。
        PinLossdB_ACT(nFag)  = GCparam.HLoss.HearingLeveldB(nFag) - PinLossdB_PAS(nFag);      % PinLossdB_ACT側も補正
        CmprsHlthList = [1:-0.1:0];
        for nCH = 1:length(CmprsHlthList)  % 高々11点： elps 0.025 sec未満 -- 問題なし。
            CmprsHlth = CmprsHlthList(nCH);
            PindB_CmprsHlthVal_Inv = GCFBv23_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CmprsHlth,HL0_IOfuncdB_CH1);
            PinLossdB_ACT4Cmpnst(nCH) = PindB_CmprsHlthVal_Inv - HL0_PinCochleadB(nFag);
        end
        % CompressionHealth = interp1(PinLossdB_ACT4Cmpnst,CmprsHlthList, PinLossdB_ACT(nFag));
        % % NaNが出てしまってerrorになる。 debugged 8 Sep 2022
        CompressionHealth = interp1(PinLossdB_ACT4Cmpnst,CmprsHlthList, PinLossdB_ACT(nFag),'linear','extrap'); % 最も近いものを探す-- 補正した値
        if isnan(CompressionHealth) == 1
           % CompressionHealth = 0;  % NaNになったら0としてしまう。--- > これがバグのもと.　'linear','extrap'で出ないようにした。
           error('Error in CompressionHealth recalculation'); % --> error
        end   
        PindB_ACTreduction     =  GCFBv23_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CompressionHealth,HL0_IOfuncdB_CH1);
        PinLossdB_ACT(nFag)   = PindB_ACTreduction - HL0_PinCochleadB(nFag);   % HLossdBは正の数
        PinLossdB_PAS(nFag)   = GCparam.HLoss.HearingLeveldB(nFag) - PinLossdB_ACT(nFag);  % 0以下でも-0.3dB 程度のずれあり。多少ずれてもかまわない
        if abs(GCparam.HLoss.CompressionHealth_InitVal(nFag) - CompressionHealth) > eps   % 誤差が大きい時のみ表示。19 Oct 22
            disp(['Compenstated GCparam.HLoss.CompressionHealth ( ' int2str(Fr1query) ' Hz ) : '  ...
                num2str(GCparam.HLoss.CompressionHealth_InitVal(nFag)) ' --> ' num2str(CompressionHealth) ]);
        end
    end
    
    % これが0にならないことはないが、debug用に置いておく
    ErrorACTPAS = GCparam.HLoss.HearingLeveldB(nFag) -  (PinLossdB_PAS(nFag) + PinLossdB_ACT(nFag));
    if  abs(ErrorACTPAS) > eps*100 
       disp([ErrorACTPAS, GCparam.HLoss.HearingLeveldB(nFag), PinLossdB_ACT(nFag),  PinLossdB_PAS(nFag)])
       if  strncmp(GCparam.HLoss.Type,'NH',2) == 0 % 'NH'の時だけerrorを出さないように。
            error('Error in HL_total = HL_ACT + HL_PAS');
        end
    end
    
    GCparam.HLoss.CompressionHealth(nFag) = CompressionHealth; % 最終値に入れ替える
    %　全体のgain control　--- AsymFunctionの最大値から計算
    HLval_PinCochleadB(nFag) = HL2PinCochlea(Fr1query,0)+GCparam.HLoss.HearingLeveldB(nFag);  % cochlear Input Level に変換。　Compensation of MidEar Trans. Func.
    [~, HLval_IOfuncdB_CHval] = GCFBv23_AsymFuncInOut(GCparam,GCresp,Fr1query,CompressionHealth,HLval_PinCochleadB(nFag));
    GCparam.HLoss.AFgainCmpnstdB(nFag) = HLval_IOfuncdB_CHval;
    
end

%　使用しない：　NHgainCmpnstBiasdB = [3.5, -1.3, -3, -3, -4, -3, -3] %NHでHL0dBに合わせるための補正値。アドホック
NHgainCmpnstBiasdB = [0, 0, 0, 0, 0, 0, 0];  %補正値は無い方が良いことがわかった。2021/10/8
GCparam.HLoss.AFgainCmpnstdB = GCparam.HLoss.AFgainCmpnstdB + NHgainCmpnstBiasdB;  
GCparam.HLoss.HLval_PinCochleadB = HLval_PinCochleadB; % renamed from HLval_SPLdB  17 Aug 2021
GCparam.HLoss.PinLossdB_ACT        = PinLossdB_ACT;
GCparam.HLoss.PinLossdB_PAS         = PinLossdB_PAS;
GCparam.HLoss.PinLossdB_ACT_Init = PinLossdB_ACT_Init;


% interporation to GCresp.Fr1 (which is closer to Fp2)
[ERBrateFag] = Freq2ERB(GCparam.HLoss.FaudgramList);
[ERBrateFr1] = Freq2ERB(GCresp.Fr1); % GC channel分
GCparam.HLoss.FB_Fr1 = GCresp.Fr1;
GCparam.HLoss.FB_HearingLeveldB     = interp1(ERBrateFag,GCparam.HLoss.HearingLeveldB, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_HLval_PinCochleadB  = interp1(ERBrateFag,GCparam.HLoss.HLval_PinCochleadB, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_PinLossdB_PAS        = interp1(ERBrateFag,GCparam.HLoss.PinLossdB_PAS, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_PinLossdB_ACT       = interp1(ERBrateFag,GCparam.HLoss.PinLossdB_ACT, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_CompressionHealth = min(max(interp1(ERBrateFag,GCparam.HLoss.CompressionHealth, ERBrateFr1,'linear','extrap'), 0), 1) ;    % 0<= CmprsHlth <= 1;
GCparam.HLoss.FB_AFgainCmpnstdB     = interp1(ERBrateFag,GCparam.HLoss.AFgainCmpnstdB, ERBrateFr1,'linear','extrap');

%% %%%%%%%%%%%
%  Debug用　plot
%%%%%%%%%%%%%
%SwPlot = 1;
SwPlot = 0;
if SwPlot == 1
    close all
    % なぜ、GCparam.HLoss.FB_PinLossdB_PASとGCparam.HLoss.FB_PinLossdB_PAS_GainReductが同じ？
    % なぜ、２つを分けたか不明。　　23 Jan 2021
    % plot(ERBrateFr1,GCparam.HLoss.FB_PinLossdB_PAS,'--' ,ERBrateFr1, GCparam.HLoss.FB_PinLossdB_PAS_GainReduct,'-.', ...
    %       ERBrateFr1, GCparam.HLoss.FB_PinLossdB_ACT  , ERBrateFr1,GCparam.HLoss.FB_PinLossdB_ACT_GainReduct);
    plot(ERBrateFr1,GCparam.HLoss.FB_PinLossdB_PAS,'--' , ...
        ERBrateFr1, GCparam.HLoss.FB_PinLossdB_ACT );
    xlabel('ERB_N number ');
    ylabel('Gain Reduction (dB)');
    legend('PAS_GainReduct','ACT_GainReduct','Location','NorthWest');
    text(3,-2,num2str(GCparam.HLoss.CompressionHealth))
    
    HLcomposition =     [GCparam.HLoss.HearingLeveldB; GCparam.HLoss.PinLossdB_PAS; GCparam.HLoss.PinLossdB_ACT];
    % 以下の値が０であることが必須  --- かならずなっている気がするが、、、
    DiffHL = GCparam.HLoss.HearingLeveldB - (  GCparam.HLoss.PinLossdB_PAS+GCparam.HLoss.PinLossdB_ACT);
    if abs(DiffHL) >  100*eps
        error('Something wrong here');
    end
    % GCparam.HLoss.PinLossdB_PAS_GainReduct+GCparam.HLoss.PinLossdB_ACT_GainReduct
end

return;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   関数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%
%    SetHearingLoss
%%%%%%%%%%%%%%%%%%%%%%%

function GCparam = SetHearingLoss(GCparam)

GCparam.HLoss.FaudgramList = [125, 250, 500, 1000, 2000, 4000, 8000];
LenFag = length(GCparam.HLoss.FaudgramList);

if isfield(GCparam.HLoss,'Type')==0, GCparam.HLoss.Type=''; end
if length(GCparam.HLoss.Type) < 1 || strncmp(GCparam.HLoss.Type,'NH',2) == 1
    GCparam.HLoss.Type = 'NH_NormalHearing';  %%
    GCparam.HLoss.HearingLeveldB       = zeros(1,LenFag);
    GCparam.HLoss.PinLossdB_ACT       = zeros(1,LenFag);
    GCparam.HLoss.PinLossdB_PAS        = zeros(1,LenFag);
    GCparam.HLoss.IOfuncLossdB_PAS   = zeros(1,LenFag);
    if isfield(GCparam.HLoss,'CompressionHealth') == 0  % 外で与えられていない時だけ1にする
        GCparam.HLoss.CompressionHealth = ones(1,LenFag);
    end
    GCparam.HLoss.FB_PinLossdB_ACT      = zeros(GCparam.NumCh,1);
    GCparam.HLoss.FB_PinLossdB_PAS       = zeros(GCparam.NumCh,1);
    GCparam.HLoss.FB_IOfuncLossdB_PAS  = zeros(GCparam.NumCh,1);
    GCparam.HLoss.FB_CompressionHealth = ones(GCparam.NumCh,1);
    
elseif strncmp(GCparam.HLoss.Type,'HL',2) == 1 % HL
    if isfield(GCparam.HLoss, 'CompressionHealth')  == 0
        GCparam.HLoss.CompressionHealth = 0.5*ones(1,LenFag); % default 50%
    end
    
    NumHL = str2num(GCparam.HLoss.Type(3:min(4,end)));   %HL+2桁の場合 (増設対応)
    if length(NumHL) < 1, NumHL = str2num(GCparam.HLoss.Type(3)); end   %HL+1桁の場合
    GCparam.HLoss.SwType = NumHL;  % 'HL0','HL1','HL2', ...'HL7'... 'HL10', 'HL11' ....
    
    %    See HIsimFastGC_InitParamHI.m for the source --  番号を一致させる
    %     9  の   manual set  だけは、今後の extentionも考え、 0 番に
    %     ParamHI.AudiogramNum : audiogram select
    %                 0.manual input　手動入力　 <--> 9番から
    %                 1.example 1
    %                 2.立木2002 80yr
    %                 3.ISO7029 70yr 男
    %                 4.ISO7029 70yr 女
    %                 5.ISO7029 60yr 男
    %                 6.ISO7029 60yr 女
    %                 7.耳硬化症(よくわかるオージオグラムp.47)
    %                 8.騒音性難聴(よくわかるオージオグラムp.63)
    %
    
    if GCparam.HLoss.SwType == 0
        GCparam.HLoss.Type='HLval_ManualSet';
        %ここでは、default値を入れずに、外部からの設定が無い場合にはerror
        LenHL = length(GCparam.HLoss.HearingLeveldB);
        if  LenHL < length(GCparam.HLoss.FaudgramList),
            error('Set GCparam.HLoss.HearingLeveldB at FaudgramList in advance.');
        end
       % if (mean(GCparam.HLoss.HearingLeveldB) < 10*eps)  % 設定がNHかどうか. warningだけ出す
       %     warning('mean(GCparam.HLoss.HearingLeveldB) nearly equal 0 --- NH?')
       % end
        if length(find(GCparam.HLoss.HearingLeveldB < 0)) > 0
            error('GCparam.HLoss.HearingLeveldB must not be negative.');
            %　Compression healthの計算がややこしくなるので、HL>0に制限する。 8 Oct 2022
        end
    elseif GCparam.HLoss.SwType == 1   % Preset examples
        GCparam.HLoss.Type='HL1_Example';
        %%%                                             % [125, 250,  500, 1000, 2000, 4000, 8000];
        GCparam.HLoss.HearingLeveldB = [ 10  4 10 13 48 58 79];
    elseif GCparam.HLoss.SwType == 2    % Preset examples
        GCparam.HLoss.Type='HL2_Tsuiki2002_80yr';
        %%%                                             % [125, 250,  500, 1000, 2000, 4000, 8000];
        GCparam.HLoss.HearingLeveldB = [ 23.5, 24.3, 26.8,  27.9,  32.9,  48.3,  68.5];
    elseif GCparam.HLoss.SwType == 3
        GCparam.HLoss.Type='HL3_ISO7029_70yr_male';
        GCparam.HLoss.HearingLeveldB = [ 8  8  9 10 19 43 59];
    elseif GCparam.HLoss.SwType == 4
        GCparam.HLoss.Type='HL4_ISO7029_70yr_female';
        GCparam.HLoss.HearingLeveldB = [ 8  8  9 10 16 24 41];
    elseif GCparam.HLoss.SwType == 5
        GCparam.HLoss.Type='HL5_ISO7029_60yr_male';
        GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 12 28 39];
    elseif GCparam.HLoss.SwType == 6
        GCparam.HLoss.Type='HL6_ISO7029_60yr_female';
        GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 11 16 26];
    elseif GCparam.HLoss.SwType == 7
        GCparam.HLoss.Type='HL7_Example_Otosclerosis';
        GCparam.HLoss.HearingLeveldB = [  50 55 50 50 40 25 20 ]; % otosclerosis 耳硬化症(よくわかるオージオグラムp.47)
    elseif GCparam.HLoss.SwType == 8
        GCparam.HLoss.Type='HL8_Example_NoiseInduced';
        GCparam.HLoss.HearingLeveldB = [  15 10 15 10 10 40 20 ]; % otosclerosis %騒音性難聴(よくわかるオージオグラムp.63)
    else
        error('Specify GCparam.HLoss.Type (HL0, HL1, HL2, ....) properly.');
    end
else
    error('Specify GCparam.HLoss.Type (NH, HL0, HL1, HL2, ....) properly.');
end

if length(GCparam.HLoss.CompressionHealth) == 1
    GCparam.HLoss.CompressionHealth = GCparam.HLoss.CompressionHealth*ones(1,LenFag);
end

return;
end

