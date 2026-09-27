%
%   Set frame for Time sequence signal
%    used for Spectral feature extraction etc.
%   Irino T.
%   Created:   6 Mar 2010
%   Modified:  6 Mar 2010
%   Modified: 15 Mar 2010 (start from sample 1. with zero padding)
%   Modified: 23 Aug 2010 (start from sample 0  0:ShiftFrame:end)
%   Modified: 18 Sep 2021 (Replacement parameter names)
%
%
% function [SndFrame,NumSmplPnt] ...
%                  = SetFrame4TimeSequence(Snd,LenWin,LenShift);
%  INPUT  : Snd : sound data
%           LenWin: Frame length in sample
%           LenShift: Frame shift in sample (== LenWin/IntegerValue)
%  OUTPUT : SndFrame : Frame matrix
%           NumSmplPnt : Number of sample point which is center of each Frame
%
% NOTE: Replacement parameter names to avoid confusion   18 Sep 21
%            LenFrame --> LenWin, ShiftFrame --> LenShift,  MtrxData --> SndFrame
%            Confirmed no errors.
%
%
function [SndFrame,NumSmplPnt]=SetFrame4TimeSequence(Snd,LenWin,LenShift)

if nargin < 2,  LenShift = []; end
if length(LenShift) == 0, LenShift = LenWin/2; end

IntDivFrame = LenWin/LenShift;

if rem(IntDivFrame,1) ~= 0 || rem(LenWin,2) ~= 0
  disp(['LenWin = ' int2str(LenWin) ', LenShift = ' ...
        int2str(LenShift) ', Ratio = ' num2str(IntDivFrame,4) ...
        ' <-- should be integer value']);
  disp(['LenWin must be even number']);
  error(['LenShift must be LenWin/Integer value']);
end;

Snd1      = [zeros(1,LenWin/2), Snd(:)' zeros(1,LenWin/2)]; % zero padding
LenSnd1   = length(Snd1);
NumFrame1 = ceil(LenSnd1/LenWin);
nlim      = LenWin*NumFrame1;
Snd1      = [Snd1(1:min(nlim,LenSnd1)), zeros(1,nlim-LenSnd1)];
LenSnd1   = length(Snd1);

NumFrameAll = (NumFrame1-1)*IntDivFrame + 1;
SndFrame = zeros(LenWin,NumFrameAll);
for nid = 0:IntDivFrame-1
  NumFrame2 = NumFrame1 - (nid > 0);
  nSnd = LenShift*nid + (1:NumFrame2*LenWin);
  Snd2 = Snd1(nSnd);
  Mtrx = reshape(Snd2,LenWin,NumFrame2);
  num = (nid+1):IntDivFrame:NumFrameAll;
  nIndx = (num - 1)*LenShift; % center of frame
  SndFrame(:,num) = Mtrx;
  NumSmplPnt(num) = nIndx;
end

nValidNumSmplPnt = find(NumSmplPnt<=length(Snd));
SndFrame   = SndFrame(:,nValidNumSmplPnt);
NumSmplPnt = NumSmplPnt(nValidNumSmplPnt);

return
  



% nIndx = max((num - 1)*LenShift,1); % center of frame NG 23 Aug 10

