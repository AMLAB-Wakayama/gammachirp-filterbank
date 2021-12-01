%
%   HL to  Pinput level at cochlea
%   Irino T.,
%   Created: 16 Aug 2021  from HL2SPL
%   Modified: 16 Aug 2021 
%
% function   [PinCchdB] = HL2PinCochlea(freq,HLdB)
% INPUT:  freq 
%              HLdB:  Hearing Level dB
% OUTPUT: PinCchdB :  Cochlear Input level dB
%
function  [PinCchdB] = HL2PinCochlea(freq,HLdB)

[SPLdB] = HL2SPL(freq,HLdB);

[dummy, FrspMEdB ] = TransFuncMiddleEar_Moore16(freq);
PinCchdB = SPLdB+FrspMEdB;

return

