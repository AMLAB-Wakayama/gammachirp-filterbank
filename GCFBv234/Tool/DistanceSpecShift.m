%
%   Distance (Minimum error) calculation of two spectrograms with shift
%   Irino, T.
%   Created:   1 Nov 21
%   Modified:  1 Nov 21
%   Modified:  2 Nov 21
%
%
%
function Rslt = DistanceSpecShift(Spec1,Spec2,nMaxShift)

[NumCh1, LenSpec1] = size(Spec1);
[NumCh2, LenSpec2] = size(Spec2);

DiffLen = abs(diff([LenSpec1, LenSpec2]));
if  DiffLen > 0 && DiffLen < 3  % small difference is compensated
    MinLenSpec = min([LenSpec1, LenSpec2]);
    Spec1 = Spec1(:,1:MinLenSpec);
    Spec2 = Spec2(:,1:MinLenSpec);
    LenSpec1 = MinLenSpec;
    LenSpec2 = MinLenSpec;
end

if NumCh1 ~= NumCh2 || LenSpec1 ~= LenSpec2
    [NumCh1, LenSpec1, NumCh2, LenSpec2]
    error('Spec1 & Spec2 should be the same size.')
end

if nargin < 3
    nMaxShift = min(30,fix(LenSpec1/4));
end

for nShift = 0:nMaxShift
    Spec1Cmpr = Spec1(:,nShift+1:end);
    ErrVal1(nShift+1) = rms(rms(Spec1Cmpr - Spec2(:,1:end-nShift)))/rms(rms(Spec1Cmpr));
    Spec2Cmpr = Spec2(:,nShift+1:end);
    ErrVal2(nShift+1) = rms(rms(Spec2Cmpr - Spec1(:,1:end-nShift)))/rms(rms(Spec2Cmpr));
end

[MinErr(1), nMinErr(1)] = min(ErrVal1);
[MinErr(2), nMinErr(2)] = min(ErrVal2);

[MinErr, n12] = min(MinErr);
NshiftMinErr = sign(n12-1.5) * (nMinErr(n12)-1);

Rslt.MinErr = MinErr;
Rslt.MinErrdB = 20*log10(MinErr);
Rslt.MinErrNshift = NshiftMinErr;
Rslt.ErrNoShift = ErrVal1(1);
Rslt.ErrNoShiftdB = 20*log10(ErrVal1(1));


SwPlot = 1;
SwPlot = 0;
if SwPlot
    subplot(2,1,1)
    plot(1:LenSpec1, rms(Spec1), 1:LenSpec2, rms(Spec2)+max(rms(Spec1))*1.2)
    subplot(2,1,2)
    plot([fliplr(ErrVal1) ErrVal2(2:end)])
end





