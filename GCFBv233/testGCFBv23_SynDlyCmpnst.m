%
%       Test GCFBv23x Synthesis & Delay compensation
%       Toshio IRINO
%       Created:   28 Feb 2021
%       Modified:  28 Feb 2021
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%       Modified:  20 Mar 2022  v302  <--- GCFBv233  to avoid misleading  HL_OHC --> HL_ACT, HL_IHC --> HL_PAS
%       Modified:  20 Mar 2022  v233 introduction of GCFBv23x
%
%
clf
DirProg = fileparts(which(mfilename)); % Directory of this program
DirSnd = [DirProg '/'];
NameSnd = ['Snd_Hello123'];
[Snd1, fs1] = audioread([DirSnd NameSnd '.wav']);
Snd = Snd1(:)'; fs = fs1;


%%%%%%
GCparam.fs     = fs;
GCparam.NumCh  = 100;
GCparam.FRange = [100, 12000];
%GCparam.FRange = [100, 8000];
GCparam.OutMidCrct = 'ELC';
% GCparam.OutMidCrct = 'NO';
GCparam.DynHPAF.StrPrc = 'frame';
GCparam.Ctrl = 'dynamic';
GCparam.HLoss.Type = 'NH';
[Snd, AmpdB] =  Eqlz2MeddisHCLevel(Snd,60);

[dcGCframe, scGCsmpl,GCparam,GCresp] = GCFBv23x(Snd,GCparam);
DCparam.fs = GCparam.fs;
[scGCsmplDC] = GCFBv23_DelayCmpnst(scGCsmpl,GCparam,DCparam);
SndSyn = GCFBv23_SynthSnd(scGCsmplDC,GCparam);

Snd = 10^(-AmpdB(2)/20)*Snd;
SndSyn = 10^(-AmpdB(2)/20)*SndSyn;
ap = audioplayer(Snd,fs);
ap1 = audioplayer(SndSyn,fs);

playblocking(ap);
playblocking(ap1);

RatiodB = 20*log10(rms(SndSyn)/rms(Snd))
DiffdB = 20*log10(rms(SndSyn-Snd)/rms(Snd))
 

%% %%%%%%%%%
subplot(3,1,1)
imagesc(scGCsmplDC);
set(gca,'YDir','normal');

subplot(3,1,2)
LenSnd = length(Snd);
plot(1:LenSnd,Snd, 1:LenSnd,SndSyn)
axis([0 400 -2 2])

subplot(3,1,3)
[frsp,freq] = freqz(Snd,1,1024,fs);
[frsp1,freq] = freqz(SndSyn,1,1024,fs);
semilogx(freq,10*log10(abs(frsp)),freq,10*log10(abs(frsp1)));
% axis([50 20000 -50 5]);
grid on;



%% %%%%%%

% SwSynMethod = 1;
% SndSyn = GCFBv230_SynSnd(scGCsmplDC,GCparam,SwSynMethod);

