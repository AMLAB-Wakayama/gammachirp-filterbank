%
%  test Lowpass filter
%  Irino, T.
%  Created: 8 Feb 2021
%
%  Morimoto TMTFと同じオーダーのLPFとするには？
% first-order low-pass filter.
% Formby and Muir (1988) and Eddins (1993) modeled the TMTF function φ(fm) as
% TMTF = Lps - 10*log10(1./(1+(freq/fcutoff).^2));
clear
clf

fs = 2000;
Nrsl = 1024*16;
Norder = 1;
LenSnd = 1024;
Imp = [zeros(1,20), 1, zeros(1, LenSnd-21)];

for nf = 2:8
    fcutoff = 2^nf;
    disp(['##### Fcutoff = ' num2str(fcutoff) ' (Hz) ######']);
    [bz ap] = butter(Norder, fcutoff/(fs/2));
    [frsp freq] = freqz(bz,ap,Nrsl,fs);
    
    TMTFlpf = 10*log10(1./(1+(freq/fcutoff).^2));
    
    subplot(3,1,1)
    plot(freq,TMTFlpf, freq,20*log10(abs(frsp)),'--')
    axis([0 fs/2 -50 5]);
    grid on;
    
    subplot(3,1,2);
    PhaseDelay0 = phasedelay(bz,ap,Nrsl);
    GrpDelay0 = grpdelay(bz,ap,Nrsl);
    plot(1:Nrsl, PhaseDelay0 , 1:Nrsl, GrpDelay0,'--')
    [max(PhaseDelay0), PhaseDelay0(2), PhaseDelay0(fix(Nrsl*(fcutoff/(fs/2))))]
    [max(GrpDelay0), GrpDelay0(2), GrpDelay0(fix(Nrsl*(fcutoff/(fs/2))))]
    
    subplot(3,1,3);
    nPl = 1:100;
    out = filter(bz,ap,Imp);
    [val nMax ] = max(out);
    NumMax(nf) = nMax-21
    plot(nPl, Imp(nPl), nPl, out(nPl))
    
    disp('Return to continue >');
    pause
end;


