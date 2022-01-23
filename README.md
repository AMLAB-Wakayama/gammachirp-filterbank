%% ======================================================================  
%%  
%% README file for gammachirp auditory filterbank (GCFB)  
%%  
%% Copyright (c) 2006-2021  Wakayama University  
%% All rights reserved.  
%% By Toshio Irino , 5 Dec 2021  
%%  
%% ======================================================================  
   
Gammchirp auditory filterbank [1]  
See ReadmeFirst.m in the individual directory.  

Packages:  
* GCFBv211pack:  Dec 2018 version  
	- Sample-by-sample processing in the caluculation.  
	- It was used in the original GEDI/mrGEDI.  
  
* GCFBv221pack:  May 2020 version   
	- Frame-based processing was introduced.   
	       It is much faster than the GCFBv211 (about 40 to 100 times)  
	       when producing frame-wise auditory spectrogram.  
	- You may choose "frame-based" or "sample-by-sample" processing.  
	- It is used in the frame-based mrGEDI.  
  
* GCFBv231:  Nov 2021 version [2]  --> New algorithm
	- Absolute threshold and hearing loss (HL) were introduced.  
    	- It works only with frame-based processing.  
	- "Sample-by-sample" processing is not much changed from v211. 
	- This version is essential for hearing impairment simulator, WHISv300.  

--- 
  
Reference:  
- [1] Toshio Irino and Roy D. Patterson, "A dynamic compressive gammachirp auditory filterbank" IEEE Trans. Audio, Speech, and Language Process., 14(6), pp.2222-2232, Nov. 2006. [doi:10.1109/TASL.2006.874669 ] 　   
- [2] Toshio Irino, "A new implementation of hearing impairment simulator WHIS based on the gammachirp auditory filterbank," Report of ASJ hearing commitee meeting, 11 Dec 2021 (Main text in Japanese, with English extended abstract)    
--> English document is under preparation.  

---

Programs  (GCFBv231 and probably applicable for the latest version): 
  
- testGCFBv231.m :   test / example program. Execute this program first.  
  
- StartupGCFB.m :  Path setting. Execute this if necessary.  


- GCFBv231.m : main body  
	- Important functions and parameters (default)
	  - Eqlz2MeddisHCLevel.m  : input level control for simplicity. You may specify SPL more strictly.
	  - GCparam.OutMidCrct = 'FreeField'; % Sound source/position selection  
	  - GCparam.Ctrl = 'dynamic';    
	  - GCparam.DynHPAF.StrPrc = 'frame-base';  
	- Hearing loss (HL) parameters  
	  - GCparam.HLoss.Type = 'NH';   % normal hearing  
      - GCparam.HLoss.Type = 'HL0'; % manual setting  
	       Example of setting:  GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 12 28 39] +5;  % HL4+5dB   
      - GCparam.HLoss.Type = 'HL1' ~ 'HL8' % various types of example hearing loss   
	  - See GCFBv231_HearingLoss.m (lines 200-240) for detail   
   
- GCFBv231_EnvModLoss.m :  Envelop modulation (TMTF) loss calculation (beta version)  
	 
- GCFBv231_AnaEnvMod.m :  Modulation filterbank calculation (beta version)  
	  
- ShowIOfunction_ExctPtn_GCFBv231.m :  Show Input-output function based on excitation pattern  
  
- ShowIOfunction_AsymFunc_GCFBv231.m :  Show Input-output function by Asymmetric Function   
  
- There are some other programs to show the characteristics of GCFB.   
  
Directories   
 - 	Fig/ :  Some figures derived from the sample programs and related documents  
 -	Tools/ :  Tools for GCFB  (execute StartupGCFB.m to setpath)  

  