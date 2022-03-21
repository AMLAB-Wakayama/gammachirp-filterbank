%      Calculate GC Hearing Loss from GCFBv230  -- Inverse IOfunc
%      逆関数　IOfuncdB　--> PindB
%       Irino, T.
%       Created:  15 Aug 2021  extracted from GCFBv230_AsymFuncInOut
%       Modified:  15 Aug 2021
%       Modified:  17 Aug 2021 using Fr1query -- NOT Fp1
%       Modified:  18 Aug 2021 
%       Modified:  28 Aug 2021 v231
%       Modified:   2  Sep 2021 v231
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%
%    function [PindB] = GCFBv23_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CmprsHlthQuery,IOfuncdB)
%       INPUT: GCparam,GCresp,Fr1query,CmprsHlthQuery,IOfuncdB
%       OUTPUT: PindB
%
%
function [PindB] = GCFBv23_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CmprsHlthQuery,IOfuncdB)
% tic
PindBList = -120:0.1:150;  % It is necessary to use such a wide range. (sometime it exceeds 120)
[~, IOfuncdBlist] = GCFBv23_AsymFuncInOut(GCparam,GCresp,Fr1query,CmprsHlthQuery,PindBList);
PindB = interp1(IOfuncdBlist,PindBList,IOfuncdB);    % vq = interp1(x,v,xq)

return


