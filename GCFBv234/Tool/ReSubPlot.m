%
%	Refined Subplot
%	irino
%	Created: 6 Oct. 94
%	Modified: 11 Jan 2007
%	Modified: 10 Jul 2008 (adding examples)
%
%	function rect = ReSubPlot(NumY,NumX,NumN,SizeVct,Scale)
%		Input : NumY	: Number of division in Y axis
%			NumX	: Number of division in X axis
%			NumX	: Number of current Plot
%			SizeVct: Absolute Size Vector for [X; Y];
%				  ex : [0.35 0.35 0.1; 0.35 0.35 0.1  ];
%				  condition: sum(XSizeVct or YSizeVct) < 0.9 
%                                 if single raw assuming YSizeVct
%                                    for compativility. ex : [0.1 0.3 0.3 ];
%			Scale: Scale of picture [ScaleVal, ScaleBias(1:2)]
%	
% Examples:
%  ReSubPlot(2,1,0);
%  ReSubPlot(1,2,0,[0.7 0.15 0.1; 0.85 0.85 0.1]);
%  ReSubPlot(1,2,0,[0.7 0.15 0.1; 0.85 0.85 0.1],[0.98,0.02,0.02]);
%
function rect = ReSubPlot(NumY,NumX,NumN,SizeVct,Scale)

if nargin < 2, 	help ReSubPlot; error('Specify full params.'); end;

  Sprt = 0.02;
  WidthAll = 0.85;
  HightAll = 0.85;
  XSizeVct = (WidthAll-Sprt*(NumX-1))/NumX * ones(1,NumX);
  YSizeVct = (HightAll-Sprt*(NumY-1))/NumY * ones(1,NumY);

  if nargin >= 4
    [nxy, LenSizeVct] = size(SizeVct);
    if nxy == 1, YSizeVct = SizeVct(1:NumY); % for consistency with old one
    else         XSizeVct = SizeVct(1,1:NumX); 
                 YSizeVct = SizeVct(2,1:NumY);
    end;
  end;

  if sum(XSizeVct) > 0.9 | sum(YSizeVct) > 0.9
    help ReSubPlot
    error('sum(XSizeVct or YSizeVct) should be less than 0.9.'); 
  end;

  BottomVal = max(0.1, (1-sum(YSizeVct)-Sprt*(NumY-1))/2);
  for nnn = 2:NumY, 
    BottomVal(nnn) = BottomVal(nnn-1)+YSizeVct(NumY-nnn+2)+Sprt; 
  end;
  BottomVal = fliplr(BottomVal);

  LeftVal = max(0.1, (1-sum(XSizeVct)-Sprt*(NumX-1))/2);
  for nnn = 2:NumX, 
    LeftVal(nnn) = LeftVal(nnn-1)+XSizeVct(nnn-1)+Sprt; 
  end;

  NumAll = 1:NumX*NumY;
  RectVct(1,NumAll) = reshape(LeftVal'*ones(1,NumY),1,NumX*NumY); % left
  RectVct(2,NumAll) = reshape(ones(NumX,1)*BottomVal,1,NumX*NumY);  % bottom 
  RectVct(3,NumAll) = reshape(XSizeVct(1:NumX)'*ones(1,NumY),1,NumX*NumY);%w
  RectVct(4,NumAll) = reshape(ones(NumX,1)*YSizeVct(1:NumY),1,NumX*NumY); %h

if nargin < 5, Scale = [1 0 0]; end;
if length(Scale) == 1, Scale = [Scale 0 0]; end;

%  RectVct
%%%%%%%%%%% Plot them all %%%%%

npl = NumN;
if npl == 0, 
  npl = 1:NumX*NumY; 
  if length(YSizeVct) > 0, npl = NumX*NumY:-1:1; end; % 11 Jan 2007
end;


for NumPanel = npl,
  subplot(NumY,NumX,NumPanel)
  title('');

  if NumPanel <= (NumY-1)*NumX,	% remove labels
    xlabel(''); 
    set(gca,'XTickLabel',''); 
  end;

  if rem(NumPanel-1,NumX) > 0,	
    ylabel('');
    set(gca,'YTickLabel',''); 
  end;

  rect = RectVct(:,NumPanel)';

  rect = rect*Scale(1) + [ Scale(2:3) 0 0];
  set(gca,'Position',rect); 
  drawnow

end;

