%
%   testEqlz2MeddisHCLevel
%   Irino, T. 
%   Created: 6 Mar 2022
%   Modified: 6 Mar 2022
%
%

SndSPLdB = 65;
CalibToneRmsLeveldB =  -26; % relative to rms = 1
InputRms1SPLdB = SndSPLdB-CalibToneRmsLeveldB;

%rng(123)
Snd0 = randn(1,1000);
Snd0 = Snd0/rms(Snd0); % rms = 1;
Snd = 10^(CalibToneRmsLeveldB/20)*Snd0;

[SndEq1, AmpdB1] = Eqlz2MeddisHCLevel(Snd,SndSPLdB);
AmpdB1 
[SndEq2, AmpdB2] = Eqlz2MeddisHCLevel(Snd,[],InputRms1SPLdB);
AmpdB2

nn = 0:length(Snd)-1;

plot(nn,SndEq1,nn,SndEq2+100, nn,SndEq1-SndEq2)

rms(SndEq1-SndEq2)