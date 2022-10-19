%
%      startup m-file of GCFBv231. 
%      IRINO T.
%      Created:    14 Sep 2021
%      Modified:   14 Sep 2021
%      Modified:   22 Jan 2022  % defined as a function not to overwrite  DirProg
%      Modified:   6  Mar 2022  v232  
%      Modified:   8  Sep 2022  v234
%
%      Setting path at least once before starting GCFB programs
%   
function DirGCFB = StartupGCFB

DirGCFB = fileparts(which(mfilename)); % Directory of this program
addpath([DirGCFB '/Tool/']);    

% if you need a m-file in Misc
% addpath([DirGCFB '/Misc/']);    

end