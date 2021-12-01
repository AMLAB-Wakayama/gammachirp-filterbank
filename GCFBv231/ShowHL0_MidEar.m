%
%   Plot Freq Resp of OutMid
%    Irino, T.
%   Created: 24 Jan 21
%   Modified: 24 Jan 21
%   Modified: 14 Sep 21
%

close all
DirProg = fileparts(which(mfilename)); % Ç±ÇÃÉvÉçÉOÉâÉÄÇ™Ç†ÇÈÇ∆Ç±ÇÎ
DirFig = [DirProg '/Fig/'];


fcList = [125 *2.^(0:6)]
[HL0 ] = HL2SPL(fcList,zeros(1,7))
[fME, ME ] = TransFuncMiddleEar_Moore16(fcList)

ME+HL0
GCparam.OutMidCrct = 'ELC';

fs = 48000;
CmpnOutMid = OutMidCrctFilt(GCparam.OutMidCrct,fs,0,2); 
[frsp freq] = freqz(CmpnOutMid , 1, 1024,fs);

semilogx(freq,20*log10(abs(frsp)), fME, ME,'--*',fcList,-HL0,'-.x', fcList,-HL0-ME,'-.^')
grid on;
xlabel('Freq (Hz)');
ylabel('Level (dB)');
axis([0 fs/2 -45 10]);
legend('ELC','MidEar','HL0@EarDrum','HL0@CP','Location','NorthWest');

printi(3,0,1);
print([DirFig, 'Fig_HL0_ELC_MidEar.eps'],'-depsc','-tiff');



