function plotSales(t,x,plotStyle,varargin)
%  PLOTSALES Plot sales pre-structured with all labels and titles necessary
% 
% Handles different scenerios by automatically scaling the y-axis and adapting 
% labels correspondingly, also adds lines like average values or user specified 
% ones if needed.
% First we validate all values
p = inputParser;
checkDates = @(x) (isnumeric(x) || isdatetime(x));
defaultPlotStyle = 'sales';
validPlotStyle = {'sales','$','quantity','qty'};
checkPlotStyle = @(x) any(validatestring(x,validPlotStyle));
defaultLineStyle = '-';
validLineStyle = {'-','--','-.',':','none'};
checkLineStyle = @(x) any(validatestring(x,validLineStyle));
defaultMarker = 'none';
validMarker = {'o','+','*','.','x','_','|','s','d','^','v','>','<','p','h','none'};
checkMarker = @(x) any(validatestring(x,validMarker));
defaultLines = {''};
validLines = {'mean','x0','y0'};
checkLinesBase = @(x) any(validatestring(x,validLines));
checkLines = @(x) all(cellfun(checkLinesBase,x));
defaultScale = 'on';
validScales = {'on','off'};
checkScales = @(x) any(validatestring(x,validScales));
defaultX0 = '';
defaultY0 = '';
defaultColors = [0.4 0.5 1; 0 0 0];
checkColors = @(x) (isnumeric(x) && size(x,2)==3);
addRequired(p,'t',checkDates);
addRequired(p,'x',@isnumeric);
addOptional(p,'plotStyle',defaultPlotStyle,checkPlotStyle);
addParameter(p,'lineStyle',defaultLineStyle,checkLineStyle);
addParameter(p,'marker',defaultMarker,checkMarker);
addParameter(p,'lines',defaultLines,checkLines);
addParameter(p,'autoscale',defaultScale,checkScales);
addParameter(p,'x0',defaultX0,checkDates);
addParameter(p,'y0',defaultY0,checkDates);
addParameter(p,'colors',defaultColors,checkColors);
% p.KeepUnmatched = true;
parse(p,t,x,plotStyle,varargin{:})
% Now adapt labels and formats
if(strcmpi(p.Results.plotStyle,'sales') || strcmpi(p.Results.plotStyle,'$'))
    y_label = 'Sales';
    le_title = 'Sales each day';
    symbol = '$';
elseif(strcmpi(p.Results.plotStyle,'quantity') || strcmpi(p.Results.plotStyle,'qty'))
    y_label = 'Quantity';
    le_title = 'Number of items sold each day';
    symbol = '';
end
y_format = [symbol '%,.0f'];
scale = 1;
if(strcmpi(p.Results.autoscale,'on'))
    if(max(p.Results.x)>1.5e7)
        y_format = [symbol '%,.0fM'];
        scale = 1/1e6;
    elseif(max(p.Results.x)>1.5e4)
        y_format = [symbol '%,.0fk'];
        scale = 1/1e3;
    end
end
% And the actual plot
plot(p.Results.t,p.Results.x*scale,'Color',p.Results.colors(1,:),'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
% And extras
if(~any(cellfun(@isempty,p.Results.lines)))
    hold on;
    legend_text = {'Data'};
    if(any(strcmpi(p.Results.lines,'mean')))
        line([p.Results.t(1) p.Results.t(end)],mean(p.Results.x)*scale*[1 1],...
        'LineWidth',1,'color',p.Results.colors(2,:),'linestyle','--')
        legend_text = [legend_text 'Average'];
    end
    if(~isempty(p.Results.x0))
        for i = 1:length(p.Results.x0)            
            line([p.Results.x0(i) p.Results.x0(i)],scale*[min(p.Results.x) max(p.Results.x)],...
                  'LineWidth',1,'color',p.Results.colors(2,:),'linestyle','-')
            if(any(strcmpi(p.Results.lines,'x0')))
                legend_text = [legend_text datestr(p.Results.x0(i))];
            end
        end
    end    
    hold off;
    legend(legend_text);
end
if(isdatetime(p.Results.t))
    if(length(unique(p.Results.t.Year))>1)
        datetick('x','mm-yyyy')
    else
        xtickformat('MMM')
    end    
end
ytickformat(y_format)
ylabel(y_label)
title(le_title)
grid on
end