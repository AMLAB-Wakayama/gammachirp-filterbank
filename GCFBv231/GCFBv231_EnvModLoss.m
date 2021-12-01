%
%       Reduction of Envelope Modulation working with GCFBv230
%       IRINO, T.
%       Created:  10 Feb 2021
%       Modified:  10 Feb 2021
%       Modified:  11 Feb 2021
%       Modified:  14 Feb 2021
%
%
%
function [EMframe, EMparam]  = GCFBv231_EnvModLoss(cGCframe,GCparam,EMparam)

if strncmp(GCparam.DynHPAF.StrPrc,'frame',5) ~= 1
    error('Working only when GCparam.DynHPAF.StrPrc== ''frame-base''');
end;

%% %%%%%%%%%
% Parameter setting
%%%%%%%%%%%
% GCparam.HLoss.FaudgramList と同じ長さのパラメータが必要
% 1つの値（scalar）なら、vectorに変換
%
LenFag = length(GCparam.HLoss.FaudgramList);
EMparam.fs = GCparam.DynHPAF.fs;  % frame-baseの出力sampling-rate

if isfield(EMparam,'ReducedB') == 0  % default
    EMparam.ReducedB = zeros(1,LenFag);
end
if length(EMparam.ReducedB) == 1
    EMparam.ReducedB = EMparam.ReducedB*ones(1,LenFag);
elseif length(EMparam.ReducedB) ~= LenFag
    error('Set EMparam.ReducedB at FaudgramList in advance.');
end

if isfield(EMparam,'Fcutoff') == 0 % default: almost no cutoff
    EMparam.Fcutoff = 0.999*EMparam.fs/2*ones(1,LenFag);
end
if length(EMparam.Fcutoff) == 1
    EMparam.Fcutoff = EMparam.Fcutoff*ones(1,LenFag);
elseif length(EMparam.Fcutoff) ~= LenFag
    error('Set EMparam.Fcutoff at FaudgramList in advance.');
end

%%%%%%
% FB 分に
%%%%%%%
% interporation to GCresp.Fr1 (which is closer to Fp2)
[ERBrateFag] = Freq2ERB(GCparam.HLoss.FaudgramList);
[ERBrateFr1] = Freq2ERB(GCparam.Fr1); % GC channel分
EMparam.FB_Fr1            = GCparam.Fr1; % GCFBv230_SetParamで代入されている
EMparam.FB_ReducedB = interp1(ERBrateFag,EMparam.ReducedB, ERBrateFr1,'linear','extrap');
EMparam.FB_Fcutoff     = interp1(ERBrateFag,EMparam.Fcutoff, ERBrateFr1,'linear','extrap');

%% %%%%%%%%%%%%%%%%%%%%%%%
% Main: filtering
%%%%%%%%%%%%%%%%%%%%%%%%%
EMframe  = zeros(size(cGCframe));
EMparam.orderLPF = 1;  %   TMTF is a first-order low-pass filter.　  これ以外は、受け付けない。
EMparam.SampleDelay = 1;  % 1st orderの時  Sample delayは1.  see testTMTFlpf.m

EMparam.fcSepFilt      = 1;  % DC vs High freq :Separation filter
EMparam.orderSepFilt = 2;
NormSepFiltCutoff = EMparam.fcSepFilt/(EMparam.fs/2);
[bzSepLP, apSepLP] = butter(EMparam.orderSepFilt,NormSepFiltCutoff);
[bzSepHP, apSepHP] = butter(EMparam.orderSepFilt,NormSepFiltCutoff,'high');

SwMethod = 1; % RMS    separation of DC component only
% Not very good:   SwMethod = 2; % Lowpass-Highpass separation

for nch = 1:GCparam.NumCh
    Env = cGCframe(nch,:);
    if SwMethod == 1,
        EnvSepLP = sqrt(mean(Env.^2)); % DC component
        EnvSepHP = Env-EnvSepLP;
    else
        EnvSepLP =  filter(bzSepLP, apSepLP,Env);  % Env Separated by LPF:  No gain control
        EnvSepHP =  filter(bzSepHP, apSepHP,Env);  % Env Separated by HPF : Gain & LPF are applied.
    end;
    
    % Lowpass of  Env separated by HPF
    NormFcutoff = EMparam.FB_Fcutoff(nch)/(EMparam.fs/2);
    [bz, ap] = butter(EMparam.orderLPF,NormFcutoff);
    EnvSepHP2 = filter(bz, ap, EnvSepHP);
    EnvSepHP2 = 10^(-EMparam.FB_ReducedB(nch)/20)*EnvSepHP2;  % filter gainをreducedB分だけ下げる
    
    EnvRdct = EnvSepHP2 + EnvSepLP; % あわせる
    
    % compensation of filter delay
    NumCmpnst = EMparam.SampleDelay;  % Sample delayで補正
    EMframe(nch,:) = [ EnvRdct((NumCmpnst+1):end), zeros(1,NumCmpnst)];
    
end

return


%% %%%%%%%%%
% Trash
%%%%%%%%%%%
% [bz, ap] = butter(EMparam.orderLPF,NormFcutoff);
% if ap(1) ~= 1, % 通常１のはず
%     warning('Something strange in butter');
%     bz = bz/ap(1);
%     ap = ap/ap(1);
% end;

%
%     RmsEnv = sqrt(mean(Env.^2));  % Rms value of Env. for equalization
% EnvNoDC = Env - RmsEnv;   % DC成分を除く -- これは、変。DC成分だけ大きく元のまま
% 全体のTMTF gainが減ると考えてよい。
%    EnvRdct = EnvRdct+ RmsEnv;    % DC成分をもどす。


