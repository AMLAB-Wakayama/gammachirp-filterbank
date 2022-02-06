%
%       Delay compensation gc filter working with GCFBv230
%       IRINO, T.
%       Created:  11 Feb 2021 from CmpnstERBfilt (in ERBtool)
%       Modified:  11 Feb 2021
%       Modified:  13 Feb 2021 % NumCmpnst 修正 (+1を除いた)
%       Modified:  27 Feb 2021 % Frame baseでもSample baseでも使えるように。
%
% Note:
%       sample-by-sampleだと、CmpnstERBFilt.mで行っていた。
%       frame-baseだとframeのサンプリング周波数が違うので専用に開発
%       GCFB処理全体の時間遅れも勘案　pulse系列との時間遅れを補正
%
%
function [GCcmpnst, DCparam]  = GCFBv230_DelayCmpnst(GCval,GCparam,DCparam)

disp('*** GC filter delay compensation ***');
if isfield(DCparam,'fs') == 0,
    error('Specify sampling frequency (fs) of  input GCval. ');
    %  これで、Frame baseでもSample-baseでも対応可能
end;

% Delay のパラメータ：tuning後この値にした。通常は変更しない方が良いが、一応外部制御も可能に。
if nargin <= 2 || isfield(DCparam,'TdelayFilt1kHz') == 0  % default値をいれる。
    DCparam.TdelayFilt1kHz =0.002;  % default 2 ms @ 1 kHz
end
if isfield(DCparam,'TdelayFB') == 0  % default値をいれる。
    DCparam.TdelayFB    = 0; %  GCFB全体のdelay:  default 0 ms
    %%% NG    DCparam.TdelayFB    = 0.002; %  GCFB全体のdelay:  default 2 ms
    %%% 最初こうしていたが、GCFBの中で閉じているなら不要。
end;
if DCparam.TdelayFilt1kHz < 0 ||  DCparam.TdelayFB< 0
    error('Negative delay compensation is not allowed.');
end

[NumCh, LenVal] = size(GCval);
GCcmpnst = zeros(NumCh,LenVal);
for nch =1:NumCh
    NumCmpnst = fix((DCparam.TdelayFilt1kHz*1000/GCparam.Fr1(nch) + DCparam.TdelayFB)*DCparam.fs);
    
    if rem(nch,50) == 0 | nch == NumCh | nch == 1
        fprintf('Compensating delay:  ch #%d / #%d.  [Delay = %5.2f (ms)] \n', ...
            nch, NumCh, NumCmpnst/DCparam.fs*1000);
    end
    if abs(NumCmpnst) > LenVal
        error('Sampling point for Compensation is greater than the signal length.');
    end
     
    GCcmpnst(nch,:) = [GCval(nch,(NumCmpnst+1):LenVal), zeros(1,NumCmpnst)];
    DCparam.NumCmpnst(nch) = NumCmpnst;
end

return

%     NumCmpnst =  fix(NumDelayFilt1kHz * 1000/GCparam.Fr1(nch)); % GCFBv230_SetParamでGCparam.Fr1はsetされている

