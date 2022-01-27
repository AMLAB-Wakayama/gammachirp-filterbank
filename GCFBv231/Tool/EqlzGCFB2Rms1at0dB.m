%
%    Normalizing output level of GCFB as  Absolute threshold 0dB == rms of 1
%    Irino, T.
%   Created:   27 Jan 2022 
%   Modified:  27 Jan 2022
%
%   GCreAT = EqlzGCFB2Rms1at0dB(GCval,StrFloor)
%       INPUT:        GCval : the output of GCFBv231  rms(snd) == 1 -->  30 dB
%                          StrFloor:   'AddNoise'  adding Gauss noise     (rms(randn)==1)
%                                            'FloorZero'  set 0 for the value less than 1
%       OUTPUT:    GCreAT :   GC relative to AbsThreshold 0dB ( rms(snd) ==  1 --> 0 dB)
%  
%   Note:
%     Snd --> Eqlz2MeddisHCLevel --> GCFB 
%           GC output level is the same as the MeddisHCLevel as shown below.
%      This function converts the level from MeddisHCLevel  to  
%           rms(s(t)) == sqrt(mean(s.^2)) == 1   --> 0 dB
%      Use this when the absolute threshold is set to 0 dB as in GCFBv231.
%      GCFB --> EqlzGCFB2Rms1at0dB  --> GCFBeqlz 
% 
function GCreAT = EqlzGCFB2Rms1at0dB(GCval,StrFloor)

MeddisHCLeveldB_RMS1 = 30;  % used in GCFB level set
GCreAT  = 10^(MeddisHCLeveldB_RMS1/20)*GCval;

if nargin > 1
    if strcmp(StrFloor,'AddNoise' ) == 1
        GCreAT = GCreAT + randn(size(GCreAT));  % adding  gauss noise
    elseif strcmp(StrFloor,'FloorZero' ) == 1
        GCreAT = max(GCreAT-1,0);   % cutoff value less than 1
    end
end

end


%%%  for reference %%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Eqlz2MeddisHCLevel
%%%%%%%%%%%%%%%%%%%%%%%%%
%    Created:   9 Jun. 2004
%    Modified:  9 Jun. 2004
%    Modified:  23 Sept 2005 (remove fs. fs has been remained for some reason.)
%  Eqlz2MeddisHCLevel(Snd,fs,OutLeveldB) --> Eqlz2MeddisHCLevel(Snd,OutLeveldB)
%
%    function [SndEqM, AmpdB] = Eqlz2MeddisHCLevel(Snd,OutLeveldB);
%    INPUT  Snd: input sound
%           OutLeveldB : Output level (No default value,  RMS level)
%
%    OUTPUT SndEqM: Equalized Sound (rms value of 1 is 30 dB SPL)
%           AmpdB: 3 values in dB 
%                  [OutputLevel_dB, CompensationValue_dB, SourceLevel_dB]
%
% Ref: Meddis (1986), JASA, 79(3),pp.702-711.
%
% rms(s(t)) == sqrt(mean(s.^2)) == 1   --> 30 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 10  --> 50 dB SPL
% rms(s(t)) == sqrt(mean(s.^2)) == 100 --> 70 dB SPL
%
