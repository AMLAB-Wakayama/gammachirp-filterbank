%
%       Dynamic Compressive Gammachirp Filterbank
%       Toshio IRINO
%       Created:   20 Mar 2022   % 
%       Modified:   20 Mar 2022   % 
%
%       This program is a wrapping function to the latest version of GCFB.
%       It makes maintainace easier.
%
function [dcGCout, scGCsmpl, GCparam, GCresp] = GCFBv23x(SndIn,GCparam)

% The latest version here
 [dcGCout, scGCsmpl, GCparam, GCresp] = GCFBv233(SndIn,GCparam);

 end