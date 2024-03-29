%
%	Correction of ELC, MAF, MAP
%	IRINO Toshio
%	Created: 18 Mar 96
%	Modified: 29 Aug 96 	renamed AFShapeCrct -> OutMidCrct
%	Modified: 14 May 97 	option of Direct Output
%	Modified: 21 Apr. 2006    (note: Sampling rate >= 32000)
%	Modified: 22 Mar 2007    (adding MiddleEar SR->fs)
%	Modified:  2 Apr 2009   (adding ER-4B impulse response)
%	Modified: 19 Feb 2012   (checked:  correspondence f1 -- ELC )
%	Modified: 20 Apr 2016   (Changed notation to avoid confusion. CrctdB--> FreqChardB_forCmpnst. 
%                            CrctTbl --> TblFreqChar. Adding Figure axis name)
%	Modified: 20 Apr 2016   (FreqChardB_forCmpnst-> FreqChardB_ToBeCmpnstd)
%   Modified: 17 Oct 2017    Adding note about TransFuncField2Cochlea.m
%   Modified: 24 Jul 2021    Add SwInterp: Select interpolation method  --> linear interp on log freq scale
%
%
%	It produces interpolated points for the ELC/MAF/MAP/MidEar correction.
%
%	Reference:
%	Glassberg and Moore (1990)
%	"Derivation of auditory filter shapes from notched noise data"
%	Hearing Research, 47 , pp.103-138.
%
%	function [CrctLinPwr, freq, FreqChardB_toBeCmpnstd] = OutMidCrct(StrCrct,NfrqRsl,fs);
%	INPUT	StrCrct: String for Correction ELC/MAF/MAP/MidEar/ER4B      
%		NfrqRsl  Number of data points, if zero, then direct out.
%		fs: 	 Sampling Frequency
%		SwPlot:  Switch for plot
%       SwInterp:  Switch for interporation method ( 24 Jul 2021)
%	OUTPUT  CrctLinPwr : Correction value in LINEAR POWER 
%                        This is defined as:  CrctLiPwr =10^(-FreqChardB_toBeCmpnstd/10); 
%		freq:   Corresponding Frequency at the data point
%		FreqChardB_toBeCmpnstd: Frequency char of ELC/MAP... dB to be compensated for filterbank
%                            (defined By Glassberg and Moore.)
%
%
%    Note: 新しい関数TransFuncField2Cochlea.m が Dec 16にできた。
%               help TransFuncField2Cochlea
%             これには、以下のoptionもあり、MidEar のMooreデータはupdateされている。
%           TypeField2EarDrumList = {'FreeField2EarDrum_Moore16'; ...
%           'DiffuseField2EarDrum_Moore16'; ...
%           'HD580_L_AMLAB15';'HD580_R_AMLAB15'; ...
%           'HD650_L_AMLAB16';'HD650_R_AMLAB16'; ...
%           };%
%
%  Note 24 Jul 2021
%   2017までのversionでは、splineで補完していた。しかし、Spline関数は必ずしもよくない。また、MAPで125Hz以下の特性がはずれすぎ。
%   もっとも簡単にlog10(freq)の上で、Linearで補完。この方が素直だと思われる。100Hz以上ではほとんど影響がない。従来からのcompativilityのため、
%   SwInterpをいれて制御する。
% 
%
function [CrctLinPwr, freq, FreqChardB_toBeCmpnstd] = OutMidCrct(StrCrct,NfrqRsl,fs,SwPlot, SwInterp);

if nargin < 1, help OutMidCrct; end
if nargin < 2, NfrqRsl = []; end
if length(NfrqRsl) == 0
    NfrqRsl = 0;
end
if nargin < 3, fs = []; end 
if length(fs) == 0
    fs = 32000;    % なぜか、こうなっていた.　そのまま。実害なし。 24 Jul 21
end
if nargin < 4, SwPlot = []; end 
if length(SwPlot) == 0
    SwPlot == 1;
end
if nargin < 5, SwInterp = []; end
if length(SwInterp) == 0
    SwInterp = 1;  %  Original Spline interp.
end 


if  strcmp(upper(StrCrct),'ER4B') == 1,   % ER4B
  [CrctLinPwr, freq, FreqChardB_toBeCmpnstd] = OutMidCrct_ER4B(NfrqRsl,fs,SwPlot);
  return;
end;

%%%% Conventional ELC/MAF/MinEar %%%

%f1a = [	20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, ...
%	125, 150, 177, 200, 250, 300, 350, 400, 450, 500, 550, ...
%	600, 700, 800, 900, 1000, 1500, 2000, 2500, 2828, 3000, ...
%	3500, 4000, 4500, 5000, 5500, 6000, 7000, 8000, 9000, 10000, ...
%	12748, 15000];

f1 = [	20,   25,  30,     35,  40,    45,  50,   55,   60,   70, ...         % 1-10
        80,   90,  100,   125,  150,   177, 200,  250,  300,  350, ...        % 11-20
        400,  450, 500,   550,  600,   700, 800,  900,  1000, 1500, ...      % 21-30
        2000, 2500, 2828, 3000, 3500, 4000, 4500, 5000, 5500, 6000, ...  %31-40
        7000, 8000, 9000, 10000, 12748, 15000];   % 41-46
 
ELC = [ 31.8, 26.0, 21.7, 18.8, 17.2, 15.4, 14.0, 12.6, 11.6, 10.6, ...
	   9.2, 8.2, 7.7, 6.7, 5.3, 4.6, 3.9, 2.9, 2.7, 2.3, ...
       2.2, 2.3, 2.5, 2.7, 2.9, 3.4, 3.9, 3.9, 3.9, 2.7, ...
       0.9, -1.3, -2.5, -3.2, -4.4, -4.1, -2.5, -0.5, 2.0, 5.0, ...
	   10.2, 15.0, 17.0, 15.5, 11.0, 22.0];

MAF = [ 73.4, 65.2, 57.9, 52.7, 48.0, 45.0, 41.9, 39.3, 36.8, 33.0, ...
	29.7, 27.1, 25.0, 22.0, 18.2, 16.0, 14.0, 11.4, 9.2, 8.0, ...
	 6.9,  6.2,  5.7,  5.1,  5.0,  5.0,  4.4,  4.3, 3.9, 2.7, ...
	 0.9, -1.3, -2.5, -3.2, -4.4, -4.1, -2.5, -0.5, 2.0, 5.0, ...
	10.2, 15.0, 17.0, 15.5, 11.0, 22.0]; 

f2  = [  125,  250,  500, 1000, 1500, 2000, 3000,  ...
	4000, 6000, 8000,10000,12000,14000,16000];

MAP = [ 30.0, 19.0, 12.0,  9.0, 11.0, 16.0, 16.0, ...
	14.0, 14.0,  9.9, 24.7, 32.7, 44.1, 63.7];

% MidEar Correction (little modification at 17000:1000:20000)
f3 =  [   1   20   25  31.5    40    50    63    80   100   125 ...
          160  200  250   315   400   500   630   750   800  1000 ...
         1250 1500 1600  2000  2500  3000  3150  4000  5000  6000 ...
         6300 8000 9000 10000 11200 12500 14000 15000 16000  20000];

MID =  [  50   39.15 31.4 25.4 20.9,18,  16.1 14.2 12.5 11.13 ...
          9.71 8.42  7.2  6.1  4.7  3.7  3.0  2.7  2.6  2.6 ...
          2.7  3.7   4.6  8.5 10.8  7.3  6.7  5.7  5.7  7.6 ...
          8.4 11.3, 10.6  9.9 11.9 13.9 16.0 17.3 17.8  20.0];

%%%%

frqTbl = [];
TblFreqChar = [];
switch upper(StrCrct)
  case {'ELC'}
   frqTbl = f1(:); TblFreqChar = ELC(:);  ValHalfFs = 130;
  case {'MAF'}
   frqTbl = f1(:); TblFreqChar = MAF(:);  ValHalfFs = 130;
  case {'MAP'}
   frqTbl = f2(:); TblFreqChar = MAP(:);  ValHalfFs = 180;
  case {'MIDEAR'}  % mid ear correction
   frqTbl = f3(:); TblFreqChar = MID(:);  ValHalfFs = 23;
  case {'NO'}
  otherwise
   error('Specifiy correction: ELC / MAF / MAP / MidEar or NO correction.');
end;

%%%% Additional dummy data for high sampling freq. %%%
if fs > 32000,
    frqTbl = [frqTbl;  fs/2];
    TblFreqChar = [TblFreqChar;  ValHalfFs];
    [frqTbl indx] = unique(frqTbl);
    TblFreqChar = TblFreqChar(indx); 
end;

str1 = '';
if NfrqRsl <= 0,
  str1 = 'No interpolation. Output: values in original table.';
  freq = frqTbl; 
  FreqChardB_toBeCmpnstd = TblFreqChar; 
else
  freq = (0:NfrqRsl-1)'/NfrqRsl * fs/2;
  if strcmp(upper(StrCrct(1:2)), 'NO'),
    FreqChardB_toBeCmpnstd = zeros(size(freq));
  else
    str1 = 'Spline interpolated value in equal frequency spacing.';
    if SwInterp == 1  % original version
        FreqChardB_toBeCmpnstd = spline(frqTbl,TblFreqChar,freq);	
    elseif SwInterp == 2  % Added 24 Jul 2021
        FreqChardB_toBeCmpnstd = interp1(log10(frqTbl),TblFreqChar,log10(freq),'linear','extrap');	 % linear interp on log scale
    else
        error('Specify SwInterp');
    end
  end;
end;

if SwPlot == 1, 
   str = ['*** Frequency Characteristics ( ' ...
		upper(StrCrct) ') : Its inverse will be corrected. ***'];
   disp(str);
   disp(str1);
   h = plot(frqTbl,TblFreqChar,freq,FreqChardB_toBeCmpnstd,'--'); 
   title(str);
   xlabel('Frequency (Hz)');
   ylabel('Level (dB)');
end;

CrctLinPwr = 10.^(-FreqChardB_toBeCmpnstd/10); 	% in Linear Power. Checked 19 Apr 2016

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% EarPhone Correction ER-4B %%%%
function [CrctLinPwr, freq, FreqChardB_toBeCmpnstd] = OutMidCrct_ER4B(NfrqRsl,fs,SwPlot);

DirEarPhone = [getenv('HOME') '/Data/Measurement/MsrRsp_ER-4B_9Feb09/'];
NameImpRsp = 'TSP48-24_ImpRsp1.wav';
[ImpRspEP,fsEP,Nbit] = wavread([DirEarPhone NameImpRsp]);
ImpRspEP = ImpRspEP(1024:end);
if fsEP ~= fs,
 ImpRspEP = resample(ImpRspEP, fs, fsEP);
end;

[Frsp, freq] = freqz(ImpRspEP,1,NfrqRsl,fs);
CrctLinPwr = abs(Frsp.^2);
FreqChardB_toBeCmpnstd = -10*log10(CrctLinPwr);  % It is inverse. Checked

if SwPlot == 1,
  plot(freq,FreqChardB_toBeCmpnstd);
end;

return;
