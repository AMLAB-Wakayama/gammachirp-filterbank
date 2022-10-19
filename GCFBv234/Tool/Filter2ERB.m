%
%	Calculate ERB for Filter Response
%	IRINO Toshio
%	31 Mar. 1993
%	6  Apr. 1995 (Renamed CalERB-> Filter2ERB)
%	20 Feb 2021 (Adding BW_10dB)
%
%	function [ERBw, Fpeak, BW_3dB] =  ...
%			Filter2ERB(Filter,SR,SwPlot, verbose),
%	INPUT	Filter  : FIR Filter Response 
%		SR	: Sampling Rate
%		SwPlot	: 0) Linear Freq & Linear Amp : default 
%			  1) Linear Freq & dB Amp
%			  2) Log Freq & dB Amp
%			  -1) Suppress Plot
%	OUTPUT	ERBw	: ERB Width (Hz)
%		Fpeak 	: Peak Frqeuncy (Hz)
%		BW_3dB  : -3dB Bandwidth (Hz)
%		BW_10dB  : -10dB Bandwidth (Hz)   20 Feb 2021
%				
%
function [ERBw, Fpeak, BW_3dB, BW_10dB] =  Filter2ERB(Filter,SR,SwPlot, verbose),

if nargin < 1; help Filter2ERB; end;
if nargin < 3; SwPlot=0; end;

LenFilt = length(Filter);
LenFFT = 2^(ceil(log(LenFilt)/log(2)));
if LenFFT < 1024*4; LenFFT = 1024*4; end;
[Frsp freq] = freqz(Filter,1,LenFFT,SR);
FrspAbs = abs(Frsp);
[PeakVal PeakNum] = max(FrspAbs);
Fpeak = freq(PeakNum);
Pwr = sum(FrspAbs.^2)*(freq(2)-freq(1));
ERBw = Pwr/PeakVal^2;
Frct = 10^(-10)*ones(size(FrspAbs));
kk = find( freq >= Fpeak-ERBw/2 & freq <= Fpeak+ERBw/2);
Frct(kk) = PeakVal*ones(size(kk));

FrspdB = 20*log10(FrspAbs/max(FrspAbs));
kk = find(FrspdB >= -3.05); % -3dB;
Frsp_3dB = FrspAbs(min(kk));
BW_3dB = freq(max(kk)) - freq(min(kk));

kk10 = find(FrspdB >= -10); % -10 dB;
BW_10dB = freq(max(kk10)) - freq(min(kk10));


%plot(freq,FrspAbs,freq,Frct,'--')
if SwPlot >= 0,
ff = [min(freq) max(freq)];
dd = [Frsp_3dB Frsp_3dB];

if SwPlot == 0,
	val1 = FrspAbs;
	val2 = Frct;
	val3 = dd;
	plot(freq,val1,freq,val2,'--',ff,val3,':');
	ylabel('Amplitude (Linear)');
else
	val1 = 20*log10(FrspAbs);
	val2 = 20*log10(Frct);
	val3 = 20*log10(dd);
	if SwPlot == 1,
		plot(freq,val1,freq,val2,'--',ff,val3,':');
		ax = axis;
		ax(4) = max(ceil(val1/10)*10);
		ax(3) = ax(4)-50;
		axis(ax)
	else
		semilogx(freq,val1,freq,val2,'--',ff,val3,':');
		ax = axis;
		ax(4) = max(ceil(val1/10)*10);
		ax(3) = ax(4)-50;
		axis([100 10000 ax(3:4)])
	end;
	ylabel('Amplitude (dB)');
end;

xlabel('Frequency (Hz)');

end;

Error = (Pwr - sum(Frct.^2)*(freq(2)-freq(1)))/Pwr;

%%%  Measured ERB : Moore & Glasberg %%%
% Fkhz = Fpeak/1000;
% MsdERBw = 6.23*Fkhz^2 + 93.39*Fkhz + 28.52;
% MsdERBRate = 11.17*log((Fkhz+0.312)/(Fkhz+14.675))+43.0;
[MsdERBw MsdERBRate] = Freq2ERB(Fpeak);

%%%  Display Results %%%
if exist('verbose') == 1,
disp(['Calculated  ERB : Fpeak = ' num2str(Fpeak) ...
	' (Hz)  ERB = ' num2str(ERBw) ' (Hz)' ...
	'   Error = ' num2str(Error)]);
disp(['Measured    ERBw : 6.23f^2+93.39f+28.52 = ' ...
	num2str(MsdERBw) ' (Hz)   ERBRate = ' num2str(MsdERBRate)]);
end;

