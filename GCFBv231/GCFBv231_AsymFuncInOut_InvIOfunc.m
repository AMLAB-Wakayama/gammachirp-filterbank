%      Calculate GC Hearing Loss from GCFBv230  -- Inverse IOfunc
%      逆関数　IOfuncdB　--> PindB
%       Irino, T.
%       Created:  15 Aug 2021  extracted from GCFBv230_AsymFuncInOut
%       Modified:  15 Aug 2021
%       Modified:  17 Aug 2021 using Fr1query -- NOT Fp1
%       Modified:  18 Aug 2021 
%       Modified:  28 Aug 2021 v231
%       Modified:   2  Sep 2021 v231
%
%    function [PindB] = GCFBv230_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CmprsHlthQuery,IOfuncdB)
%       INPUT: GCparam,GCresp,Fr1query,CmprsHlthQuery,IOfuncdB
%       OUTPUT: PindB
%
%
function [PindB] = GCFBv231_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CmprsHlthQuery,IOfuncdB)
% tic
PindBList = -120:0.1:150;  % It is necessary to use such a wide range. (sometime it exceeds 120)
[dummy, IOfuncdBlist] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1query,CmprsHlthQuery,PindBList);
PindB = interp1(IOfuncdBlist,PindBList,IOfuncdB);    % vq = interp1(x,v,xq)

return


%% %%%%%%%%%
% Trash
%%%%%%%%%%%%
% IOfuncdBlist(1:3)
% length(find(isnan(PindB)))
% toc

%
%  Tableを作ったが、CmprsHlthQueryがわかっているなら作る必要ない。
% 
% PindBList = [-30:0.1:120];
% CmprsHlthList = [1:-0.01:0];
% if length(TableIOfunc) == 0
%     disp(['Making lookup table in ' mfilename]);
%     for nCH = 1:length(CmprsHlthList)
%         [dummy TableIOfunc(nCH,:)] = GCFBv230_AsymFuncInOut(GCparam,GCresp,Fr1query,CmprsHlthList(nCH),PindBList);
%     end
% end
% 
% [~, nCHquery] = min(abs(CmprsHlthList-CmprsHlthQuery));   % 一番近いnCHを求める。一番使うのは1なので、精度はこれで十分
% 
% PindB = interp1(TableIOfunc(nCHquery,:),PindBList,IOfuncdB);
% 

% 収束計算では１点ずつ計算せざるを得ず、時間がかかる


% function [PindBest] = GCFBv230_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CompressionHealth,IOfuncdB)
%     global Param4InvIOfunc    % parameter 引き渡しのため
%     Param4InvIOfunc{1} = GCparam;
%     Param4InvIOfunc{2} = GCresp;
%     Param4InvIOfunc{3} = Fr1query;
%     Param4InvIOfunc{4} = CompressionHealth;
%     Param4InvIOfunc{5} = IOfuncdB;
%     
%     PindBinit = IOfuncdB - 20;
%     PindBest = fminsearch(@OptimFunc4InvIOfunc,PindBinit);
%     
%     clear global Param4InvIOfunc  % 終了後、消しておく
% end
% 
% function ErrVal = OptimFunc4InvIOfunc(PindB)
%     global Param4InvIOfunc
%     GCparam = Param4InvIOfunc{1};
%     GCresp    = Param4InvIOfunc{2};
%     Fr1query  = Param4InvIOfunc{3};
%     CompressionHealth    = Param4InvIOfunc{4};
%     IOfuncdB   = Param4InvIOfunc{5};
%     
%     [dummy, IOfuncdBEst] = GCFBv230_AsymFuncInOut(GCparam,GCresp,Fr1query,CompressionHealth,PindB);
%     ErrVal = (IOfuncdB - IOfuncdBEst)^2;
% end



