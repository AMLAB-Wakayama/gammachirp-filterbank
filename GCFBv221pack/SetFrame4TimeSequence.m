%
%   Set frame for Time sequence signal
%    used for Spectral feature extraction etc.
%   Irino T.
%   Created:   6 Mar 2010
%   Modified:  6 Mar 2010
%   Modified: 15 Mar 2010 (start from sample 1. with zero padding)
%   Modified: 23 Aug 2010 (start from sample 0  0:ShiftFrame:end)
%
%
% function [MtrxData,NumSmplPnt] ...
%                  = SetFrame4TimeSequence(Snd,LenFrame,ShiftFrame);
%  INPUT  : Snd : sound data
%           LenFrame: Frame length in sample
%           ShiftFrame: Frame shift in sample (== LenFrame/IntegerValue)
%  OUTPUT : MtrxData : Frame matrix
%           NumSmplPnt : Number of sample point which is center of each Frame
%
%
function [MtrxData,NumSmplPnt]=SetFrame4TimeSequence(Snd,LenFrame,ShiftFrame);

if nargin < 2,  ShiftFrame = []; end;
if length(ShiftFrame) == 0, ShiftFrame = LenFrame/2; end;

IntDivFrame = LenFrame/ShiftFrame;

if rem(IntDivFrame,1) ~= 0 | rem(LenFrame,2) ~= 0,
  disp(['LenFrame = ' int2str(LenFrame) ', ShiftFrame = ' ...
        int2str(ShiftFrame) ', Ratio = ' num2str(IntDivFrame,4) ...
        ' <-- should be integer value']);
  disp(['LenFrame must be even number']);
  error(['ShiftFrame must be LenFrame/Integer value']);
end;

Snd1      = [zeros(1,LenFrame/2), Snd(:)' zeros(1,LenFrame/2)]; % zero padding
LenSnd1   = length(Snd1);
NumFrame1 = ceil(LenSnd1/LenFrame);
nlim      = LenFrame*NumFrame1;
Snd1      = [Snd1(1:min(nlim,LenSnd1)), zeros(1,nlim-LenSnd1)];
LenSnd1   = length(Snd1);

NumFrameAll = (NumFrame1-1)*IntDivFrame + 1;
MtrxData = zeros(LenFrame,NumFrameAll);
for nid = 0:IntDivFrame-1,
  NumFrame2 = NumFrame1 - (nid > 0);
  nSnd = ShiftFrame*nid + (1:NumFrame2*LenFrame);
  Snd2 = Snd1(nSnd);
  Mtrx = reshape(Snd2,LenFrame,NumFrame2);
  num = (nid+1):IntDivFrame:NumFrameAll;
  nIndx = (num - 1)*ShiftFrame; % center of frame
  MtrxData(:,num) = Mtrx;
  NumSmplPnt(num) = nIndx;
end;

nValidNumSmplPnt = find(NumSmplPnt<=length(Snd));
MtrxData   = MtrxData(:,nValidNumSmplPnt);
NumSmplPnt = NumSmplPnt(nValidNumSmplPnt);

return
  



% nIndx = max((num - 1)*ShiftFrame,1); % center of frame NG 23 Aug 10

