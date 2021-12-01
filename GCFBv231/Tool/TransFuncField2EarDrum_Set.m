%
%	    Transfer function from field to ear drum  various set 
%   	IRINO T.
%	    Created:  27 Oct 21 from  MAR's  src_to_cochlea_filt
%	    Modified: 27 Oct 21
%
%
%
function [FreqTbl,FrspdBTbl,Param] = TransFuncField2EarDrum_Set(StrCrct, FreqList)

if strncmp(StrCrct, 'FreeField',3) || strcmp(upper(StrCrct), 'FF')
    Param.TypeField2EarDrum = 'FreeField';
    [FreqTbl,FrspdBTbl] = TransFuncFreeField2EarDrum_Moore16;
elseif strncmp(StrCrct, 'DiffuseField',3) || strcmp(upper(StrCrct), 'DF')
    Param.TypeField2EarDrum = 'DiffuseField';
    [FreqTbl,FrspdBTbl] = TransFuncDiffuseField2EarDrum_Moore16;
elseif strncmp(StrCrct, 'ITU',3)
    Param.TypeField2EarDrum = 'ITU';
    [FreqTbl,FrspdBTbl] = TransFuncField2EarDrum_ITU;
else
    error(['Specify:  FreeField (FF) / DiffuseField (DF) / ITU ']);
end


if nargin < 2, return; end

% selection of FreqList

for nfr = 1:length(FreqList)
    NumFreq = find(FreqTbl == FreqList(nfr));
    if length(NumFreq)> 0
        FreqTbl(nfr)   =  FreqTbl(NumFreq);
        FrspdBTbl(nfr) = FrspdBTbl(NumFreq);
    else  % Error if the freq is not listed in table.
        error(['Freq ' num2str(FreqList(nfr)) ' is not listed on the table.'])
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Free Field to Ear Drum %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FreqTbl,FrspdBTbl] = TransFuncFreeField2EarDrum_Moore16
%
%	    Transfer function from field to ear drum
%	    IRINO T.
%	    Created:  16 Jun 20   Seprated from TranFuncField2Cochlea
%	    Modified:  16 Jun 20
%	    Modified:  25 Jun 21 Checked
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

table = [ ...
    20.,  0.0;
    25.,  0.0;
    31.5,  0.0;
    40.,  0.0;
    50.,  0.0;
    63.,  0.0;
    80.,  0.0;
    100.,  0.0;
    125.,  0.1;
    160.,  0.3;
    200.,  0.5;
    250.,  0.9;
    315.,  1.4;
    400.,  1.6;
    500.,  1.7;
    630.,  2.5;
    750.,  2.7;
    800.,  2.6;
    1000.,  2.6;
    1250.,  3.2;
    1500.,  5.2;
    1600.,  6.6;
    2000., 12.0;
    2500., 16.8;
    3000., 15.3;
    3150., 15.2;
    4000., 14.2;
    5000., 10.7;
    6000.,  7.1;
    6300.,  6.4;
    8000.,  1.8;
    9000., -0.9;
    10000., -1.6;
    11200.,  1.9;
    12500.,  4.9;
    14000.,  2.0;
    15000., -2.0;
    16000.,  2.5;
    ];


    FreqTbl   = table(:,1);
    FrspdBTbl = table(:,2);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Diffuse Field to Ear Drum %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FreqTbl,FrspdBTbl] = TransFuncDiffuseField2EarDrum_Moore16

%
%	    Transfer function from field to ear drum
%	    IRINO T.
%	    Created:  16 Jun 20   Seprated from TranFuncField2Cochlea
%	    Modified:  16 Jun 20
%     Modified: 16 Jul 20   extension fc--> resp
%	    Modified:  25 Jun 21 Checked%
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


table = [ ...
    20.,   0.0
    25.,   0.0
    31.5,   0.0
    40.,   0.0
    50.,   0.0
    63.,   0.0
    80.,   0.0
    100.,   0.0
    125.,   0.1
    160.,   0.3
    200.,   0.4
    250.,   0.5
    315.,   1.0
    400.,   1.6
    500.,   1.7
    630.,   2.2
    750.,   2.7
    800.,   2.9
    1000.,   3.8
    1250.,   5.3
    1500.,   6.8
    1600.,   7.2
    2000.,  10.2
    2500.,  14.9
    3000.,  14.5
    3150.,  14.4
    4000.,  12.7
    5000.,  10.8
    6000.,   8.9
    6300.,   8.7
    8000.,   8.5
    9000.,   6.2
    10000.,   5.0
    11200.,   4.5
    12500.,   4.0
    14000.,   3.3
    15000.,   2.6
    16000.,   2.0
    ];

    FreqTbl   = table(:,1);
    FrspdBTbl = table(:,2);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ITU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FreqTbl,FrspdBTbl] = TransFuncField2EarDrum_ITU

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ITU Rec P 58 08/96 Head and Torso Simulator transfer fns.
% from Peter Hugher BTRL , 4-June-2001
% Negative of values in Table 14a of ITU P58 (05/2013), accesible at  http://www.itu.int/rec/T-REC-P.58-201305-I/en
% Freely available. Converts from ear reference point (ERP) to eardrum reference point (DRP)
% EXCEPT extra 2 points added for 20k & 48k by MAS, MAr 2012
%
% ITU_Hz = [0 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000   20000 48000];
% ERP-DRP transfer fn, Table 14A/P.58, sect 6.2.  NB negative of table since defined other way round.
% Ear Reference Point to Drum Reference Point
% ITU_erp_drp = [0. 0. 0. 0. 0. .3 .2 .5 .6 .7 1.1 1.7 2.6 4.2 6.5 9.4 10.3 6.6 3.2 3.3 16 14.4    14.4 14.4];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% remove 20000 Hz and 48000 Hz
FreqTbl = [0 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000]';
FrspdBTbl = [0. 0. 0. 0. 0. .3 .2 .5 .6 .7 1.1 1.7 2.6 4.2 6.5 9.4 10.3 6.6 3.2 3.3 16 14.4]';

end
