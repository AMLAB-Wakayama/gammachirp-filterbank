%
%      startup m-file of GCFBv231. 
%      IRINO T.
%      Created:    14 Sep 2021
%      Modified:   14 Sep 2021
%      Modified:   22 Jan 2022  % defined as a function not to overwrite  DirProg
%
%      Setting path at least once before starting GCFB programs
%   
function DirProg = StartupGCFB

DirProg = fileparts(which(mfilename)); % Directory of this program
addpath([DirProg '/Tool/']);    

% mfilename
% DirProg

end