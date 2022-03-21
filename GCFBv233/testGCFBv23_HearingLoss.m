%
%       test GCFBv230_HearingLoss
%       Irino T.,
%       Created: 21 May 20
%       Modified: 21 May 20
%       Modified: 22 May 20
%       Modified: 19 Jul 20
%       Modified:  24 Jan 2021 (InternalCmpnstLeveldB = -7, FactCmpnst --> OK)
%       Modified:  28 Aug 2021 v231
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%
%

%%%% Stimuli : a simple pulse train %%%%
DirProg = fileparts(which(mfilename)); % Directory of this program
DirFig = [DirProg '/Fig/'];

if exist('GCresp') == 0
    testGCFBv233
end

figure(1); clf
GCparam.HLoss.Type = 'NH';
GCparam.HLoss.Type = 'HL2';

CHlist = [1 0.5 0];
for nCH = 1:length(CHlist)
    GCparam.HLoss.CompressionHealth = CHlist(nCH);
    
    tic;
    [GCparam] = GCFBv23_HearingLoss(GCparam, GCresp);
    toc;
    % GCparam.HLoss
    subplot(2,2,nCH)
    [NameFig] =  GCFBv23_HearingLoss_ShowAudGram(GCparam);
    
end

NameFig
printi(3,0,2);
print([DirFig  NameFig '_All' ] ,'-depsc','-tiff');



