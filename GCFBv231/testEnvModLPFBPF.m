%
%  Envelop domain LPF + BPF
%  Irino, T
%  Created: 14 Feb 2021
%  Modified: 14 Feb 2021
%
fs = 2000;
fcLPF = 1;
nOrder = 2;
[bzLPF, apLPF] = butter(nOrder,fcLPF/(fs/2));
[bzHPF, apHPF] = butter(nOrder,fcLPF/(fs/2),'high');

[frspL freq] = freqz(bzLPF,apLPF,1024,fs);
[frspH freq] = freqz(bzHPF,apHPF,1024,fs);

figure(1);
plot(freq,20*log10(abs(frspL)),freq,20*log10(abs(frspH)))
grid on;
axis([0 10 -50 5])
xlabel('Frequency (Hz)');
ylabel('Gain (dB)');

%%%%% response
figure(2);
LenSnd = 4000;
Snd = ones(1,4000);
Snd = [ zeros(1,20), 1, zeros(1,LenSnd-21)];
SndH = filter(bzHPF,apHPF,Snd);
 mean(SndH)
 20*log10(abs(mean(SndH))/abs(mean(Snd)))

SndL = filter(bzLPF,apLPF,Snd);
 mean(SndL)
 20*log10(abs(mean(SndL))/abs(mean(Snd)))

 plot(1:LenSnd,SndH, 1:LenSnd,SndL,1:LenSnd,SndL+SndH);
 
