
%
%	Transfer function from field to cochlear input
%	IRINO T.
%	Created:  16 Jun 20   Seprated from TranFuncField2Cochlea
%	Modified:  16 Jun 20
%
%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FreqTbl, FrspdBTbl ] = TransFuncMiddleEar_Moore16(FreqList)

table = [ ...
    20.0,	-39.6;
    25.0,	-32.0;
    31.5	-25.85;
    40.0,	-21.4;
    50.0,	-18.5;
    63.0,	-15.9;
    80.0,	-14.1;
    100.0,	-12.4;
    125.0,	-11.0;
    160.0,	-9.6;
    200.0,	-8.3;
    250.0,	-7.4;
    315.0,	-6.2;
    400.0,	-4.8;
    500.0,	-3.8;
    630.0,	-3.3;
    750.0,	-2.9;
    800.0,	-2.6;
    1000.0,	-2.6;
    1250.0,	-4.5;
    1500.0,	-5.4;
    1600.0,	-6.1;
    2000.0,	-8.5;
    2500.0,	-10.4;
    3000.0,	-7.3;
    3150.0,	-7.0;
    4000.0,	-6.6;
    5000.0,	-7.0;
    6000.0,	-9.2;
    6300.0,	-10.2;
    8000.0,	-12.2;
    9000.0,	-10.8;
    10000.0,	-10.1;
    11200.0,	-12.7;
    12500.0,	-15.0;
    14000.0,	-18.2;
    15000.0,	-23.8;
    16000.0,	-32.3;
    18000.0,	-45.5;
    20000.0,	-50.0;
    ];

if nargin < 1,
    FreqTbl   = table(:,1);
    FrspdBTbl = table(:,2);
    return;
end;

for nfr = 1:length(FreqList)
    NumFreq = find(table(:,1) == FreqList(nfr));
    if length(NumFreq)> 0
        FreqTbl(nfr)   = table(NumFreq,1);
        FrspdBTbl(nfr) = table(NumFreq,2);
    else  % Error if the freq is not listed in table.
        error(['Freq ' num2str(FreqList(nfr)) ' is not listed on the table.'])
    end;
end;

return;

