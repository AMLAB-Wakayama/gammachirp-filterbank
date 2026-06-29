function y = MeddisHairCell(data,sampleRate,subtractSpont)
% y = MeddisHairCell(data,sampleRate)
% This function calculates Ray Meddis' hair cell model for a
% number of channels.  Data is arrayed as one channel per row.
% All channels are done in parallel (but each time step is
% sequential) so it will be much more efficient to process lots
% of channels at once.

% (c) 1998 Interval Research Corporation  
% Changed h and added comment at suggestion of Alain de Cheveigne'   12/11/98
%

%
% Modified by T. Irino
% Modified: 7 Jun 2004:  spont --> h*spont
% Modified: 25 May 2006:  memo
% 


if (nargin<3),  subtractSpont=0;  end

% Parameters from Meddis' April 1990 JASA paper.
M = 1;
A = 5;
B = 300;
g = 2000;
y = 5.05;
l = 2500;
r = 6580;
x = 66.31;
h = 50000;	% This parameter scales the discharge rate. Adjust as necessary.
		% In combination with the gammatone filterbank (ERBFilterBank),
		% h=50000 will produce a steady-state average discharge
		% probability of about 135 spikes/s within the 1kHz channel,
		% for an input consisting of a 1 kHz sinewave at 60 dB SPL
		% (0 dB SPL corresponds to an RMS level of 1.0 at the
		% input of the gammatone filter).  Scaling and constant 
		% courtesy of Alain de Cheveigne'
%
%  [Note by T. Irino (7 Jun 2004, modified 25 May 2006)]
%  This description is pazzling. 
%  "h = 50000;" is the original value in Fig 2 of Meddis et al. 1990.
%  Signal Level by Meddis (1986)
%  rms(s(t)) == mean(s^2(t)) == 1  -->  Level 30 dB SPL 
%  So I assume that this level is also used in this parameter set.
%  
%  Let's test by "testMeddisHairCell.m"
%  Sinusoid (60 dB SPL in Meddis Level) produces 257 (spike/s).
%  Please use this under your control.
%

% Internal constants
dt = 1/sampleRate;
gdt = g*dt;
ydt = y*dt;
ldt = l*dt;
rdt = r*dt;
xdt = x*dt;
[numChannels dataLength] = size(data);

% Initial values 
kt = g*A/(A+B);
spont = M*y*kt/(l*kt+y*(l+r));
c = spont * ones(numChannels,1);
q = c*(l+r)/kt;
w = c*r/x;
zeroVector = zeros(numChannels,1);

% Now iterate through each time slice of the data.  Use the
% max function to implement the "if (0>" test.
y = zeros(numChannels, dataLength);
for i = 1:dataLength
 limitedSt = max(data(:,i)+A,0);
 kt = gdt*limitedSt./(limitedSt+B);
 replenish = max(ydt*(M-q),zeroVector);
 eject = kt.*q;
 loss = ldt.*c;
 reuptake = rdt.*c;
 reprocess = xdt.*w;

 q = q + replenish - eject + reprocess;
 c = c + eject - loss - reuptake;
 w = w + reuptake - reprocess;
 y(:,i) = c;
end

y = h .* y;

if (subtractSpont > 0)
 y=max(0,y-h*spont);     % fixed bug by IT (7 Jun 2004) spont --> h*spont
end
