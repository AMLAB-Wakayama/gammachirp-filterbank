%
%   HL to SPL
%   Irino T.,
%   Created:   9 Feb 2012
%   Modified:  9 Feb 2012
%   Modified: 29 Feb 2012
%   Modified:  7 Jan 2014 (clarify the reference to AA-79)
%   Modified: 21 Feb 2018 下位互換性のため残す。情報はTableSPLatHL0dBに
%   Modified: 23 Feb 2018 Table はSPLatHL0dB_Tableから
%   Modified: 23 Feb 2018 Table はSPLatHL0dB_Tableから
%   Modified: 18 Jul 2020  adding "<= 8000"
%
% function  [SPLdB] = HL2SPL(freq,HLdB)
% INPUT:  freq 
%         HLdB:  Hearing Level dB
% OUTPUT: SPLdB : SPL dB
%
function  [SPLdB] = HL2SPL(freq,HLdB)

Table1 = SPLatHL0dB_Table; % 数値をいろいろなプログラム中に書き込まないように。
FreqRef  = Table1.freq;
SPLdBatHL0dB = Table1.SPLatHL0dB; % SPLdBatHL0dB_ANSI_S39_1996

if nargin < 2
    help(mfilename)
    disp('[Frequency (kHz); SPLdB@HL0dB] = ');
    disp([FreqRef/1000; SPLdBatHL0dB]);
    return
end;

if length(freq) ~= length(HLdB)
    error('Length of freq & HLdB should be the same.');
end;

for nf = 1: length(freq)
    nfreq = find(freq(nf) == FreqRef);
    if length(nfreq) == 0;
        error('Frequency should be one of 125*2^n & 750*n (Hz) <= 8000. ');
    end;

    SPLdB(nf) =  HLdB(nf) + SPLdBatHL0dB(nfreq);
end;

return

