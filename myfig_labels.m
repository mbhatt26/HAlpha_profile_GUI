%function myfig_labels(fh,xtext,ytext,font_size,varargin);
%
% Customize a Matlab plot and turn background of plot white.
%
% Required...
%
% fh		figure handle
% xtext		xlabel text
% ytext		ylabel text
% font_size	font size for axes labels
%
% varargin ...
%
% 'Title'	[] plot title
% 'Font'	['Courier'] font name
% 'AWidth'	[2] axes line width
%
% ASigut 8 December 2017
%
function myfig_labels(fh,xtext,ytext,font_size,varargin);

if mod(length(varargin),2) ~= 0
  disp(' ')
  disp('Error: mis-match (odd number) of vargargin inputs')
  disp(' ')
  funcOutput=[];
  return
end

my_title=[];
my_font='Courier';
line_width_axes=2;

for i=1:2:length(varargin)
    idone=0;
    if strcmp(varargin{i},'Title') == 1
       my_title=varargin{i+1};
       idone=1;
    end
    if strcmp(varargin{i},'Font') == 1
       my_font=varargin{i+1};
       idone=1;
    end
    if strcmp(varargin{i},'AxisWidth') == 1
       line_wdith_axes=varargin{i+1};
       idone=1;
    end
    if idone == 0
       disp(' ')
       disp(sprintf('WARNING: unknown varargin %s',varargin{i}))
       disp(' ')
    end
end

if isempty(fh)
   fh=gcf;
   set(fh,'color','w')
else
   figure(fh);
   set(fh,'color','w')
end

xlabel(xtext,'FontWeight','Bold','FontSize',font_size);
ylabel(ytext,'FontWeight','Bold','FontSize',font_size);

if ~isempty(my_title)
   title(my_title,'FontWeight','Bold','FontSize',font_size);
end

font_size_axes=round(0.875*font_size);

set(gca,'FontWeight','Bold','LineWidth',line_width_axes,...
        'FontName',my_font,'FontSize',font_size_axes);
