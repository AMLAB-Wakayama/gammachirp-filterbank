%
%       Analysis of Envelope Modulation using filterbank working with GCFBv230
%       IRINO, T.
%       Created:  10 Feb 2021
%       Modified:  10 Feb 2021
%       Modified:  11 Feb 2021 renamed to GCFBv230_AnaEnvMod
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%
%
function [GCEMframe, AnaEMparam]  = GCFBv23_AnaEnvMod(cGCframe,GCparam,AnaEMparam),

if strncmp(GCparam.DynHPAF.StrPrc,'frame',5) ~= 1
    error('Working only when GCparam.DynHPAF.StrPrc== ''frame-base''');
end

if nargin <= 2 || isfield(AnaEMparam,'FcModList') == 0; % default  % modulation center frequency
    % No use now AnaEMparam.FcModList = 2.^(0:0.5:8);   % [1, 1.4, 2, 2^1.5, 4, ... 256]; 0.5 step
    AnaEMparam.FcModList = 2.^(0:8);   % [1 2 4 8, ... 256];
end

AnaEMparam.fs = GCparam.DynHPAF.fs; 
[NumCh, LenFrame] = size(cGCframe);
LenFcm = length(AnaEMparam.FcModList);

GCEMframe = zeros(NumCh, LenFcm ,LenFrame);
for nch = 1:GCparam.NumCh
    GCEMframe(nch,:,:) = EnvModFB(cGCframe(nch,:),AnaEMparam);
end

return


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  modulation filterbank based on K. Yamamoto
%  But cleaned up the codes.
%  
function EnvOut = EnvModFB(Env,AnaEMparam)

Env = Env(:)'; % row vector
EnvOut  = zeros(length(AnaEMparam.FcModList),length(Env));

for nMod = 1:length(AnaEMparam.FcModList)
    FcMod = AnaEMparam.FcModList(nMod);
    
    if FcMod  == 1   % if FcMod  is 1 Hz  Lowpass filter
        % Third order lowpass filter
        [bz, ap] = butter(3, FcMod/(AnaEMparam.fs/2));  
    else
        % Pre-warping
        w_warp = 2*pi*FcMod/AnaEMparam.fs;
        % Bilinear z-transform
        W0 = tan(w_warp/2);
        % Second order bandpass filter
        Q = 1;
        B0 = W0/Q;
        b = [B0; 0; -B0];
        a = [1 + B0 + W0^2; 2*W0^2 - 2; 1 - B0 + W0^2];
        bz = b/a(1);
        ap = a/a(1);
    end

    % filtering
    EnvOut(nMod,:) = filter(bz, ap, Env);
end

