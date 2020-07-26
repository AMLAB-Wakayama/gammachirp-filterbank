%
%       Test GCFBv220 (for GCFBpack)
%       Toshio IRINO
%       Created:   15 Sep 2005 (for v205)
%       Modified:   7 Apr 2006 (v206, Compensation of Group delay OutMidCrct)
%       Modified:  23 Dec 2006 (v207, 'dynamic' rather than 'time-varying')
%       Modified:  18 Mar 2007 (check. modifying title)
%       Modified:  25 Jul 2007 (GCresp)
%       Modified:   5 Aug 2007 (Elapsed time)
%       Modified:  26 Jun 2013
%       Modified:  25 Nov 2013 (v209)
%       Modified:  18 Apr 2015 (v210, include GCresp in GCFBv210_SetParam )
%       Modified:  13 May 2015 (v210, debug & comparison)
%       Modified:    5 Dec 2018  (v211,  No software modification in the main. remove 209.)
%       Modified:  14 May 2020  (for checking processing speed)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%
%
clear
%close all

%%%% Stimuli : a simple pulse train %%%%
fs = 48000;
Tp = 0.010; % = 10 (ms) 100 Hz pulse train
Snd1 = [1, zeros(1,Tp*fs-1)];
Snd = [];
Tsnd = 0.1; % sec
%Tsnd = 0.2; % sec

for nnn = 1:Tsnd/Tp,
    %for nnn = 1:3,
    Snd = [Snd1 Snd];
end;
rng(123);
Snd = randn(1,Tsnd*fs);
Tsnd = length(Snd)/fs;
disp(['Duration of sound = ' num2str(Tsnd*1000) ' (ms)']);

SigSPLlist = [40:20:80]
%SigSPLlist = [60]

cnt = 0;
for SwDySt =  1 % only dynamic
    figure(SwDySt);
    
    for SwSPL = 1:length(SigSPLlist)
        figure(SwSPL)
        cnt = cnt+1;
        SigSPL = SigSPLlist(SwSPL);
        Snd =  Eqlz2MeddisHCLevel(Snd,SigSPL);
        
        %%%% GCFB %%%%
        GCparam = []; % reset all
        GCparam.fs     = fs;
        GCparam.NumCh  = 100;
        GCparam.FRange = [100, 6000];
        
        GCparam.OutMidCrct = 'No';
        GCparam.OutMidCrct = 'ELC';
        
        if SwDySt == 1, GCparam.Ctrl = 'dynamic'; % used to be 'time-varying'
        else    GCparam.Ctrl = 'static'; % or 'fixed'
        end;
        
        NameSave = [getenv('HOME')  '/tmp/cGCoutRsp' int2str(SigSPLlist(SwSPL)) '.mat'];
        delete(NameSave)   % for reset
        if exist(NameSave) == 2,
            load(NameSave) 
        else
            tic
            GCparam.DynHPAF.StrPrc = 'sample-by-sample';
            [cGCout, pGCout,GCparam,GCresp] = GCFBv221(Snd,GCparam);
            tm = toc;
            disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
                num2str(tm/Tsnd,4) ' times RealTime.']);
            disp(' ');
            save(NameSave,'cGCout','pGCout', 'GCparam', 'GCresp')
        end;
        
        GCparam.DynHPAF.StrPrc = 'frame-base';
        tic
        [cGCframe, pGCframe,GCparam,GCrespFrame] = GCFBv221(Snd,GCparam);
        tm = toc;
        disp(['Elapsed time is ' num2str(tm,4) ' (sec) = ' ...
            num2str(tm/Tsnd,4) ' times RealTime.']);
        disp(' ');
        Telapse(cnt) = tm;

        %%%%% Making Spectrogram from Dynamic cGCout
        for nch = 1:GCparam.NumCh
                [cGCsbsFrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
                    cGCout(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
                [LenFrame, NumFrame] = size(cGCsbsFrameMtrx);
                cGCsbsFrame(nch,1:NumFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(cGCsbsFrameMtrx.^2));  % weighted mean
                % cGCsbsFrame(nch,1:NumFrame) = GCparam.DynHPAF.ValWin(:)'*abs(cGCsbsFrameMtrx); % NG
        end;

        % normalization
        [max(max(cGCsbsFrame)) max(max(cGCframe))]
       % cGCsbsFrame = cGCsbsFrame/max(max(cGCsbsFrame));
        % cGCframe = cGCframe/max(max(cGCframe));

        ErrRMS = sqrt(mean(mean((cGCsbsFrame-cGCframe).^2))/mean(mean(cGCsbsFrame.^2)));
        ErrdB = 20*log10(ErrRMS)

        % [mean(mean(GCresp.LvldB)) mean(mean(GCrespFrame.LvldB))]
        %figure(2)
        %nch = 50;
        %plot((0:length(GCresp.LvldB)-1)/fs*1000, GCresp.LvldB(nch,:), ...
        %    (0:length(GCrespFrame.LvldB(nch,:))-1)*GCparam.DynHPAF.Tshift*1000,GCrespFrame.LvldB(nch,:), '--')
            
        % figure(1);
        % subplot(length(SigSPLlist),1,SwSPL)
        amp = 5;
        subplot(3,1,1)
        image(amp*max(cGCsbsFrame,0));
        set(gca,'YDir','normal');
        title('SbS --> Frame')

        subplot(3,1,2)
        image(amp*max(cGCframe,0));
        set(gca,'YDir','normal');
        title('Frame base')
 
        subplot(3,1,3)
        image(amp*(abs(cGCsbsFrame-cGCframe)));
        set(gca,'YDir','normal');
        title('Abs(diff)')
        
        figure(SwSPL+10)
        %nchList = [95:-20:15];
        nchList = [90:-20:10];
        for nc = 1:length(nchList)
            subplot(length(nchList),1,nc)
            nch = nchList(nc);
            nn = 1:NumFrame;
            plot(nn,cGCsbsFrame(nch,nn),nn,cGCframe(nch,nn) ,'--' ,nn,pGCframe(nch,nn),':');
            ax = axis;
            text(5,ax(4)*0.9,['ch #' int2str(nch)])
            maxY = ceil(max([cGCsbsFrame(nch,:), cGCframe(nch,:)]));
            axis([ax(1:2), 0 , maxY]);
        end;    
        
        drawnow
    end;
end;
