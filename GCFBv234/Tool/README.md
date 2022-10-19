%% ======================================================================
%%
%% README file for gammachirp auditory filterbank (GCFB)
%%
%% Copyright (c) 2006-2020 Wakayama University
%% All rights reserved.
%% By Toshio Irino , 23-07-2020
%% ======================================================================
%%
Gammchirp auditory filterbank
See ReadmeFirst.m in the individual directory.

Packages:
GCFBv211pack:  Dec 2018 version
	       Sample-by-sample processing in the caluculation.
	       It was used in the original GEDI/mrGEDI.

GCFBv221pack:  May 2020 version 
	       Frame-based processing was introduced. 
	       It is much faster than the GCFBv211 (about 40 to 100 times)
	       when producing frame-wise auditory spectrogram.
	       You may choose "frame-based" or "sample-by-sample" processing.
	       It is used in the frame-based mrGEDI.
				   
Ref: 
Toshio Irino and Roy D. Patterson, "A dynamic compressive gammachirp auditory filterbank" IEEE Trans. Audio, Speech, and Language Process., 14(6), pp.2222-2232, Nov. 2006. [doi:10.1109/TASL.2006.874669 ] *			   




