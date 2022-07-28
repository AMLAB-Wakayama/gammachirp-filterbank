%% ======================================================================  
%%  
%% README file for gammachirp auditory filterbank (GCFB)  
%%  
%% Copyright (c) 2006-2022  Wakayama University  
%% All rights reserved.  
%% By Toshio Irino , 20 Mar 2022
%%  
%% ======================================================================  
   
Gammchirp auditory filterbank [1]  
See _Readme.m in the individual directory.  

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

* GCFBv232:  Mar 2022 version  
	- Introducing DigitalRms1SPLdB for precise calculation. 
	- Renamed function names as GCFBv231_FunctionName --> GCFBv23_FunctionName
	- Other features are the same as in GCFBv231

* GCFBv233:  20 Mar 2022 version  
	- Parameter names with "OHC" and "IHC" were changed to "ACT" and "PAS"
	- Other features are the same as in GCFBv232
	- See arXiv preprint "arXiv_WHISgc22_I.pdf" [3] for the detail of GCFBv23


--- 
  
Reference:  
- [1] Toshio Irino and Roy D. Patterson, "A dynamic compressive gammachirp auditory filterbank" IEEE Trans. Audio, Speech, and Language Process., 14(6), pp.2222-2232, Nov. 2006. [doi:10.1109/TASL.2006.874669 ] 　   
- [2] Toshio Irino, "A new implementation of hearing impairment simulator WHIS based on the gammachirp auditory filterbank," Report of ASJ hearing commitee meeting, 11 Dec 2021 (Main text in Japanese, with English extended abstract)    
- [3] Toshio Irino, "WHIS: Hearing impairment simulator based on the gammachirp auditory filterbank," arXiv preprint, [arXiv.2206.06604], 
https://doi.org/10.48550/arXiv.2206.06604, 14 Jun 2022. 


---

Programs  (GCFBv23x and probably applicable for the latest version): 
  
- testGCFBv233.m :   test / example program. Execute this program first.  
  
- StartupGCFB.m :  Path setting. Execute this if necessary.  

- GCFBv233.m : main body  
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
	  - See GCFBv23_HearingLoss.m (lines 200-240) for detail   

- GCFBv23_EnvModLoss.m :  Envelop modulation (TMTF) loss calculation (beta version)  
	 
- GCFBv23_AnaEnvMod.m :  Modulation filterbank calculation (beta version)  
	  
- There are some other programs to show the characteristics of GCFB.   
  
Directories   
 - 	Document/ :  Related documents  
 -	Tool/ :  Tools for GCFB  (execute StartupGCFB.m to setpath)  

  
