%
%	    Filter of Field to Cochlea with compativility of OutMidCrctFilt
%	    Irino, T.
%	    Created: 24 Oct 2021 (from OutMidCrctFilt.m see also MAR's src_to_cochlea_filt.m)
%	    Modified: 25 Oct 2021
%
%	    Making minimum phase forward and inverse filter
%     TransFuncDiffuseField2EarDrum_Moore16 etc.
%     + conventional  OutMidCrctFilt
%
%	    function [FIRCoef, Param] = MkFilterField2Cochlea(StrCrct,fs,SwFwdBwd,SwPlot)
%	    INPUT	StrCrct: FreeField (FF) / DiffuseField (DF) / ITU / ELC
%		            fs: 	       Sampling frequecny
%		            SwFwdBck:  1) Forward: FIR minimum phase filter
%                                     -1) Backward: inverse FIR minimum phase filter
%                 SwPlot: 1) plot
%	    OUTPUT  FIRCoef: FIR filter coefficients
%                   Param
%
%       Note: The filter is valid only for freq < 16000 Hz
%             For inverse filter: freq < 15000 Hz
%
%
function [FIRCoef, Param] = MkFilterField2Cochlea(StrCrct,fs,SwFwdBwd,SwPlot)

persistent TypeField2EarDrum_Keep fs_Keep  FIRCoefFwd_Keep FIRCoefBwd_Keep

%% %%%%%%%%%%%%%%%
% initial setup %%
%%%%%%%%%%%%%%%%%%
if nargin < 2, help(mfilename); end
if nargin < 3, SwFwdBwd = 1; end  % default
if nargin < 4, SwPlot = 0; end

if fs > 48000
    disp([mfilename ': Sampling rate of ' num2str(fs) ...
        ' (Hz) (> 48000 (Hz)) is not recommended. ']);
    disp(['<-- Transfer function is only defined below 16000 (Hz).']);
end
Param.fs = fs;

if strcmp(StrCrct, 'FreeField') || strcmp(upper(StrCrct), 'FF')
    SwType = 1;
    Param.TypeField2EarDrum = 'FreeField';
elseif strcmp(StrCrct, 'DiffuseField') || strcmp(upper(StrCrct), 'DF')
    SwType = 2;
    Param.TypeField2EarDrum = 'DiffuseField';
elseif strcmp(StrCrct, 'ITU')
    SwType = 3;
    Param.TypeField2EarDrum = 'ITU';
elseif strcmp(StrCrct, 'ELC')
    SwType = 4;
    Param.TypeField2EarDrum = 'ELC'; % for backward compativility
else
    error(['Specify:  FreeField (FF) / DiffuseField (DF) / ITU / ELC']);
end

if       SwFwdBwd== 1, Param.NameFilter   = '(Forward) FIR minimum phase filter';
elseif SwFwdBwd == -1, Param.NameFilter = '(Backward) FIR minimum phase inverse filter';
else   help(mfilename);
    error('Specify SwFwdBwd :  (1) Forward,  (-1) Backward.');
end

Param.NameFilter = [ '[' StrCrct  ']  '  Param.NameFilter];

% TypeField2EarDrum_Keep

%% %%%%%%%%%%%%%%%%%%%%%%%%%
% No Culculation.  Restoring from the kept data
% Time for calculation of firpm is relatively long  about 0.118 sec. -- Reducing
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(TypeField2EarDrum_Keep,Param.TypeField2EarDrum) == 1 && fs_Keep == fs ...
        && SwPlot ~= 1
    if  SwFwdBwd == 1 && length(FIRCoefFwd_Keep) > 20
        FIRCoef = FIRCoefFwd_Keep;
        disp(['*** ' mfilename ': Restoring '  Param.NameFilter ' ***']);
        return % return here
    elseif SwFwdBwd == -1 && length(FIRCoefBwd_Keep) > 20
        FIRCoef = FIRCoefBwd_Keep;
        disp(['*** ' mfilename ': Restoring '  Param.NameFilter ' ***']);
        return % return here
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating filter at the first time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['*** ' mfilename ': Generating  '  Param.NameFilter ' ***']);

if SwType <= 3
    Param.TypeMidEar2Cochlea = 'MiddleEar'; % default but specify here for clarity
    TransFunc= TransFuncField2Cochlea(Param);
    FrspCrct = 10.^(TransFunc.Field2CochleadB/20);
    freq = TransFunc.freq;
    Param.TypeField2CochleadB  = TransFunc.TypeField2CochleadB;
else  
    % ELC for backward compativility
    Nrslt = 2048;
    [crctPwr, freq] = OutMidCrct(StrCrct,Nrslt,fs,0);
    FrspCrct = sqrt(crctPwr);
    Param.TypeField2CochleadB  =  'ELC';  
end

if SwFwdBwd == -1  % Backward filter
    FrspCrct =1./(max(FrspCrct,0.1));
    % Giving up less then -20dB : f>15000Hz. If required, the response becomes worse.
    % from OutMidCrctFilt.m
end

% tic
LenCoef = 200; %  ( -45 dB) <- 300 (-55 dB)
NCoef = fix(LenCoef/16000*fs/2)*2;            % fs dependent length, even number only
FIRCoef = firpm(NCoef,freq/fs*2,FrspCrct);  % the same coefficient

Win     = TaperWindow(length(FIRCoef),'han',LenCoef/10); % Necessary to avoid sprious
FIRCoef = Win.*FIRCoef;

% minimum phase reconstruction -- important to avoid pre-echo
[dummy, x_mp] = rceps(FIRCoef);
FIRCoef = x_mp(1:fix(length(x_mp)/2));  % half length is suffient
% toc

%% %%%%%%%%%%
% keep records for fast processing
%%%%%%%%%%%%%

if SwFwdBwd == 1
    FIRCoefFwd_Keep = FIRCoef;
elseif SwFwdBwd == -1
    FIRCoefBwd_Keep = FIRCoef;
end
TypeField2EarDrum_Keep = Param.TypeField2EarDrum;
fs_Keep = fs;


%% %%%%%%%%%%%%%%%
% Plot 
%%%%%%%%%%%%%%%%%%

if SwPlot==1
    Nrsl = length(FrspCrct);
    [frsp, freq2] = freqz(FIRCoef,1,Nrsl,fs);
    subplot(2,1,1)
    plot(FIRCoef);
    xlabel('Sample');
    ylabel('Amplitude');
    title(['Type : '  Param.TypeField2EarDrum ]);

    subplot(2,1,2)
    plot(freq2,abs(frsp),freq,FrspCrct,'--')
    %	plot(freq2,20*log10(abs(frsp)),freq,20*log10(FrspCrct))
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (linear term)');
    ELCError = mean((abs(frsp) - FrspCrct).^2)/mean(FrspCrct.^2);
    ELCErrordB = 10*log10(ELCError);          % corrected

    disp(['Fitting Error : ' num2str(ELCErrordB) ' (dB)']);
    if ELCErrordB > -30
        disp(['Warning: Error in ELC correction = ' ...
            num2str(ELCErrordB) ' dB > -30 dB'])
    end
end


end
