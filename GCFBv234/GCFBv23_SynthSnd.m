%
%       Synthesis sound for GCFBv23x
%       IRINO, T.
%       Created:   28 Feb 2021 
%       Modified:  28 Feb 2021 % 
%       Modified:  25 Oct 2021 % introducing MkFilterField2Cochlea
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%
% Note:
%       GCFBがELC補正をして分析している場合、それを逆補正する必要あり。
%
%
function [SndSyn]  = GCFBv23_SynthSnd(GCsmpl,GCparam)

disp('*** Synthesis from GCFB 2D-sample ***');
fs = GCparam.fs;
% Inverse compensation of ELC
if strcmp(upper(GCparam.OutMidCrct),'NO') ~= 1
    % ELC等の逆フィルタ。周波数特性がこちらの方が良い。
    AmpSyn = -15; % AnaSynでimpulse 応答が一致するように決めた。
                             % GCFBの周波数範囲によって影響はなし。
    Tdelay = 0.00632; % filter delay  時間遅れの補正。 ただし、ELC filter用。
    Ndelay = fix(Tdelay*fs);
     InvCmpnOutMid = MkFilterField2Cochlea(GCparam.OutMidCrct,fs,-1); % -1) backward inverse filter 26 Oct 21
    SndMean = mean(GCsmpl);
    SndSyn1 = filter(InvCmpnOutMid,1,SndMean);
    % 振幅と時間遅れ補正
    SndSyn = AmpSyn*[SndSyn1(Ndelay+1: end), zeros(1,Ndelay)];
else
    % ELC等の重み付けがない場合
    disp('No inverse OutMidCrct (FF / DF / ITU +MidEar / ELC) correction.');
    AmpSyn = -15;  % 上と同じ値でOK
    SndSyn =  AmpSyn*mean(GCsmpl);
end

return
