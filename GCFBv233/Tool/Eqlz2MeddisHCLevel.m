%    Equalizing Signal RMS Level to the Level for MeddisHairCell
%    Irino, T.
%    Created:     9 Jun 2004
%    Modified:    9 Jun 2004
%    Modified:  23 Sep 2005 remove fs. fs has been remained for some reason.)
%                                        Eqlz2MeddisHCLevel(SndIn,fs,OutLeveldB) --> Eqlz2MeddisHCLevel(SndIn,OutLeveldB)
%    Modified:   6 Mar 2022  Adding InputRms1SPLdB  (when the input SPL is already defined)
%
%    function [SndEqMds, AmpdB] = Eqlz2MeddisHCLevel(SndIn,OutLeveldB, InputRms1SPLdB);
%    INPUT  SndIn:                  input sound
%               OutLeveldB :         Output level (No default value,  RMS  level) :  convenventional method
%               InputRms1SPLdB:  SPL(dB) of input sound digital level  rms(s(t))=1 : This enables precise control of SPL.
%
%    OUTPUT SndEqMds: Equalized Sound (rms value of 1 is 30 dB SPL)
%                 AmpdB: 3 values in dB 
%                       [OutputLevel_dB, CompensationValue_dB, SourceLevel_dB]
%
% Ref: Meddis (1986), JASA, 79(3),pp.702-711.
%
% rms(s(t)) == sqrt(mean(s.^2)) == 1   --> 30 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 10  --> 50 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 100 --> 70 dB SPL
%
%
% Usage:   (when Snd SPL = 65 dB,  Reference level -26 dB re. rms=1)
%   1, Conventional:          [SndEqMds, AmpdB] = Eqlz2MeddisHCLevel(SndIn,65);
%   2, InputRms1SPLdB:    [SndEqMds, AmpdB] = Eqlz2MeddisHCLevel(SndIn,[],(65+26));
%
%
function [SndEqMds, AmpdB] = Eqlz2MeddisHCLevel(SndIn,OutLeveldB,InputRms1SPLdB)

if nargin < 2, help Eqlz2MeddisHCLevel; end

if nargin == 2  % conventional method 2004-
    SourceLevel = sqrt(mean(SndIn.^2))*10^(30/20); % level in terms of Meddis Level
    AmpCmpnst = (10^(OutLeveldB/20))/SourceLevel;
    SndEqMds = AmpCmpnst * SndIn; 

   %  AmpdB = [OutLeveldB  20*log10([AmpCmpnst, SourceLevel])];
    SourceLeveldB = 20*log10(SourceLevel);
    CmpnstdB = 20*log10(AmpCmpnst);
 
elseif nargin == 3 % more precise method 2022 - 
    if length(OutLeveldB) > 0
        help Eqlz2MeddisHCLevel
        error('You need set OutLevel = [] when using InputRms1SPLdB. --> See Usage')
    end

    SourceLeveldB = 20*log10(sqrt(mean(SndIn.^2)))+InputRms1SPLdB;
    OutLeveldB = SourceLeveldB; % It is invarient. Just signal rms level becomes MeddisHCLevel.

    CmpnstdB = InputRms1SPLdB-30;  % rms(s(t)) == 1 should become 30 dB SPL
    AmpCmpnst = (10^(CmpnstdB/20));
    SndEqMds = AmpCmpnst * SndIn; 

end

AmpdB = [OutLeveldB, CmpnstdB, SourceLeveldB];

end

%%%%%%%%%%%%%%%%
%% Trash 
%%%%%%%%%%%%%%%%

% if nargin < 3, OutLeveldB = []; end;  
% if length(OutLeveldB) == 0, OutLeveldB = 50; end; % for speech
% No default value! 
% if nargin > 2 | OutLeveldB > 120 % for checking inconsistency
%   disp('Eqlz2MeddisHCLevel was modified to take 2 input arguments. Sept2005.')
%     error('function [SndInEqMds, AmpdB] = Eqlz2MeddisHCLevel(SndIn,OutLeveldB)');
% end
