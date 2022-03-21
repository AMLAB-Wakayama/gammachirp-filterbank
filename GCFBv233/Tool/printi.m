%
%	*** Print by a default size (portrate/landscape) ***
%	IRINO Toshio
%	12 Mar. 97
%
%       function  [OrgPP,OrgUnit,ModPP, ModUnit]
%			 = printi(SwSizeSet,SwPrint,SetCord),
%	INPUT SwSizeSet :  -1) Back to initialization
%			0) No setting
%			1) 1 graph  in A4 paper [subplot(111)] 
%                       2) 2 graphs in A4 paper [subplot(211)]
%                       3) Paper #1 [2, 7, 18*Mag, 14.4*Mag];
%                       4) Paper #2 [0.5, 4, 20, 19];
%                       5) Paper #3 Landscape of #1 : [7, 2, 18*Mag, 14.4*Mag];
%                       6) Paper #4 Landscape of #2 : [4, 0.5, 20, 19];
%	      SwPrint:  0) Just setting (default)
%			1) Query(GhostView/Printer) & Setting
%	      SetCord:  if length==4 :  SetCordinate 
%					[left bottom width hight]
%			if length==2 :  PageMaker PS Set [ 0 0 ] 
%			if length==1 :  Set Mag 
%				(valid only when SwSizeSet==3. default: 1)
%
function  [OrgPP, OrgUnit, ModPP, ModUnit] = printi(SwSizeSet,SwPrint,SetCord),

global OrgUnit OrigPP

if nargin < 1,	help printi; return; end;
if nargin < 2,	SwPrint = 0; end;
if nargin == 3 
	if length(SetCord) == 1 & SwSizeSet < 3,
	error('Magnitude parameter should be used as printi(3,1,Mag).')
	end;
end;

if length(OrgUnit) == 0,	OrgUnit = get(gcf,'PaperUnits');
				OrgPP   = get(gcf,'PaperPosition');
end;

if SwSizeSet <4, set(gcf,'PaperOrientation','portrait');
else             set(gcf,'PaperOrientation','landscape');
end;

if SwSizeSet == 0;
	disp('No Modification in PaperUnits / PaperPosition. Set Portrate.');
else
	MagDef = 1.2;
	Mag = 1;
	if nargin < 3, SetCord = Mag; end;
	if length(SetCord) == 1, 	Mag = SetCord; end;
	if length(SetCord) == 4,  	ModPP = SetCord;
	else
	if 	SwSizeSet == 1,  	ModPP = [0.5,6,17*MagDef,13*MagDef];
	elseif 	SwSizeSet == 2,		ModPP = [2,2,17,13*2];
	elseif 	SwSizeSet == 3,	
		ModPP = [2+12/2*MagDef*(1-Mag), 7+15/2*MagDef*(1-Mag), ...
			15*Mag*MagDef, 12*Mag*MagDef];
	elseif 	SwSizeSet == 4,		ModPP  = [0.5, 4, 20, 19];
	elseif 	SwSizeSet == 5,
		ModPP = [ 5+12/2*MagDef*(1-Mag), ...
		          3.5+15/2*MagDef*(1-Mag), ...
			15*Mag*MagDef, 12*Mag*MagDef];
	elseif 	SwSizeSet == 6,		ModPP  = [4, 0.5, 20, 19];
	elseif 	SwSizeSet == -1,	ModUnit = OrigUnit;  ModPP = OrigPP;
	else				help printi; error('Specify SwSizeSet!');
	end;
	end;

	if length(SetCord) == 2, ModPP(1:2) = SetCord(1:2);  end;

	ModUnit = 'centimeters'; 
	set(gcf,'PaperUnits',ModUnit);
	set(gcf,'PaperPosition',ModPP);
end;


Prnt = 'no';
if length(ModPP) > 0
str = sprintf('PaperPosition = [%4.1f  %4.1f  %4.1f  %4.1f]', ModPP);
else
PP = get(gcf,'PaperPosition');
str = sprintf( ...
  	'PaperPosition = No-Set. Current [%4.1f  %4.1f  %4.1f  %4.1f]', PP);
end;

if SwPrint == 1, % Query
fprintf([str '\n']);
Prnt = ...
input('Print Figure to [(p)rinter / (g)hostview / (f)ile / no (Ret) ] ','s');
if length(Prnt) < 1, Prnt = 'no'; end;
end;

ModUnit =  get(gcf,'PaperUnit');
ModPP 	=  get(gcf,'PaperPosition');
str = [ 'PaperUnit = ' ModUnit '   ' str];

if Prnt(1) == 'g',
	disp('*** Print to Ghostview ***');
	disp(str);
	FileName = [HomeDir '/tmp/tmp.ps'];
	str = ['print ' FileName];
	eval(str);
	if strcmp(computer,'HP700'), str = ['!remsh topos ghostview '  FileName];
	else			str = ['!ghostview '  FileName];
	end;
	eval(str);
	str = ['delete ' FileName];
	eval(str);
elseif Prnt(1) == 'p', 	
	disp('*** Print to Printer ***');
	disp(str);
	print -dps
elseif Prnt(1) == 'f', 	
	disp('*** Print to File ***');
	disp(['Current directory: ' pwd]);
	FileName = input('File Name : ','s');
	strP = ['print ' FileName];
	disp(strP);
	eval(strP);
else
	if SwSizeSet > 0,
	disp(['*** No Printing & Just Setting ''PaperPosition''  # ' ...
		 int2str(SwSizeSet) ' ***']);
	else
	disp(['*** No Printing & No Setting ''PaperPosition''  # ' ...
		 int2str(SwSizeSet) ' ***']);
	end;
	disp(str);
end;

%disp(['Modification Skelton: set(gcf, ''PaperUnit'' , ''centimeters'' )'])
%disp(['Modification Skelton: set(gcf, ''PaperPosition'',[2, 6, 17, 13])'])






