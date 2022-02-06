%      Calculate GC Hearing Loss from GCFBv230  -- AsymFuncInOut
%       Irino, T.
%       Created:  15 Aug 2021  extracted from GCFBv230_HearingLoss
%       Modified:  15 Aug 2021
%       Modified:  17 Aug 2021 using Fr1query -- NOT Fp1
%       Modified:  25 Aug 2021 v231
%       Modified:   7 Oct  2021  v231 debug IOfunction errors
%
%    function [AFoutdB, IOfuncdB, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, Fr1query, CompressionHealth,PindB)
%       INPUT: GCparam, GCresp, 
%                  Fr1query :  Specify by Fr1  which is usually used in specifying FB freq. (not Fp1)
%                  CompressionHealth
%                  PindB
%       OUTPUT: AFoutdB, IOfuncdB
%
%   Note: new 19 Jul 2020  GCresp.c2valにcompression healthをかける。
%            こちらの方がlinearityが良いことを確認　ーー＞定式化としても素直
%
function [AFoutdB, IOfuncdB, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, Fr1query, CompressionHealth,PindB)

GCparam.AsymFunc_NormdB = 100; % default 　この値自体200にしても、GCFBv231の出力にほとんど影響ない。すべてdB上でのshiftにすぎない。

AFoutLin         = CalAsymFunc(GCparam,GCresp, Fr1query, CompressionHealth,PindB);
AFoutLinNorm = CalAsymFunc(GCparam,GCresp, Fr1query, CompressionHealth,GCparam.AsymFunc_NormdB);

AFoutdB  = 20*log10(AFoutLin/AFoutLinNorm);
IOfuncdB = AFoutdB + PindB;

end

%% %%%%%%%%%%%

function [AFoutLin] = CalAsymFunc(GCparam,GCresp, Fr1query, CompressionHealth,PindB)
[~,nch] = min(abs(GCparam.Fr1 - Fr1query)); % choosing the closest number nch of Fr1 in the GCFB
Fp1 = GCresp.Fp1(nch);
frat = GCresp.frat0Pc(nch) + GCresp.frat1val(nch).*( PindB - GCresp.PcHPAF(nch));  %中心からの係数変化
Fr2 = frat*Fp1;
[dummy, ERBw2] =   Freq2ERB(Fr2); % definition of  HPAF

b2E = GCresp.b2val(nch)*ERBw2;
c2CH = CompressionHealth*GCresp.c2val(nch);

AFoutLin = exp(c2CH*atan2(Fp1 - Fr2,b2E)); %c2にcompression health

end


%% %%%%%%%%%%
% Trash
%%%%%%%%%%%%

% GCparam.AsymFunc_NormdB = 48.9908; % これでおこなう必然性なし。Pc中心。　Pc = (1 - GCparam.frat(1,1))/GCparam.frat(2,1) = 48.9908
%  GCparam.AsymFunc_NormdB = 200; % Infとほぼ同じ いまいち
% GCparam.AsymFunc_NormdB = 48.9908; % 中心にもってくるなら、== GCresp.PcHPAF(nch) 
% GCparam.AsymFunc_NormdB = 53.7; % 


%                  PinShiftdB: shift of AsymFuncInOut
% if nargin < 6, PinShiftdB = 0; end;
% GCparam.AsymFunc_ShiftdB = PinShiftdB; % 関数を入力音圧方向にshiftするdB値。
