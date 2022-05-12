%
%       Set Tools of GCFB for standalone processing
%       IRINO T.
%       Created:   11 Sep 2021
%       Modified:  11 Sep 2021
%       Modified:  19 Sep 2021
%       Modified:  30 Sep 2021
%       Modified:    9 Oct 2021
%       Modified:  24 Oct 2021
%       Modified:  27 Jan 2022  introducing EqlzGCFB2Rms1at0dB;
%
%
DirProg = fileparts(which(mfilename));
NameProg = DirProg(max(strfind(DirProg,'GCFB')):end);
disp(['+++  ' NameProg ' +++'])
cd(DirProg)
DirTool = [DirProg  '/'];
% if exist(DirTool) == 0
%     mkdir(DirTool)
% end
DirMAT = [getenv('HOME') '/m-file/'];
DirSource1 = [DirMAT 'Auditory/GCTool/'];
NameFile1     ={'ACFilterBank.m', 'AsymCmpFrspV2.m', 'CmprsGCFrsp.m' ...
    'Fpeak2Fr.m', 'Fr2Fpeak.m', 'Fr1toFp2.m', 'Fp2toFr1.m', ...
    'GammaChirp.m', 'GammaChirpFrsp.m', 'MakeAsymCmpFiltersV2.m', ...
    'MkCalibTone4AFB.m', 'Eqlz2MeddisHCLevel.m', 'EqlzGCFB2Rms1at0dB', ...
    'ReadmeFirst.m', 'Readme_SignalLevel4GCFB.m', 'Readme_License.m','README.md'};
for nFile = 1:length(NameFile1)
    if exist([DirTool char(NameFile1(nFile))]) == 0
        str = ['cp  -p -f ' DirSource1 char(NameFile1(nFile)) '   "' DirTool '" '];
        disp(str); unix(str);
        pause(0.1);
    else
        disp(['File exists: ' char(NameFile1(nFile)) ' --- Remove it in advance if replacement is necessary.' ]);
    end
end

disp(' ')
DirSource2 = [DirMAT '/Auditory/ERBTool/'];
NameFile2 = {'Freq2ERB.m', 'ERB2Freq.m', 'EqualFreqScale.m', 'Filter2ERB.m', ...
        'HL2SPL.m','HL2PinCochlea.m','SPLatHL0dB_Table.m',...
        'MkFilterField2Cochlea.m', 'OutMidCrct.m', ...
        'TransFuncField2Cochlea.m','TransFuncField2EarDrum_Set.m', ...
        'TransFuncMiddleEar_Moore16.m'};
 for nFile = 1:length(NameFile2)
    if exist([DirTool char(NameFile2(nFile))]) == 0
        str = ['cp  -p -f ' DirSource2 char(NameFile2(nFile)) '   "' DirTool '" '];
        disp(str); unix(str);
        pause(0.1);
    else
        disp(['File exists: ' char(NameFile2(nFile))  ' --- Remove it in advance if replacement is necessary.' ]);
    end  
 end

 % not used: , 'testOutMidCrct.m' 'OutMidCrctFilt.m', 'testOutMidCrctFilt.m'
    
str = ['cp  -p -f ' DirMAT '/Auditory/GCApl/CalSmoothSpec.m    "' DirTool '" '];
    disp(str); unix(str);
str = ['cp  -p -f ' DirMAT '/Auditory/GCApl/DistanceSpecShift.m    "' DirTool '" ']; % 4 Nov 21
    disp(str); unix(str);
str = ['cp  -p -f ' DirMAT '/Signal/Filter/TaperWindow.m   "' DirTool '" '];
    disp(str); unix(str);
str = ['cp  -p -f ' DirMAT '/Signal/Filter/SetFrame4TimeSequence.m    "' DirTool '" '];
    disp(str); unix(str);
str = ['cp  -p -f ' DirMAT '/Tool/Plot/printi.m    "' DirTool '" '];
    disp(str); unix(str);
     
    
%% %%%
%  Trash
%%%%%%
% str = ['cp  -p -f ' DirMAT '/PDS/SlaneyTB/MeddisHairCell.m   "' DirTool '" '];
%     disp(str); unix(str);
% str = ['cp  -p -f ' DirMAT '/PDS/SlaneyTB/testMeddisHairCell.m   "' DirTool '" '];
%     disp(str); unix(str);


