function [ax] = plot_sessionsBack2Back(ax, plotNorm, analysis, data2plot, exptName)
% X-axis contains the first session and the second session (vsaSentence).
% SDB 3-2024

if isempty(plotNorm); plotNorm = true; end  % plot normalized rather than raw values
if isempty(analysis); analysis = 'duration'; end % options: 'AVS', 'VSA4', 'VSA3', 'AAVS', 'duration', 'intensityMax', 'intensityMean', 'f0Max', 'f0Mean', 'f0Range'

if nargin < 5 || isempty(exptName)
    exptName = 'vsaSentence';
end

a1 = [data2plot.adaptFirst];
c1 = [data2plot.controlFirst];
a2 = [data2plot.adaptSecond]; 
c2 = [data2plot.controlSecond]; 

adaptColor        = [237 28 26] ./ 255;
controlColor      = [4 75 214] ./ 255;
adaptLightColor   = brighten(adaptColor, 0.7);
controlLightColor = brighten(controlColor, 0.7);
adaptDarkColor    = brighten(adaptColor, -0.7);
controlDarkColor  = brighten(controlColor, -0.7);
shadeColor        = [0.9 0.9 0.9];       % light grey
shadeColor2       = [0.68 0.68 0.68];    % dark grey


lineWidth = 1.25;
markerSize = 6;
fontSize = 9;
labelSize = 11;

hold on;
switch exptName
    case 'vsaSentence'

% first sessions
errorbar(1, mean(c1(:,1)), ste(c1(:,1)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(3.2, mean(c1(:,3)), ste(c1(:,3)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5:11, mean(c1(:,5:11)), ste(c1(:,5:11)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(13, mean(c1(:,13)), ste(c1(:,13)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(14, mean(c1(:,14)), ste(c1(:,14)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2, mean(c1(:,2)), ste(c1(:,2)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(4.2, mean(c1(:,4)), ste(c1(:,4)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(12, mean(c1(:,12)), ste(c1(:,12)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

errorbar(1, mean(a1(:,1)), ste(a1(:,1)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2.8, mean(a1(:,3)), ste(a1(:,3)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5:11, mean(a1(:,5:11)), ste(a1(:,5:11)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(13, mean(a1(:,13)), ste(a1(:,13)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(14, mean(a1(:,14)), ste(a1(:,14)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2, mean(a1(:,2)), ste(a1(:,2)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(3.8, mean(a1(:,4)), ste(a1(:,4)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(12, mean(a1(:,12)), ste(a1(:,12)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

% second sessions
errorbar(17, mean(c2(:,1)), ste(c2(:,1)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(19, mean(c2(:,3)), ste(c2(:,3)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(21:27, mean(c2(:,5:11)), ste(c2(:,5:11)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(29, mean(c2(:,13)), ste(c2(:,13)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(30, mean(c2(:,14)), ste(c2(:,14)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(18, mean(c2(:,2)), ste(c2(:,2)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(20, mean(c2(:,4)), ste(c2(:,4)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(28, mean(c2(:,12)), ste(c2(:,12)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

errorbar(17, mean(a2(:,1)), ste(a2(:,1)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(19, mean(a2(:,3)), ste(a2(:,3)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(21:27, mean(a2(:,5:11)), ste(a2(:,5:11)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(29, mean(a2(:,13)), ste(a2(:,13)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(30, mean(a2(:,14)), ste(a2(:,14)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(18, mean(a2(:,2)), ste(a2(:,2)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(20, mean(a2(:,4)), ste(a2(:,4)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(28, mean(a2(:,12)), ste(a2(:,12)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

    case {'vsaPD', 'vsaPD_poster'}
        % for baselineSentence, baselinePassage, baselineTransfer phases, plot points at an offset to zero for legibility
        xPos_adapt   = [1 2 3 4 5 6.2 7.2 8.2 9 10 11 12 13 14 15 16 17 18];
        xPos_control = [1 2 3 4 5 5.8 6.8 7.8 9 10 11 12 13 14 15 16 17 18];
        nConds2plot = length(xPos_adapt);
        visit2offset = xPos_adapt(end); % how much further to the right to start plotting the visit 2 data

        % visit 1 control
        for i = 1:nConds2plot
            errorbar(xPos_control(i),  mean(c1(:,i)), ste(c1(:,i)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 1 adapt
        for i = 1:nConds2plot
            errorbar(xPos_adapt(i),  mean(a1(:,i)), ste(a1(:,i)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 2 control
        for i = 1:nConds2plot
            errorbar(xPos_control(i)+visit2offset,  mean(c2(:,i)), ste(c2(:,i)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 2 adapt
        for i = 1:nConds2plot
            errorbar(xPos_adapt(i)+visit2offset,  mean(a2(:,i)), ste(a2(:,i)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        
    case 'vsaSponSpeechPilot'
        % for baselinePassage and baselineTransfer phases, plot points at an offset to zero for legibility
        xPos_adapt   = [1 2 3 4 5 6.2 7.2 8 9 10 11];
        xPos_control = [1 2 3 4 5 5.8 6.8 8 9 10 11];
        nConds2plot = length(xPos_adapt);
        visit2offset = xPos_adapt(end); % how much further to the right to start plotting the visit 2 data
        
        % visit 1 control
        for i = 1:nConds2plot
            errorbar(xPos_control(i),  mean(c1(:,i)), ste(c1(:,i)), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 1 adapt
        for i = 1:nConds2plot
            errorbar(xPos_adapt(i),  mean(a1(:,i)), ste(a1(:,i)), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 2 control
        for i = 1:nConds2plot
            errorbar(xPos_control(i)+visit2offset,  mean(c2(:,i)), ste(c2(:,i)), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 2 adapt
        for i = 1:nConds2plot
            errorbar(xPos_adapt(i)+visit2offset,  mean(a2(:,i)), ste(a2(:,i)), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end


    case 'vsaCP'
        conds2run = 1:16;
        % TODO these positions aren't correct, since there are some conditions that are skipped

        % for baselinePassage and baselineTransfer phases, plot points at an offset to zero for legibility
        xPos_adapt   = [1 2 3 4 5 6.2 7.2 8 9 10 11 12 13 14 15 16];
        xPos_control = [1 2 3 4 5 5.8 6.8 8 9 10 11 12 13 14 15 16];
        nConds2plot = length(xPos_adapt);
        visit2offset = xPos_adapt(end); % how much further to the right to start plotting the visit 2 data
        
        % visit 1 control
        for i = 1:nConds2plot
            errorbar(xPos_control(i),  mean(c1(:,conds2run(i))), ste(c1(:,conds2run(i))), 'd-', 'Color', controlDarkColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 1 adapt
        for i = 1:nConds2plot
            errorbar(xPos_adapt(i),  mean(a1(:,conds2run(i))), ste(a1(:,conds2run(i))), 's-', 'Color', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'MarkerEdgeColor', adaptLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 2 control
        for i = 1:nConds2plot
            errorbar(xPos_control(i)+visit2offset,  mean(c2(:,conds2run(i))), ste(c2(:,conds2run(i))), 's-', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % visit 2 adapt
        for i = 1:nConds2plot
            errorbar(xPos_adapt(i)+visit2offset,  mean(a2(:,conds2run(i))), ste(a2(:,conds2run(i))), 'd-', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end


end

ticks = [];
if plotNorm
    if     strcmp(analysis, 'AVS');           ylims = [0.90 1.10]; ylimSpacing = 0.05; yl = 'norm. AVS';              normVal = 1;
    elseif strcmp(analysis, 'VSA4');          ylims = [0.80 1.20]; ylimSpacing = 0.10; yl = 'norm. VSA';              normVal = 1;
    elseif strcmp(analysis, 'VSA3');          ylims = [0.80 1.20]; ylimSpacing = 0.10; yl = 'norm. VSA';              normVal = 1;
    elseif strcmp(analysis, 'AAVS');          ylims = [0.80 1.20]; ylimSpacing = 0.10; yl = 'norm. AAVS';             normVal = 1;
    elseif strcmp(analysis, 'duration');      ylims = [-0.3 0.2];  ylimSpacing = 0.1;  yl = 'norm. dur. (ms)';        normVal = 0; ticks = {'-300', '-200', '-100', '0', '100', '200'};
    elseif strcmp(analysis, 'f0Max');         ylims = [-12 8];     ylimSpacing = 4;    yl = 'norm. f0 max (Hz)';      normVal = 0;
    elseif strcmp(analysis, 'f0Mean');        ylims = [-50 50];    ylimSpacing = 5;    yl = 'norm. f0 mean (Hz)';     normVal = 0;
    elseif strcmp(analysis, 'f0Range');       ylims = [-15 10];    ylimSpacing = 5;    yl = 'norm. f0 range (Hz)';    normVal = 0;
    elseif strcmp(analysis, 'intensityMax');  ylims = [-9 6];      ylimSpacing = 3;    yl = 'norm. peak int. (a.u.)'; normVal = 0;
    elseif strcmp(analysis, 'intensityMean'); ylims = [-15 10];    ylimSpacing = 5;    yl = 'norm. mean int. (a.u.)'; normVal = 0; end
else
    if     strcmp(analysis, 'AVS');          ylims = [225 350];      ylimSpacing = 25;    yl = 'AVS (mels)';
    elseif strcmp(analysis, 'VSA4');         ylims = [70000 190000]; ylimSpacing = 30000; yl = 'VSA (mels^2)';
    elseif strcmp(analysis, 'VSA3');         ylims = [40000 160000]; ylimSpacing = 30000; yl = 'VSA (mels^2)';
    elseif strcmp(analysis, 'duration');     ylims = [40000 160000]; ylimSpacing = 30000; yl = 'dur. (s)';
    elseif strcmp(analysis, 'intensityMax'); ylims = [0 25];         ylimSpacing = 5;     yl = 'peak int. (a.u.)'; end
    normVal = NaN;
end

ylen = ylims(2) - ylims(1);

if strcmp(analysis, 'duration')
    yoffset = 0.025;
    text(5.25, ylims(2)-yoffset*ylen*1, 'adapt-first', 'Color', shadeColor./2, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    plot(8.75, ylims(2)-yoffset*ylen*4, 'Marker', 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'LineWidth', lineWidth);
    plot(9.25, ylims(2)-yoffset*ylen*4, 'Marker', 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', controlLightColor, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth);
    
    text(5.25, ylims(1)+yoffset*ylen*27, 'control-first', 'Color', 'k', 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    plot(9.25, ylims(1)+yoffset*ylen*30, 'Marker', 'd', 'MarkerSize', markerSize, 'MarkerEdgeColor', controlDarkColor, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth);
    plot(9.75, ylims(1)+yoffset*ylen*30, 'Marker', 'd', 'MarkerSize', markerSize, 'MarkerEdgeColor', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'LineWidth', lineWidth);

elseif strcmp(analysis, 'intensityMax') || strcmp(analysis, 'f0Max') || strcmp(analysis, 'f0Range')
    yoffset = 0.025;
    text(5.25, ylims(2)-yoffset*ylen*26, 'adapt-first', 'Color', shadeColor./2, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    plot(8.75, ylims(2)-yoffset*ylen*29, 'Marker', 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'LineWidth', lineWidth);
    plot(9.25, ylims(2)-yoffset*ylen*29, 'Marker', 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', controlLightColor, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth);
    
    text(5.25, ylims(1)+yoffset*ylen*2, 'control-first', 'Color', 'k', 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    plot(9.25, ylims(1)+yoffset*ylen*5, 'Marker', 'd', 'MarkerSize', markerSize, 'MarkerEdgeColor', controlDarkColor, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth);
    plot(9.75, ylims(1)+yoffset*ylen*5, 'Marker', 'd', 'MarkerSize', markerSize, 'MarkerEdgeColor', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'LineWidth', lineWidth);

else
    yoffset = 0.075;
    text(5.25, ylims(2)-yoffset*ylen, 'adapt-first', 'Color', shadeColor./2, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    plot(8.75, ylims(2)-yoffset*ylen-yoffset*ylen, 'Marker', 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', adaptLightColor, 'MarkerFaceColor', adaptLightColor, 'LineWidth', lineWidth);
    plot(9.25, ylims(2)-yoffset*ylen-yoffset*ylen, 'Marker', 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', controlLightColor, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth);
    
    text(5.25, ylims(1)+yoffset*ylen, 'control-first', 'Color', 'k', 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    plot(9.25, ylims(1)+yoffset*ylen+yoffset*ylen, 'Marker', 'd', 'MarkerSize', markerSize, 'MarkerEdgeColor', controlDarkColor, 'MarkerFaceColor', 'w', 'LineWidth', lineWidth);
    plot(9.75, ylims(1)+yoffset*ylen+yoffset*ylen, 'Marker', 'd', 'MarkerSize', markerSize, 'MarkerEdgeColor', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'LineWidth', lineWidth);
end

switch exptName
    case 'vsaSentence'
        axlimMax = 30.5;
        xTicks = [1 2 3 4 5 8 11 12 13 14 17 18 19 20 21 24 27 28 29 30];
        xTickLabels = {'familiarization', 'familiarization', 'baseline', 'baseline', 'ramp', 'hold', 'adaptation', 'transfer', 'washout', 'retention'};
        xTickLabels = [xTickLabels(:)' xTickLabels(:)']; % double it
        fill_1 = [2 4 12 18 20 28];
        fill_2 = [];
    case {'vsaPD' 'vsaPD_poster'}
        axlimMax = 38.5;
        xTicks = [1 5 6 7 8 9 10 11 14 15 16 17 18];
        xTicks = [xTicks xTicks+18];
        xTickLabels = {'familPass', 'familTrans', 'baselineSent', 'baselinePass', 'baselineTrans', 'ramp', 'holdPass', 'hold', 'adaptSent', 'adaptPass', 'transfer', 'washout', 'retention'};
        xTickLabels = [xTickLabels(:)' xTickLabels(:)']; % double it
        fill_1 = get_vsaPD_info('transfer phases indices');
        fill_2 = [6 9 11 12 13 14]; % VoA and Harvard sentences ("other" sentences)
    case 'vsaSponSpeechPilot'
        axlimMax = 24.5;
        xTicks = [1 5 6 7 8 9 10 11];
        xTicks = [xTicks xTicks+11];
        xTickLabels = {'familPass', 'familTrans', 'baselinePass', 'baselineTrans', 'adaptPass', 'transfer', 'washout', 'retention'};
        xTickLabels = [xTickLabels(:)' xTickLabels(:)']; % double it
        fill_1 = get_vsaSponSpeechPilot_info('transfer phases indices');
        fill_2 = [];
    case 'vsaCP'
        axlimMax = 32.5;
        xTicks = [1 5 6 7 8 9 10 13 14 15 16];
        xTicks = [xTicks xTicks+16];
        xTickLabels = {'familPass', 'familTrans', 'baselinePass', 'baselineTrans', 'ramp', 'holdPass', 'hold', 'adaptPass', 'transfer', 'washout', 'retention'};
        xTickLabels = [xTickLabels(:)' xTickLabels(:)']; % double it
        fill_1 = get_vsaCP_info('transfer phases indices');
        fill_2 = [];
end

axlim = [0.5 axlimMax ylims(1) ylims(2)];
axis(axlim);
set(gca, 'FontSize', fontSize);
set(gca, 'XTick', xTicks);
set(gca, 'XTickLabel', xTickLabels);
set(gca, 'YTick', ylims(1):ylimSpacing:ylims(2));
if ~isempty(ticks); set(gca, 'YTickLabel', ticks); end
xtickangle(30);
h_lines = hline(normVal, 'k', '--');
for hl = 1:length(h_lines); h_lines(hl).HandleVisibility = 'off'; end
for i = 1:length(fill_1)
    h_fill_1(i) = fill([fill_1(i)-0.5 fill_1(i)+0.5 fill_1(i)+0.5 fill_1(i)-0.5], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor, 'EdgeColor', 'none'); %#ok<AGROW> 
end
for i = 1:length(fill_2)
    h_fill_2(i) = fill([fill_2(i)-0.5 fill_2(i)+0.5 fill_2(i)+0.5 fill_2(i)-0.5], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor2, 'EdgeColor', 'none'); %#ok<AGROW> 
end

set(gca, 'Layer', 'top');
uistack(h_fill_1(:),'bottom');
if exist('h_fill_2', 'var')
    uistack(h_fill_2(:),'bottom');
end
ylabel(yl);

end
