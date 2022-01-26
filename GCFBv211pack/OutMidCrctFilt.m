%
%	Outer/middle ear compensation filter
%	Irino, T.
%	29 Aug. 1996 (check on 14 May  1997 )
%	8 Jan. 2002  (Multiply Win for avoid sprious)
%	19 Nov. 2002 (remez : even integer)
%	2  June 2003 (define Inverse Filter)
%	15 Apr. 2006 (Minimum phase filter)
%	21 Apr. 2006 (note: Sampling rate >= 48000)
%   19 Apr. 2015 ("firpm" takes time! 0.5 sec for designing. Restoring previous coef  )
%
%
%	It is a linear phase /minimum phase filter 
%        for the ELC/MAF/MAP correction.
%	see OutMidCrct.m 
%
%	function [FIRCoef] = OutMidCrctFilt(StrCrct,SR,SwPlot,SwFilter);
%	INPUT	StrCrct: String for Correction ELC/MAF/MAP
%		SR: 	 Sampling Rate
%		SwPlot:  SwPlot
%		SwFilter:  0) FIR linear phase filter
%                          1) FIR linear phase inverse filter
%                          2) FIR minimum phase filter 
%                               (length : half of linear phase filter)
%	OUTPUT  FIRCoef: FIR filter coefficients 
%
%       Note: The filter is valid only for freq < 16000 Hz
%             For inverse filter: freq < 15000 Hz 
%
%
function [FIRCoef, StrFilt] = OutMidCrctFilt(StrCrct,SR,SwPlot,SwFilter);

persistent StrCrct_Keep SR_Keep SwFilter_Keep FIRCoef_Keep

%% %%%%%%%%%%%%%%%
% initial setup %%
%%%%%%%%%%%%%%%%%%

if nargin < 2, help(mfilename); end;
if nargin < 3, SwPlot = []; end;
if length(SwPlot) == 0, SwPlot = 1; end;
if nargin < 4, SwFilter = []; end;
if length(SwFilter) == 0, SwFilter = 0; end;
if length(StrCrct_Keep) == 0,  StrCrct_Keep = 'NoSet'; end; % initial set
if length(SR_Keep) == 0,       SR_Keep       = -99; end; 
if length(SwFilter_Keep) == 0, SwFilter_Keep = -99; end;


if SR > 48000, 
  disp([mfilename ': Sampling rate of ' num2str(SR) ...
        ' (Hz) (> 48000 (Hz)) is not recommended. ']);
  disp(['<-- ELC etc. is only defined below 16000 (Hz).']);
end;

if     SwFilter == 0, StrFilt = 'FIR linear phase filter';
elseif SwFilter == 1, StrFilt = 'FIR linear phase inverse filter';
elseif SwFilter == 2, StrFilt = 'FIR minimum phase filter';
else help(mfilename);
  error('Specify Filter type.');
end;

if length(StrCrct)~=3, 
  help(mfilename);
  error('Specifiy correction in 3 characters: ELC / MAF / MAP.'); 
end;

if ~(strcmp(upper(StrCrct(1:3)), 'ELC')  ...
	| strcmp(upper(StrCrct(1:3)),'MAF') ...
	| strcmp(upper(StrCrct(1:3)),'MAP')),
	error('Specifiy correction: ELC / MAF / MAP.'); 
end;


%% No Culculation.  restoring from the kept data
if strcmp(StrCrct_Keep,StrCrct) == 1 && SR_Keep == SR ...
    && SwFilter_Keep == SwFilter && length(FIRCoef_Keep) > 20
    FIRCoef = FIRCoef_Keep;
    disp(['*** ' mfilename ': Restoring  "'  upper(StrCrct(1:3)) '" ' StrFilt ' ***']);    
    return; % return here
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating filter at the first time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(['*** ' mfilename ': Generating "'  upper(StrCrct(1:3)) '" ' StrFilt ' ***']);
    Nint = 1024;
    % Nint = 0; % No spline interpolation:  NG no convergence at remez
    [crctPwr freq] = OutMidCrct(StrCrct,Nint,SR,0);
    crct = sqrt(crctPwr);
    if SwFilter == 1, 
      crct = 1./(max(sqrt(crctPwr),0.1)); % Giving up less then -20dB : f>15000Hz
                                 % if required, the response becomes worse.
    end; 

    %%% FIRCoef = remez(50/16000*SR,freq/SR*2,crct); % NG 
    %%% FIRCoef = remez(300/16000*SR,freq/SR*2,crct); % Original
    %%% FIRCoef = remez(LenCoef/16000*SR,freq/SR*2,crct); % when odd num : warning
    %%% modified on 8 Jan 2002, 19 Nov 2002, 21 Jun 2006
    LenCoef = 200; %  ( -45 dB) <- 300 (-55 dB)
    NCoef = fix(LenCoef/16000*SR/2)*2; % even number only
    %%% FIRCoef1 = remez(NCoef,freq/SR*2,crct);  % remez : obsolete (help remez)
    % firpm takes time! 0.5 sec for designing   % found 19 Apr 2015
    FIRCoef = firpm(NCoef,freq/SR*2,crct);  % the same coefficient
                                        %%% sqrt(mean((FIRCoef-FIRCoef1).^2))

                                        
    Win     = TaperWindow(length(FIRCoef),'han',LenCoef/10); 
	    % Necessary to avoid sprious
    FIRCoef = Win.*FIRCoef;


    if SwFilter == 2,  % minimum phase reconstruction
        [dummy, x_mp] = rceps(FIRCoef);
         FIRCoef = x_mp(1:fix(length(x_mp)/2));

        % Be careful (Note: 21 June 2006)
         % 1/FIRCoef is not necessarily stable when the Sampling Rate 
         % is high (ex. when 48 kHz). 
    end;

% end of calulation
 
%% keep records

FIRCoef_Keep = FIRCoef;
StrCrct_Keep = StrCrct;
SR_Keep = SR;
SwFilter_Keep = SwFilter;



%% %%%%%%%%%%%%%%%
% Plot %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%

if SwPlot==1
    Nrsl = 1024;
	[frsp freq2] = freqz(FIRCoef,1,Nrsl,SR);
	subplot(2,1,1)
	plot(FIRCoef);
	xlabel('Sample');
	ylabel('Amplitude');
	subplot(2,1,2)
	plot(freq2,abs(frsp),freq,crct,'--')
	%	plot(freq2,20*log10(abs(frsp)),freq,20*log10(crct))
	xlabel('Frequency (Hz)');
	ylabel('Amplitude (linear term)');
	ELCError = mean((abs(frsp) - crct).^2)/mean(crct.^2);
	ELCErrordB = 10*log10(ELCError);          % corrected 

        disp(['OutMidCrct Filter : ' StrFilt ]);
        disp(['Fitting Error : ' num2str(ELCErrordB) ' (dB)']);
	if ELCErrordB > -30,
	    disp(['Warning: Error in ELC correction = ' ...
		    num2str(ELCErrordB) ' dB > -30 dB'])
	end;
end;


return;
