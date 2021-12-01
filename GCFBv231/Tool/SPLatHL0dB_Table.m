%
%   Table of corresponding between HL and SPL
%   Irino T.,
%   Created:  21 Feb 2018  ( ANSI S3.6-1996 standard)
%   Modified:  21 Feb 2018  ( ANSI S3.6-1996 standard)
%   Modified:  23 Feb 2018  Table を独立のファイルとして
%   Modified:  24 May 2018  ANSI S3.6-2010 standardの値を導入。中間の周波数の値が新たに追加されている。
%   Modified:    6 Jun  2018  勘違いを修正。Noteに記述
%
% function   [Table] = TableSPLatHL0dB(SwYear)
% INPUT:  SwYear
% OUTPUT:   Table.freq : 周波数
%                   Table.SPLatHL0dB : SPL dB
% ------------------------------------------------------------
% Information:
% ------------------------------------------------------------
%
%  Note: 21 Feb 2018
% ANSI_S3.6-1996の情報
% http://hearinglosshelp.com/blog/understanding-the-difference-between-sound-pressure-level-spl-and-hearing-level-hl-in-measuring-hearing-loss/
% ANSI_S3.6-2004の情報
% https://www.researchgate.net/publication/284004608_Audiometric_calibration_Air_conduction
% ANSI_S3.6-2010の情報：　2018/5/24. document入手。ASA会員は5本までstandardを無料入手可
%
% Note: 6 May 2018
%       1996もオージオメータ測定以外の中間の周波数あり。
%       数値も、イヤホンがTDH Type IEC318 の場合、2010と 全く同じ
%       SwYearで分けるのはふさわしくない。--> 消去
%        SPLatHL0dB_Table(SwYear) --> SPLatHL0dB_Table
%
%
function  [Table] = SPLatHL0dB_Table

%  ANSI_S3.6-2010 (1996)の中間の周波数も含むTable
    %周波数が多すぎるので、一対ずつ記載
    Freq_SPLdBatHL0dB_List = ...
        [125, 45.0; 160, 38.5; 200, 32.5; ...
        250, 27.0; 315, 22.0; 400, 17.0; ...
        500, 13.5; 630, 10.5; 750, 9.0; 800, 8.5;  ...
        1000, 7.5; 1250, 7.5; 1500, 7.5; 1600, 8.0; ...
        2000, 9.0; 2500, 10.5; 3000, 11.5; 3150, 11.5; ...
        4000, 12.0; 5000, 11.0; 6000, 16.0; 6300, 21.0; ...
        8000, 15.5];
    Speech = 20.0; % ANSI_S3.6_2010;
    
    Table.freq = Freq_SPLdBatHL0dB_List(:,1)';
    Table.SPLatHL0dB = Freq_SPLdBatHL0dB_List(:,2)';
    Table.Speech = 20.0;
    Table.Standard = 'ANSI-S3.6_2010';
    Table.Earphone = 'Any supra aural earphone having the characteristics described in clause 9.1.1 or ISO 389-1'; 
            %イヤホン。ANSI-S3.6_2010の規格書のp.26 Table 5 の注釈aに記述されているとおり。
    Table.AirficialEar = 'IEC 60318-1';  % 人工耳。これで測定して、校正もされる。

    
% 参考 21 Feb 2018に書いた部分。
% オージオメータの測定周波数だけに関してのTable
    %Freq_ANSI_S36_1996_Augiogram     = [125  250  500  750 1000 1500 2000 3000 4000 6000 8000];
    %SPLdBatHL0dB_ANSI_S36_1996_Augiogram     = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5];
                                                    % ANSI_S36_1996は、Rion AA79, AA74で採用されているものと同じ
    % Table.freq_Audiogram = Freq_ANSI_S36_1996_Augiogram; 不要
    % Table.SPLatHL0dB_Audiogram = SPLdBatHL0dB_ANSI_S36_1996_Augiogram; 不要
    % オージオメータの周波数のみピックアップ　：　意味ない気がするのでやめる。外で行えば良い。    
    
return;

%% %%%%%%%%%%%%%%%%%%%%%%%%%

% ------------------------------------------------------------
% Information:いままでの経緯
% ------------------------------------------------------------
%
% Note:
% Rion AA-79 AD-02
% http://www.rion.co.jp/dbcon/pdf/AA-79.pdf
%
% http://www20.big.or.jp/~ent/kikoe/db_hz.htm
%・オージオメータでの純音聴力検査で０ｄＢはＪＩＳ規格により、標準カップラー（ＮＢＳ９Ａカップラー）内で表の音圧になるように定められている。
%
% この音圧は商用されている国産受話器によってそれぞれ定められており、表の（　）内の値はＡＤ?０２の場合です。
% 聞き取る最小の音圧、最小可聴閾値が下の表であるとき、聴力レベルが０ｄＢであるといいます。
% これより大きな値の時は、基準となる下表の値との差に従い、聴力レベルプラス何ｄＢ（ＨＬ）と言います。
%
% オージオメータの出力レベル目盛りが０ｄＢの時の検査音の強さは表のとおりです。
%
% 周波数 Ｈｚ	125	250	500	1000	1500	2000	3000	4000	6000	8000
% 音圧　ｄＢ＊	45.5	24.5	11.0	6.5	6.5	8.5	7.5	9.0	8.0	9.5
% 0dB＝20μPa	(47.5)	(27.0)	(13.0)	(7.0)	(6.5)	(7.0)	(8.0)	(9.5)	(12.0)	(16.5)
%
%・スピーカ等の音場での音圧ＳＰＬをｄＢＨＬに換算する場合の計算
% ２５０ＨｚはｄＢＳＰＬはｄＢＨＬに１４、５００Ｈｚは９、１０００Ｈｚは７、２００ ０Ｈｚは４、４０００Ｈｚは?１を足しますとｄＢＨＬがｄＢＳＰＬに換算できます。
%
% SPLdBatHL0dB_Kikoe  = [45.5 24.5 11.0 NaN 6.5  6.5  8.5  7.5  9.0   8.0  9.5];
% SPLdBatHL0dB_AD02   = [47.5 27.0 13.0 NaN 7.0  6.5  7.0  8.0  9.5  12.0 16.5];
%
% SPLdBatHL0dB_AA79   = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5];
%      ※気導:0dB = 20μPa(IEC 60318-1人工耳による)
%
% 日医
% http://www.nihon-iryouki.jp/index.php?main_page=page&id=13&chapter=0
% SPLdBatHL0dB_NichiI = [NaN  NaN  13.5 NaN 7.5  NaN  9.0  11.5 12  16   NaN]; % NichiI
%
% http://www.audiology-japan.jp/yougo/AudiologyJapanYougo.pdf
% 
% ------------------------------------------------------------
%
%  Memo:  AA79をreferenceとして用いることにしています。29 Feb 2012　
%         SPLdBatHL0dB_AA79という変数名が無かったため追加。（値は変化無し）　7 Jan 2014
%
% ------------------------------------------------------------
%
%  Note: 21 Feb 2018
% ANSI_S3.9-1996の情報
% http://hearinglosshelp.com/blog/understanding-the-difference-between-sound-pressure-level-spl-and-hearing-level-hl-in-measuring-hearing-loss/
%
%
%FreqRef               = [125  250  500  750 1000 1500 2000 3000 4000 6000 8000];
%SPLdBatHL0dB_ANSI_S39_1996     = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5];
% これは、SPLdBatHL0dB_AA79で採用されているものと同じ
% SPLdBatHL0dB_AD02B  = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5]; % Rion AA-79
% SPLdBatHL0dB_Kikoe  = [45.5 24.5 11.0 NaN 6.5  6.5  8.5  7.5  9.0   8.0  9.5];
% SPLdBatHL0dB_AD02   = [47.5 27.0 13.0 NaN 7.0  6.5  7.0  8.0  9.5  12.0 16.5];
% SPLdBatHL0dB_NichiI = [NaN  NaN  13.5 NaN 7.5  NaN  9.0  11.5 12  16   NaN]; % NichiI



