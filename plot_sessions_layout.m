function plot_sessions_layout(ax, plotNorm, analysis, bPaired, data2plot, data2plot2, exptName)
% SDB 5-2024

% --- SETUP ---

if nargin < 7 || isempty(exptName)
    exptName = 'vsaSentence';
end

if isempty(ax)
    fullPageWidth = 17.4+3.0; % 174 mm + margins
    figure('Units', 'centimeters', 'Position', [1 1 fullPageWidth fullPageWidth/2]); set(gcf, 'Color', 'w');
    ax = gca;
else
    axes(ax);
end

if isempty(plotNorm); plotNorm = true; end  % plot normalized rather than raw values
if isempty(analysis); analysis = 'AVS'; end % options: 'AVS', 'VSA4', 'VSA3', 'AAVS', 'duration', 'intensityMax', 'intensityMean', 'f0Max', 'f0Mean', 'f0Range'

a1 = [data2plot.adaptFirst];
c1 = [data2plot.controlFirst];
a2 = [data2plot.adaptSecond];
c2 = [data2plot.controlSecond];  
a  = [a1; a2]; 
c  = [c1; c2]; 

adaptColor           = [237 28 26] ./ 255;  % red
controlColor         = [4 75 214] ./ 255;   % blue
shadeColor           = [0.9 0.9 0.9];       % light grey
shadeColor2          = [0.68 0.68 0.68];    % dark grey

lineWidth = 1.25;
markerSize = 6;
fontSize = 9;
labelSize = 11;

switch exptName
    case 'vsaPD_poster'
        % do nothing
    otherwise % use tiled layout
        outer    = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
        topLeft  = tiledlayout(outer, 'flow', 'TileSpacing', 'tight', 'Padding', 'loose');
        topRight = tiledlayout(outer, 1, 4, 'TileSpacing', 'loose', 'Padding', 'loose');
        bottom   = tiledlayout(outer, 'flow', 'TileSpacing', 'tight', 'Padding', 'loose');
        topRight.Layout.Tile = 2;
        bottom.Layout.Tile = 3;
        bottom.Layout.TileSpan = [1 2];
        nexttile(topLeft);
end

hold on;

% --- BOTH SESSIONS COMBINED ---



switch exptName
    case 'vsaSentence'
errorbar(1, mean(c(:,1)), ste(c(:,1)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(3.2, mean(c(:,3)), ste(c(:,3)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5:11, mean(c(:,5:11)), ste(c(:,5:11)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(13, mean(c(:,13)), ste(c(:,13)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(14, mean(c(:,14)), ste(c(:,14)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2, mean(c(:,2)), ste(c(:,2)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(4.2, mean(c(:,4)), ste(c(:,4)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(12, mean(c(:,12)), ste(c(:,12)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

errorbar(1, mean(a(:,1)), ste(a(:,1)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2.8, mean(a(:,3)), ste(a(:,3)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5:11, mean(a(:,5:11)), ste(a(:,5:11)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(13, mean(a(:,13)), ste(a(:,13)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(14, mean(a(:,14)), ste(a(:,14)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2, mean(a(:,2)), ste(a(:,2)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(3.8, mean(a(:,4)), ste(a(:,4)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(12, mean(a(:,12)), ste(a(:,12)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

    case 'vsaPD'
        % TODO once we have multiple datasets, combine sections 1-4, 11-13, and 17-18 together so they're connected by a line
errorbar(1, mean(c(:,1)), ste(c(:,1)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2, mean(c(:,2)), ste(c(:,2)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(3, mean(c(:,3)), ste(c(:,3)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(4, mean(c(:,4)), ste(c(:,4)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5, mean(c(:,5)), ste(c(:,5)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(6.2, mean(c(:,6)), ste(c(:,6)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(7.2, mean(c(:,7)), ste(c(:,7)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(8.2, mean(c(:,8)), ste(c(:,8)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(9, mean(c(:,9)), ste(c(:,9)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(10, mean(c(:,10)), ste(c(:,10)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(11, mean(c(:,11)), ste(c(:,11)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(12, mean(c(:,12)), ste(c(:,12)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(13, mean(c(:,13)), ste(c(:,13)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(14, mean(c(:,14)), ste(c(:,14)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(15, mean(c(:,15)), ste(c(:,15)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(16, mean(c(:,16)), ste(c(:,16)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(17, mean(c(:,17)), ste(c(:,17)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(18, mean(c(:,18)), ste(c(:,18)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

errorbar(1, mean(a(:,1)), ste(a(:,1)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(2, mean(a(:,2)), ste(a(:,2)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(3, mean(a(:,3)), ste(a(:,3)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(4, mean(a(:,4)), ste(a(:,4)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5, mean(a(:,5)), ste(a(:,5)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(5.8, mean(a(:,6)), ste(a(:,6)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(6.8, mean(a(:,7)), ste(a(:,7)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(7.8, mean(a(:,8)), ste(a(:,8)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(9, mean(a(:,9)), ste(a(:,9)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(10, mean(a(:,10)), ste(a(:,10)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(11, mean(a(:,11)), ste(a(:,11)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(12, mean(a(:,12)), ste(a(:,12)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(13, mean(a(:,13)), ste(a(:,13)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(14, mean(a(:,14)), ste(a(:,14)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(15, mean(a(:,15)), ste(a(:,15)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(16, mean(a(:,16)), ste(a(:,16)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(17, mean(a(:,17)), ste(a(:,17)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
errorbar(18, mean(a(:,18)), ste(a(:,18)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);

    case 'vsaPD_poster'
        current_pp_c_vals = [c(7) c(15) c(17) c(18)];
        current_pp_a_vals = [a(7) a(15) a(17) a(18)];
        pd004_c_vals = [1 0.9903 0.9772 0.9584];
        pd004_a_vals = [1 1.1017 1.1422 1.1037];
        pd003_c_vals = [1 1.0671 1.0578 1.0153];
        pd003_a_vals = [1 0.8864 1.0452 1.0467];
        kerry_c_vals = [1 1.1587 1.0722 1.0385];
        kerry_a_vals = [1 1.1729 1.0969 1.0731];
        acacia_c_vals= [1 0.9143 1.0293 1.0440];
        acacia_a_vals= [1 0.8777 0.8998 0.9691];
        
        % UPDATE PER RUN
        c_vals = pd004_c_vals;
        a_vals = pd004_a_vals;
%         plot([1.04 2 3 4], pd003_c_vals, 'o-', 'Color', controlColor,'MarkerFaceColor', 'white','MarkerEdgeColor', controlColor,'MarkerSize', markerSize, 'LineWidth', lineWidth)
%         plot([0.96 2 3 4], pd003_a_vals, 'o-', 'Color', adaptColor,  'MarkerFaceColor', 'white',  'MarkerEdgeColor', adaptColor,  'MarkerSize', markerSize, 'LineWidth', lineWidth)
        plot([1.04 2 3 4], pd004_c_vals, 'o-', 'Color', controlColor,'MarkerFaceColor', 'black','MarkerEdgeColor', controlColor,'MarkerSize', markerSize, 'LineWidth', lineWidth)
        plot([0.96 2 3 4], pd004_a_vals, 'o-', 'Color', adaptColor,  'MarkerFaceColor', 'black',  'MarkerEdgeColor', adaptColor,  'MarkerSize', markerSize, 'LineWidth', lineWidth)
% errorbar(1.2, mean(c(:,6)), ste(c(:,6)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% errorbar(2, mean(c(:,14)), ste(c(:,14)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% errorbar(3, mean(c(:,16)), ste(c(:,16)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% errorbar(4, mean(c(:,17)), ste(c(:,17)), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% 
% errorbar(0.8, mean(a(:,6)), ste(a(:,6)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% errorbar(2, mean(a(:,14)), ste(a(:,14)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% errorbar(3, mean(a(:,16)), ste(a(:,16)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
% errorbar(4, mean(a(:,17)), ste(a(:,17)), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);


    case 'vsaSponSpeechPilot'
        % phases: baselinePassage (6), adaptPassage (8), washout (10), retention (11)
        conds2plot = 1:11;
        xPos_control = [1 2 3 4 5 6.1 7.1 8 9 10 11];
        xPos_adapt =   [1 2 3 4 5 5.9 6.9 8 9 10 11];

        % plot control session data
        for i = 1:length(conds2plot)
            errorbar(xPos_control(i),mean(c(:,conds2plot(i))),  ste(c(:,conds2plot(i))), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % plot adapt session data
        for i = 1:length(conds2plot)
            errorbar(xPos_adapt(i),mean(a(:,conds2plot(i))),  ste(a(:,conds2plot(i))), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

    case 'vsaCP'
        % phases: baselinePassage (6), holdPassage (9), adaptPassage (13), washout (15), retention (16)
        conds2plot = 1:16;
        xPos_control = [1 2 3 4 5 6.2 7.2 8 9 10 11 12 13 14 15 16];
        xPos_adapt =   [1 2 3 4 5 5.8 6.8 8 9 10 11 12 13 14 15 16];

        % plot control session data
        for i = 1:length(conds2plot)
            errorbar(xPos_control(i),mean(c(:,conds2plot(i))),  ste(c(:,conds2plot(i))), 'o-', 'Color', controlColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

        % plot adapt session data
        for i = 1:length(conds2plot)
            errorbar(xPos_adapt(i),mean(a(:,conds2plot(i))),  ste(a(:,conds2plot(i))), 'o-', 'Color', adaptColor, 'MarkerFaceColor', adaptColor, 'MarkerEdgeColor', adaptColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end

end

ticks = [];
switch exptName
    case 'vsaSentence'
        if plotNorm
            if     strcmp(analysis, 'AVS');          ylims = [0.96 1.06]; spacing = 0.02;  yls = 'norm. AVS';             normVal = 1; ylims_paired = [0.8 1.3]; spacing_paired = 0.1;
            elseif strcmp(analysis, 'VSA4');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'VSA3');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.3 1.7]; spacing_paired = 0.7;
            elseif strcmp(analysis, 'AAVS');         ylims = [0.92 1.12]; spacing = 0.04;  yls = 'norm. AAVS';            normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'duration');     ylims = [-0.2 0.2];  spacing = 0.1;   yls = 'norm. dur. (ms)';       normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3; ticks = {'-200', '-100', '0', '100', '200'};
            elseif strcmp(analysis, 'intensityMax'); ylims = [-4 4];      spacing = 2;     yls = 'norm. peak int.(a.u.)'; normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Max');        ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 max (Hz)';     normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Range');      ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 range (Hz)';   normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            end
        else
            if     strcmp(analysis, 'AVS');  ylims = [225 350];      spacing = 25;    yls = 'AVS (mels)';
            elseif strcmp(analysis, 'VSA4'); ylims = [70000 190000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'VSA3'); ylims = [40000 160000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'AAVS'); ylims = [50000 70000];  spacing = 5000;  yls = 'AAVS'; end
            normVal = NaN;
        end
    case 'vsaPD_poster'
        ylims = [0.85 1.20]; spacing = 0.05;  yls = 'normalized vowel spacing'; normVal = 1; ylims_paired = [0.85 1.20]; spacing_paired = 0.1;
    case 'vsaPD'
        if plotNorm
            % TODO make these more accurate for vsaPD
            if     strcmp(analysis, 'AVS');          ylims = [0.85 1.20]; spacing = 0.05;  yls = 'normalized AVS';        normVal = 1; ylims_paired = [0.85 1.20]; spacing_paired = 0.1;
            elseif strcmp(analysis, 'VSA4');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'VSA3');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.3 1.7]; spacing_paired = 0.7;
            elseif strcmp(analysis, 'AAVS');         ylims = [0.92 1.12]; spacing = 0.04;  yls = 'norm. AAVS';            normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'duration');     ylims = [-0.2 0.2];  spacing = 0.1;   yls = 'norm. dur. (ms)';       normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3; ticks = {'-200', '-100', '0', '100', '200'};
            elseif strcmp(analysis, 'intensityMax'); ylims = [-4 4];      spacing = 2;     yls = 'norm. peak int.(a.u.)'; normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Max');        ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 max (Hz)';     normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Range');      ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 range (Hz)';   normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            end
        else
            if     strcmp(analysis, 'AVS');  ylims = [225 350];      spacing = 25;    yls = 'AVS (mels)';
            elseif strcmp(analysis, 'VSA4'); ylims = [70000 190000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'VSA3'); ylims = [40000 160000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'AAVS'); ylims = [50000 70000];  spacing = 5000;  yls = 'AAVS'; end
            normVal = NaN;
        end
    case 'vsaSponSpeechPilot'
        if plotNorm
            % TODO make these more accurate for vsaSponSpeechPilot
            if     strcmp(analysis, 'AVS');          ylims = [0.85 1.20]; spacing = 0.05;  yls = 'normalized AVS';        normVal = 1; ylims_paired = [0.85 1.20]; spacing_paired = 0.1;
            elseif strcmp(analysis, 'VSA4');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'VSA3');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.3 1.7]; spacing_paired = 0.7;
            elseif strcmp(analysis, 'AAVS');         ylims = [0.92 1.12]; spacing = 0.04;  yls = 'norm. AAVS';            normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'duration');     ylims = [-0.2 0.2];  spacing = 0.1;   yls = 'norm. dur. (ms)';       normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3; ticks = {'-200', '-100', '0', '100', '200'};
            elseif strcmp(analysis, 'intensityMax'); ylims = [-4 4];      spacing = 2;     yls = 'norm. peak int.(a.u.)'; normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Max');        ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 max (Hz)';     normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Range');      ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 range (Hz)';   normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            end
        else
            if     strcmp(analysis, 'AVS');  ylims = [225 350];      spacing = 25;    yls = 'AVS (mels)';
            elseif strcmp(analysis, 'VSA4'); ylims = [70000 190000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'VSA3'); ylims = [40000 160000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'AAVS'); ylims = [50000 70000];  spacing = 5000;  yls = 'AAVS'; end
            normVal = NaN;
        end
    case 'vsaCP'
        if plotNorm
            % TODO make these more accurate for vsaCP
            if     strcmp(analysis, 'AVS');          ylims = [0.85 1.20]; spacing = 0.05;  yls = 'normalized AVS';        normVal = 1; ylims_paired = [0.85 1.20]; spacing_paired = 0.1;
            elseif strcmp(analysis, 'VSA4');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'VSA3');         ylims = [0.90 1.15]; spacing = 0.05;  yls = 'norm. VSA';             normVal = 1; ylims_paired = [0.3 1.7]; spacing_paired = 0.7;
            elseif strcmp(analysis, 'AAVS');         ylims = [0.92 1.12]; spacing = 0.04;  yls = 'norm. AAVS';            normVal = 1; ylims_paired = [0.2 2.2]; spacing_paired = 0.4;
            elseif strcmp(analysis, 'duration');     ylims = [-0.2 0.2];  spacing = 0.1;   yls = 'norm. dur. (ms)';       normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3; ticks = {'-200', '-100', '0', '100', '200'};
            elseif strcmp(analysis, 'intensityMax'); ylims = [-4 4];      spacing = 2;     yls = 'norm. peak int.(a.u.)'; normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Max');        ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 max (Hz)';     normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            elseif strcmp(analysis, 'f0Range');      ylims = [-5 5];      spacing = 2.5;   yls = 'norm. f0 range (Hz)';   normVal = 0; ylims_paired = [0.7 1.3]; spacing_paired = 0.3;
            end
        else
            if     strcmp(analysis, 'AVS');  ylims = [225 350];      spacing = 25;    yls = 'AVS (mels)';
            elseif strcmp(analysis, 'VSA4'); ylims = [70000 190000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'VSA3'); ylims = [40000 160000]; spacing = 30000; yls = 'VSA (mels^2)';
            elseif strcmp(analysis, 'AAVS'); ylims = [50000 70000];  spacing = 5000;  yls = 'AAVS'; end
            normVal = NaN;
        end
end

ylen = ylims(2) - ylims(1);
yoffset = 0.025;

% display 'control' and 'adapt' labels
switch exptName
    case 'vsaSentence'
        if strcmp(analysis, 'duration') || strcmp(analysis, 'intensityMax') || strcmp(analysis, 'f0Max') || strcmp(analysis, 'f0Range')
            text(5.25, ylims(2)-yoffset*ylen, 'adapt', 'Color', adaptColor, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
            text(5.25, ylims(1)+yoffset*ylen*28, 'control', 'Color', controlColor, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
        else
            text(5.25, ylims(2)-yoffset*ylen, 'adapt', 'Color', adaptColor, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
            text(5.25, ylims(1)+yoffset*ylen, 'control', 'Color', controlColor, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
        end
    case {'vsaPD', 'vsaPD_poster', 'vsaSponSpeechPilot', 'vsaCP'}
        % don't display labels
end


% set axis limits, xticks, yticks for top left panel
switch exptName
    case 'vsaSentence'
        xlimMax = 14.5;
        set(gca, 'XTick', [1 2 3 4 5 8 11 12 13 14]);
        set(gca, 'XTickLabel', {'familiarization', 'familiarization', 'baseline', 'baseline', 'ramp', 'hold', 'adaptation', 'transfer', 'washout', 'retention'}, 'Fontsize', fontSize);
        axlim = [0.5 xlimMax ylims(1) ylims(2)];
    case 'vsaPD'
        xlimMax = 18.5;
        set(gca, 'XTick', [1 5 6 7 8 9 10 11 14 15 16 17 18]);
        set(gca, 'XTickLabel', {'familPass', 'familTrans', 'baselineSent', 'baselinePass', 'baselineTrans', 'ramp', 'holdPass', 'hold', 'adaptSent', 'adaptPass', 'transfer', 'washout', 'retention'}, 'Fontsize', fontSize);
        axlim = [0.5 xlimMax ylims(1) ylims(2)];
    case 'vsaPD_poster'
        xlimMax = 4.2;
        set(gca, 'XTick', [1 2 3 4]);
        set(gca, 'XTickLabel', {'baseline' 'adaptation' 'washout' 'retention'}, 'Fontsize', fontSize);
        axlim = [0.8 xlimMax ylims(1) ylims(2)];
    case 'vsaSponSpeechPilot'
        xlimMax = 11.5;
        set(gca, 'XTick', [1 5 6 7 8 9 10 11]);
        set(gca, 'XTickLabel', {'familPass' 'familTrans' 'baselinePassage' 'baselineTrans' 'adaptPassage' 'transfer' 'washout' 'retention'}, 'Fontsize', fontSize);
        axlim = [0.8 xlimMax ylims(1) ylims(2)];
    case 'vsaCP'
        % TODO update this after running it
        xlimMax = 16.5;
        set(gca, 'XTick', [1 5 6 7 8 9 10 13 14 15 16]);
        set(gca, 'XTickLabel', {'familPass' 'familTrans' 'baselinePass' 'baselineTrans' 'ramp' 'holdPass' 'hold' 'adaptPass' 'transfer' 'washout' 'retention'}, 'Fontsize', fontSize);
        axlim = [0.5 xlimMax ylims(1) ylims(2)];
end
axis(axlim);
set(gca, 'FontSize', fontSize);

set(gca, 'YTick', ylims(1):spacing:ylims(2));
if ~isempty(ticks); set(gca, 'YTickLabel', ticks); end
xtickangle(30);
h_lines = hline(normVal, 'k', '--');
for hl = 1:length(h_lines); h_lines(hl).HandleVisibility = 'off'; end


% --- add light grey fill (shading) for transfer sections in top left panel ---

switch exptName
    case 'vsaSentence'
        sectionsForPrimaryFill = [2 4 12]; % transfer
    case 'vsaPD'
        sectionsForPrimaryFill = get_vsaPD_info('transfer phases indices');
    case 'vsaPD_poster'
        sectionsForPrimaryFill = [];
    case 'vsaSponSpeechPilot'
        sectionsForPrimaryFill = get_vsaSponSpeechPilot_info('transfer phases indices');
    case 'vsaCP'
        sectionsForPrimaryFill = get_vsaCP_info('transfer phases indices');
end
for i = 1:length(sectionsForPrimaryFill)
    offset = 0.5;
    startVal = sectionsForPrimaryFill(i)-offset;
    endVal   = sectionsForPrimaryFill(i)+offset;
    h_fill(i) = fill([startVal endVal endVal startVal], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor, 'EdgeColor', 'none'); %#ok<AGROW> 
end
if length(sectionsForPrimaryFill)>1
    set(gca, 'Layer', 'top');
    uistack(h_fill(:),'bottom');
end
ylabel(yls);

% --- add dark grey fill (shading) for another section in top left panel ---
switch exptName
    case 'vsaSentence'
        sectionsForSecondaryFill = [];
    case 'vsaPD'
        sectionsForSecondaryFill = [6 9 11 12 13 14]; % VoA and Harvard sentences ("other" sentences)
    case 'vsaPD_poster'
        sectionsForSecondaryFill = [];
    case 'vsaSponSpeechPilot'
        sectionsForSecondaryFill = [];
    case 'vsaCP'
        sectionsForSecondaryFill = [8 10 11 12]; % IEEE sentences
end
for i = 1:length(sectionsForSecondaryFill)
    offset = 0.5;
    startVal = sectionsForSecondaryFill(i)-offset;
    endVal   = sectionsForSecondaryFill(i)+offset;
    h_fill_2(i) = fill([startVal endVal endVal startVal], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor2, 'EdgeColor', 'none'); %#ok<AGROW> 
end
if length(sectionsForSecondaryFill)>1 % only set these values if using this secondary fill set
    set(gca, 'Layer', 'top');
    uistack(h_fill_2(:),'bottom');
end

if strcmp(exptName, 'vsaPD_poster')
    makeFig4Printing;
    error('all done.');
end

% --- PAIRED DATA ---

if bPaired

    colorSpec = [adaptColor; controlColor];

    plotParams.Marker = '.';
    plotParams.MarkerSize = 25;
    plotParams.MarkerAlpha = .25;
    plotParams.avgMarker = 'o';
    plotParams.avgMarkerSize = 6;
    plotParams.avgMarkerColor = colorSpec;
    plotParams.LineColor = [0.6 0.6 0.6];
    plotParams.LineWidth = 0.5;
    if size(colorSpec,1)==1
        plotParams.avgLineColor = colorSpec;
    else
        plotParams.avgLineColor = [0 0 0];
    end
    plotParams.avgLineWidth = 2;
    plotParams.jitterFrac = 0.4;
    plotParams.bCI = 0;
    plotParams.capsize = 0;
    plotParams.bPaired = 1;
    plotParams.bMeansOnly = 0;
    
    switch exptName
        case 'vsaSentence'
            phases2plot = {'adaptation', 'washout', 'retention'};
            blocks2plot = [11 13 14];
            tileNums = [1 3 4];
        case {'vsaPD', 'vsaPD_poster'}
            % TODO make room for adaptSentence section (#14)
            phases2plot = {'adaptPassage', 'washout', 'retention'};
            blocks2plot = [15 17 18];
            tileNums = [1 3 4];
        case 'vsaSponSpeechPilot'
            phases2plot = {'adaptPassage', 'washout', 'retention'};
            blocks2plot = [8 10 11];
            tileNums = [1 3 4];
        case 'vsaCP'
            phases2plot = {'adaptPassage', 'washout', 'retention'};
            blocks2plot = [13 15 16];
            tileNums = [1 3 4];
    end
    for p = 1:length(phases2plot)
        
        phase = phases2plot{p};
        block = blocks2plot(p);
        pairedData.adapt   = a(:,block);
        pairedData.control = c(:,block);
        plot_pairedData(pairedData, colorSpec, plotParams);
        hold on;
        plot(2, nanmean(pairedData.control), 'w.', 'MarkerSize', plotParams.MarkerSize/2.5);
    
        set(gca, 'FontSize', fontSize);
        set(gca, 'Ylim', ylims_paired);
        set(gca, 'YTick', ylims_paired(1):spacing_paired:ylims_paired(2));
        if p > 1; set(gca, 'YTickLabel' ,''); end
        if p == 1; ylabel(yls); end
        hl = hline(normVal, 'k', '--');
        uistack(hl, 'bottom');
        xtickangle(30);
        title(phase, 'FontSize', fontSize);
        h = gca; h.Parent = topRight; h.Layout.Tile = tileNums(p);
    end

    switch exptName
        case 'vsaSentence'
            phases2plot = {'transfer'};
            blocks2plot = 12;
        case {'vsaPD', 'vsaPD_poster'}
            phases2plot = {'transfer'};
            blocks2plot = 16;
        case 'vsaSponSpeechPilot'
            phases2plot = {'transfer'};
            blocks2plot = 9;
        case 'vsaCP'
            phases2plot = {'transfer'};
            blocks2plot = 14;
    end
    for p = 1:length(phases2plot)
        
        phase = phases2plot{p};
        block = blocks2plot(p);
        pairedData.adapt   = a(:,block);
        pairedData.control = c(:,block);
        plot_pairedData(pairedData, [adaptColor; controlColor], plotParams);
        hold on;
        plot(2, nanmean(pairedData.control), 'w.', 'MarkerSize', plotParams.MarkerSize/2.5);
    
        set(gca, 'FontSize', fontSize);
        set(gca, 'Ylim', ylims_paired);
        set(gca, 'YTick', ylims_paired(1):spacing_paired:ylims_paired(2));
        set(gca, 'YTickLabel' ,'');
        hl = hline(normVal, 'k', '--');
        uistack(hl, 'bottom');
        xtickangle(30);
        title(phase, 'FontSize', fontSize);
        xls = xlim;
        yls = ylim;
        h_fill = fill([xls(1) xls(2) xls(2) xls(1)], [yls(1) yls(1) yls(2) yls(2)], shadeColor, 'EdgeColor', 'none');
        set(gca, 'Layer', 'top');
        uistack(h_fill, 'bottom');
        h = gca; h.Parent = topRight; h.Layout.Tile = 2;
    end

end

% --- BOTH SESSIONS BACK TO BACK ---

nexttile(bottom); 
[~] = plot_sessionsBack2Back([], plotNorm, analysis, data2plot2, exptName); 

end
