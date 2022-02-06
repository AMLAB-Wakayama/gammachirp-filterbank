%
%       Test GCFBv230 Synthesis & Delay compensation
%       Toshio IRINO
%       Created:   28 Feb 2021
%       Modified:  28 Feb 2021
%
%
clf
%%%% Stimuli : a simple pulse train %%%%
fs = 48000;
Tsnd = 0.1; % sec
Snd = [zeros(1,200), 1, zeros(1,Tsnd*fs-1)];
DirSnd = [getenv('HOME') '/tmp/'];
NameSnd = ['Snd_Konnichiwa_Orig'];
NameSnd = ['Snd_Konnichiwa'];
[Snd1 fs1] = audioread([DirSnd NameSnd '.wav']);
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
[Snd AmpdB] =  Eqlz2MeddisHCLevel(Snd,60);

[dcGCframe, scGCsmpl,GCparam,GCresp] = GCFBv230(Snd,GCparam);
DCparam.fs = GCparam.fs;
[scGCsmplDC] = GCFBv230_DelayCmpnst(scGCsmpl,GCparam,DCparam);
SndSyn = GCFBv230_SynSnd(scGCsmplDC,GCparam);

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

