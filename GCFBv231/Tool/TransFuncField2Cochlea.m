%
%	    Transfer function from field to cochlear input
%	    IRINO T.
%	    Created:  27 Sep 16   from Moore's table (as OutMidCrct2016)
%	    Modified: 27 Sep 16   from Moore's table
%	    Modified:  5 Nov 16    IT, renamed to TransFuncField2Cochlea
%	    Modified:  6 Nov 16    IT, renamed to TransFuncField2Cochlea
%	    Modified: 14 Nov 16   IT,
%	    Modified:  6 Dec 16    IT, adding HD650
%	    Modified:  17 Oct 17   IT, adding note
%	    Modified:  20 Feb 18   IT, if nargin < 1
%	    Modified:  16 Jul 20    IT, %  Separated: TransFuncMiddleEar_Moore16, FreeField2EarDrum_Moore16,  DiffuseField2EarDrum_Moore16
%	    Modified:  26 Oct 21   IT,  interp1 linear extrap;  ITU, ParamIn.TypeField2EarDrum='FreeField'
%	    Modified:  27 Jun 21   Use TransFuncField2EarDrum_Set.m
%
%
%	function TransFunc = TransFuncField2Cochlea(ParamIn);
%
%	INPUT
%       ParamIn: input parameters
%           TypeField2EarDrum: String for transfer function / headphones
%           TypeMidEar2Cochlea: Middle ear transfer function from the ear drum to cochlea
%           NfrqRsl  Number of data points, if zero, then direct out.
%           fs: 	 Sampling Frequency
%           FreqCalib: Frequency at which SPL at ear drum is calibrated
%           SwPlot:  Switch for plot
%
%	OUTPUT
%       TransFunc : Transfer function structure
%                   freq :  Corresponding Frequency at the data point
%                   Transfer functions in dB
%       ParamOut  : = ParamIn + DirData
%
%
% NOTE: Parameter setting is different from OutMidCrct
%        [CrctLinPwr, freq] = OutMidCrct(StrCrct,NfrqRsl,fs);
%
% NOTE:   17 Oct 17
%        The following function is inside in this function. See bottom.
%           TransFuncMiddleEar_Moore16
%           FreeField2EarDrum_Moore16
%           DiffuseField2EarDrum_Moore16
%    --->  Separated on 16 Jul 2020
%
%  NOTE: 31 Jan 20
%   Information about the middle ear transfer function from BJC Moore
% Puria, S., Rosowski, J. J., Peake, W. T., 1997.
%       Sound-pressure measurements in the cochlear vestibule of human-cadaver ears.
%       J. Acoust. Soc. Am. 101, 2754-2770.
% Aibara, R., Welsh, J. T., Puria, S., Goode, R. L., 2001.
%       Human middle-ear sound transfer function and cochlear input impedance.
%       Hear. Res. 152, 100-109.
% However, its exact form was chosen so that our model of loudness perception would
% give accurate predictions of the absolute threshold, as described in:
% Glasberg, B. R., Moore, B. C. J., 2006.
%       Prediction of absolute thresholds and equal-loudness contours using
%       a modified loudness model. J. Acoust. Soc. Am. 120, 585-588.
%
%
function [TransFunc, ParamOut] = TransFuncField2Cochlea(ParamIn)

if nargin < 1
    help(mfilename);
    disp('Set Parameter to default value');
    ParamIn = [];
end

if isfield(ParamIn,'TypeField2EarDrum') == 0
    ParamIn.TypeField2EarDrum = 'FreeField';  % default 25 Oct 21
end
if isfield(ParamIn,'TypeMidEar2Cochlea') == 0
    ParamIn.TypeMidEar2Cochlea = 'MiddleEar_Moore16';
end

if isfield(ParamIn,'fs')        == 0, ParamIn.fs = 48000;       end
if isfield(ParamIn,'NfrqRsl')   == 0, ParamIn.NfrqRsl = 2048;   end
if isfield(ParamIn,'FreqCalib') == 0, ParamIn.FreqCalib = 1000; end % SPL at ear drum is calibrated at 1000 Hz
if isfield(ParamIn,'SwPlot')    == 0, ParamIn.SwPlot = 0;       end
if isfield(ParamIn,'SwGetTable')  == 0, ParamIn.SwGetTable = 0;       end


ParamOut  = ParamIn;
TransFunc.fs        = ParamIn.fs;
TransFunc.FreqCalib = ParamIn.FreqCalib;

freq      = (0:ParamIn.NfrqRsl-1)'/ParamIn.NfrqRsl * ParamIn.fs/2;
TransFunc.freq = freq;

% Data directory
DirThisProgram = which(mfilename);
NumDot = find(DirThisProgram == '.');
DirData = [DirThisProgram(1:NumDot-1) '_Data/'];
ParamOut.DirData = DirData;


%% %%%%%%%%%%%%%%%%%%%%%%
%%% Field to Ear Drum
%%%%%%%%%%%%%%%%%%%%%%%%
TypeField2EarDrumList = { ...
    'FreeField2EarDrum_Moore16';  ...
    'DiffuseField2EarDrum_Moore16'; 
    'ITUField2EarDrum'; ...
    'HD580_L_AMLAB15';'HD580_R_AMLAB15'; ...
    'HD650_L_AMLAB16';'HD650_R_AMLAB16'; ...
    };

SwCrct = [];
for nc = 1:length(TypeField2EarDrumList)
    LenMatch = 3;
    if nc >= 4, LenMatch = 7; end
    if strncmp(upper(ParamIn.TypeField2EarDrum),upper(char(TypeField2EarDrumList(nc))), LenMatch) == 1
        SwCrct = nc;
    end
end

if length(SwCrct) == 0
    disp('Select "TypeField2EarDrum" from one of ');
    for nL = 1:length(TypeField2EarDrumList)
        disp(['   - ' char(TypeField2EarDrumList(nL))]);
    end
    error(['You specified "TypeField2EarDrum" as "' ParamIn.TypeField2EarDrum '"  <--- Check name']);
end

TransFunc.TypeField2EarDrum  = char(TypeField2EarDrumList(SwCrct));

% StrInterp1 = 'spline';
StrInterp1 = 'linear'; % linearの方が素直だと思う。　26 Oct 21

if SwCrct <= 3
    [FreqTbl, FrspdBTbl] =  TransFuncField2EarDrum_Set(TransFunc.TypeField2EarDrum);
    if ParamIn.fs/2 > max(FreqTbl)
        FreqTbl    = [FreqTbl;     ParamIn.fs/2];
        FrspdBTbl = [FrspdBTbl;  FrspdBTbl(end)]; %  fs/2では最後と同じ値を入れておく
    end
    % logだとfreq=0を扱えない。でも聴覚特性に合わせたいのでFreq2ERB
    Field2EarDrumdB = interp1(Freq2ERB(FreqTbl),FrspdBTbl,Freq2ERB(freq),StrInterp1,'extrap'); 

elseif SwCrct >= 4
    NameImpRsp = [ 'ImpRsp_' char(TypeField2EarDrumList(SwCrct)) '.wav'];
    disp(['Read Impulse response : ' NameImpRsp]);
    tic
    [SndImpRsp, fsIR] = audioread([DirData NameImpRsp]);
    [frspIR, freqIR] = freqz(SndImpRsp,1,length(SndImpRsp),fsIR);
    toc
    Field2EarDrumdB = interp1(Freq2ERB(freqIR),20*log10(abs(frspIR)),Freq2ERB(freq),StrInterp1,'extrap');
end


% Compensate to 0dB at ParamIn.FreqCalib
% find bin number of ParamIn.FreqCalib
[dummy, NumFreqCalib]  = min(abs(freq-ParamIn.FreqCalib));

TransFunc.freq_AtFreqCalib  = freq(NumFreqCalib);
TransFunc.Field2EarDrumdB = Field2EarDrumdB - Field2EarDrumdB(NumFreqCalib);
TransFunc.Field2EarDrumdB_AtFreqCalib = TransFunc.Field2EarDrumdB(NumFreqCalib); % It should be 0dB.
TransFunc.Field2EarDrumdB_CmpnstdB    = Field2EarDrumdB(NumFreqCalib);


%% %%%%%%%%%%%%%%%%%%%%%%
%%% Ear Drum to cochlea
%%%%%%%%%%%%%%%%%%%%%%%%
if strncmp(ParamIn.TypeMidEar2Cochlea,'MiddleEar',9) ~= 1
    error(['Not Prepared yet : ' ParamIn.TypeMidEar2Cochlea]);
else
    [FreqTbl2,  FrspdBTbl2] =  TransFuncMiddleEar_Moore16;
    if ParamIn.fs/2 > max(FreqTbl2)
        FreqTbl2    = [FreqTbl2;     ParamIn.fs/2];
        FrspdBTbl2 = [FrspdBTbl2;  FrspdBTbl2(end)];
    end
    MidEar2CochleadB = interp1(Freq2ERB(FreqTbl2),FrspdBTbl2,Freq2ERB(freq),StrInterp1,'extrap');

    TransFunc.MidEar2CochleadB = MidEar2CochleadB;
    TransFunc.MidEar2CochleadB_AtFreqCalib = MidEar2CochleadB(NumFreqCalib);
    TransFunc.TypeMidEar2Cochlea = 'MiddleEar_Moore16';
end


%% %%%%%%%%%%%%%%%%%%%%%%
%%% Total: Field to cochlea
%%%%%%%%%%%%%%%%%%%%%%%%

TransFunc.Field2CochleadB = TransFunc.Field2EarDrumdB + TransFunc.MidEar2CochleadB;
TransFunc.Field2CochleadB_AtFreqCalib = TransFunc.Field2CochleadB(NumFreqCalib);

TransFunc.TypeField2CochleadB = [TransFunc.TypeField2EarDrum ' + ' TransFunc.TypeMidEar2Cochlea];

disp(['TypeField2CochleadB : ' TransFunc.TypeField2CochleadB]);

disp(['TransFunc.freq_AtFreqCalib = ', int2str(TransFunc.freq_AtFreqCalib) ' Hz  ( <-- ' int2str(ParamIn.FreqCalib) ' Hz )']);
disp(['TransFunc.Field2EarDrumdB_AtFreqCalib  = ', num2str(TransFunc.Field2EarDrumdB_AtFreqCalib,'%5.3f') ' dB']);
disp(['                        (Compensated for ' num2str(TransFunc.Field2EarDrumdB_CmpnstdB,'%5.3f') ' dB)']);
disp(['TransFunc.MidEar2CochleadB_AtFreqCalib = ', num2str(TransFunc.MidEar2CochleadB_AtFreqCalib,'%5.3f') ' dB']);
disp(['TransFunc.Field2CochleadB_AtFreqCalib  = ', num2str(TransFunc.Field2CochleadB_AtFreqCalib,'%5.3f') ' dB']);


%% %%%%%%%%%%%%%%%%%%%%%%
%%% Plot data
%%%%%%%%%%%%%%%%%%%%%%%%

if ParamIn.SwPlot == 1
    clf;
    subplot(3,1,1);
    semilogx(freq, TransFunc.Field2EarDrumdB,...
        TransFunc.freq_AtFreqCalib,TransFunc.Field2EarDrumdB_AtFreqCalib,'rx');
    grid on;
    text(TransFunc.freq_AtFreqCalib*0.9,TransFunc.Field2EarDrumdB_AtFreqCalib-3,...
        [ num2str(TransFunc.Field2EarDrumdB_AtFreqCalib,'%5.2f') ' dB']);
    xlabel('Frequency (Hz)');
    if SwCrct <= 2
        hold on;
        h = semilogx(FreqTbl, FrspdBTbl,'o');
    end
    ylabel('Gain (dB)');
    str = ['Frequency response : ' TransFunc.TypeField2EarDrum ...
        ',  Gain normalized at ' int2str(TransFunc.freq_AtFreqCalib) ' (Hz)'];
    ht = title(str);
    set(ht,'interpreter','none');
    axis([10 30000 -20 20]);

    subplot(3,1,2);
    h = semilogx(freq, TransFunc.MidEar2CochleadB,FreqTbl2, FrspdBTbl2,'o');
    hold on;
    semilogx(TransFunc.freq_AtFreqCalib*[1 1], [-0.3 TransFunc.Field2CochleadB_AtFreqCalib+1],'r-v');
    text(TransFunc.freq_AtFreqCalib*1.08,TransFunc.Field2CochleadB_AtFreqCalib/2,...
        [ num2str(TransFunc.Field2CochleadB_AtFreqCalib,'%5.2f') ' dB']);
    grid on;
    xlabel('Frequency (Hz)');
    %h = plot(Freq2ERB(FreqTbl2), FrspdBTbl2,'o',Freq2ERB(freq), TransFunc.MidEar2CochleadB);
    %xlabel('ERB number');
    ylabel('Gain (dB)');
    str = ['Frequency response : ' TransFunc.TypeMidEar2Cochlea ];
    ht = title(str);
    set(ht,'interpreter','none');
    axis([10 30000 -30 10]);


    subplot(3,1,3);
    %h = plot(freq,TransFunc.MidEar2CochleadB);
    %xlabel('Frequency (Hz)');
    h = semilogx(freq,TransFunc.Field2CochleadB);
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Gain (dB)');
    str = ['Frequency response :  Total Transfer Function from Field to cochlea'];
    ht = title(str);
    set(ht,'interpreter','none');
    axis([10 30000 -30 10]);

    printi(2,0)
    str = ['print -depsc -tiff ' DirData '/Fig_TransFunc_' TransFunc.TypeField2EarDrum '_' ...
        TransFunc.TypeMidEar2Cochlea '.eps'];
    disp(str)
    eval(str);

end



return




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%

% if ParamIn.SwGetTable >= 1
%     disp('Return Table of Moore16 / ITU values only');
%     [FreqTbl,  FrspdBTbl] =  TransFuncFreeField2EarDrum_Moore16;
%     TransFunc.Table.FreeField2EarDrum_Moore16.freq = FreqTbl;
%     TransFunc.Table.FreeField2EarDrum_Moore16.FrspdB = FrspdBTbl;
% 
%     [FreqTbl,  FrspdBTbl] =   TransFuncDiffuseField2EarDrum_Moore16;
%     TransFunc.Table.DiffuseField2EarDrum_Moore16.freq = FreqTbl;
%     TransFunc.Table.DiffuseField2EarDrum_Moore16.FrspdB = FrspdBTbl;
% 
%     [FreqTbl,  FrspdBTbl] =   TransFuncField2EarDrum_ITU;
%     TransFunc.Table.Field2EarDrum_ITU.freq = FreqTbl;
%     TransFunc.Table.Field2EarDrum_ITU.FrspdB = FrspdBTbl;
% 
%     [FreqTbl2,  FrspdBTbl2] =  TransFuncMiddleEar_Moore16;
%     TransFunc.Table.TransFuncMiddleEar_Moore16.freq = FreqTbl2;
%     TransFunc.Table.TransFuncMiddleEar_Moore16.FrspdB = FrspdBTbl2;
% 
%     ParamOut = [];
%     return;
% end


%%% Transfer functionは外部関数化　16 Jul 2020

%[SwCrct SwCrctPrevious]

% if 1 % SwCrct ~= SwCrctPrevious, %もし、前条件と異なったら実行 audioreadの時間が長いので節約
% 間違いの元なので、やめた。 --> 収束計算中で用いないように。　　14 Nov. 16
%
%disp(['=== Setting "Field2EarDrumdB" as ' TransFunc.TypeField2EarDrum]);


% persistent Field2EarDrumdB SwCrctPrevious   間違いの元なので、毎回計算するように 14 Nov 16
% avoid reading impulse response repeatedly
%if isempty(Field2EarDrumdB) == 1, Field2EarDrumdB = []; end;
%if isempty(SwCrctPrevious)  == 1, SwCrctPrevious = 0; end;
%end; % SwCrct ~= SwCrctPrevious
%SwCrctPrevious = SwCrct; % 前条件の保存。Previous condition



