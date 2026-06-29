function [h] = plot_vsaSentencePaperFigs(figs2plot)
% PLOT_VSASENTENCEPAPERFIGS  Plot figures for the vsaSentence paper.

% 1 = Fig 1: Experiment and metrics
% 2 = Fig 2: AVS (and supplementary figures for VSA and AAVS)
% 3 = Fig 3: Vowel-specific
% 4 = Fig 4: Duration (and supplementary figures for intensityMax, f0Max, and f0Range)
% 5 = Fig 5: Intelligibility

if nargin < 1 || isempty(figs2plot), figs2plot = 1; end

adaptColor        = [237 28 26] ./ 255;
controlColor      = [4 75 214] ./ 255;
controlLightColor = brighten(controlColor, 0.7);
adaptDarkColor    = brighten(adaptColor, -0.7);
shadeColor        = [0.9 0.9 0.9];
baselineColor     = [0.2 0 0.4];

vowels_sentence = {'IY','IH','EY','EH','AE','AA','AH','UH','OW','UW','ER','AO','AW','AY'}; % n = 14
vowels_transfer = {'IY','IH','EY','EH','AE','AA','AH','UH','OW','UW'}; % n = 10

ColorSet = varycolor(length(vowels_sentence)+1);
for v=1:length(vowels_sentence)
    vowel = vowels_sentence{v};
    vowColors.(vowel) = ColorSet(v,:);
end

fullPageWidth = 17.4+3.0;
lineWidth = 1.5;
markerSize = 8;

plotParams.Marker = '.';
plotParams.MarkerSize = 8;
plotParams.MarkerAlpha = .25;
plotParams.LineWidth = .6;
plotParams.LineColor = [.7 .7 .7 .5];
plotParams.avgMarker = 'o';
plotParams.avgMarkerSize = 4;
plotParams.avgLineWidth = 1.25;
plotParams.jitterFrac = .25;
plotParams.FontSize = 13;

dataPaths = get_dataPaths_vsaSentence;

exptPath = get_exptLoadPath('vsaSentence');
sentenceVowFile = fullfile(exptPath, 'sentenceVow_41.mat');
transferVowFile = fullfile(exptPath, 'transferVow_41.mat');


%% Fig 1: Experiment and metrics

[bPlot,ifig] = ismember(1,figs2plot);
if bPlot

    h(ifig) = figure('Units', 'centimeters', 'Position', [1 1 fullPageWidth fullPageWidth/2]); set(gcf, 'Color', 'w');
    tiledlayout(6, 9, 'TileSpacing', 'compact', 'Padding', 'compact');

    fontSize = 9;
    stimSize = 10;
    labelSize = 11;
    common_lims = [250 1050 1000 1800];
    common_spacing = 400;

    sp       = 'sp336'; % one representative subject's vowel space
    sp_phase = 'baseline2';
    sp_cond  = 'null';
    load(sentenceVowFile, 'sentenceVow');
    sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    sV = sV(strcmp(sV.speaker, sp),:);
    sV = sV(strcmp(sV.phase, sp_phase),:);
    sV = sV(strcmp(sV.cond, sp_cond),:);
    for v = 1:length(vowels_sentence)
        vow = vowels_sentence{v};
        F1.(lower(vow)) = sV(strcmp(sV.vow, vow),:).mean_f1; % for AVS
        F2.(lower(vow)) = sV(strcmp(sV.vow, vow),:).mean_f2; % for VSA
        fmtMeans.(lower(vow)) = [F1.(lower(vow)) F2.(lower(vow))]; % for perturbation field
    end
    dataPath = dataPaths(contains(dataPaths, sp));
    dataPath = char(dataPath);
    dataPath = fullfile(dataPath, sp_cond);
    load(fullfile(dataPath, 'expt.mat'), 'expt');
    load(fullfile(dataPath, 'dataVals_sentences.mat'), 'dataVals');       
    ind = expt.inds.conds.(sp_phase);
    fmtMatrix = gen_concatenated_formants(dataVals, ind);
    fmtMatrix = rmoutliers(fmtMatrix); 
    fmtMatrix = hz2mels(fmtMatrix); % for AAVS

    % A: Perturbation field
    hax = nexttile(1, [3 3]); hold on;

    plot([F1.iy F1.ae F1.aa F1.uw F1.iy], [F2.iy F2.ae F2.aa F2.uw F2.iy], '-', 'MarkerSize', stimSize, 'Color', 'k');

    F1Min = 200; % from calc_pertField
    F1Max = 1500;
    F2Min = 500;
    F2Max = 3500;
    F1Min = hz2mels(F1Min);
    F1Max = hz2mels(F1Max);
    F2Min = hz2mels(F2Min);
    F2Max = hz2mels(F2Max);
    % initialize perturbation field values with zeros
    fieldDim = 257;
    pertAmp = zeros(fieldDim, fieldDim);
    pertPhi = zeros(fieldDim, fieldDim);
    % F1 and F2 values of perturbation field
    pertF1 = floor(F1Min:(F1Max-F1Min)/(fieldDim-1):F1Max);
    pertF2 = floor(F2Min:(F2Max-F2Min)/(fieldDim-1):F2Max);
    [xPertField, yPertField] = meshgrid(pertF1, pertF2);
    % create pert field
    % find pert field location of vowel space center and corner vowels
    vowels = fieldnames(fmtMeans);
    for v = 1:length(vowels)
        vow = vowels{v};
        [~,inds.(vow)(1)] = min(abs(pertF1 - fmtMeans.(vow)(1)));
        [~,inds.(vow)(2)] = min(abs(pertF2 - fmtMeans.(vow)(2)));
    end
    xVS = [inds.iy(1) inds.ae(1) inds.aa(1) inds.uw(1)];
    yVS = [inds.iy(2) inds.ae(2) inds.aa(2) inds.uw(2)];
    % find center of vowel area
    [fCen(1),fCen(2)] = centroid(polyshape({pertF1(xVS)}, {pertF2(yVS)}));
    [~,iFCen(1)] = min(abs(pertF1 - fCen(1)));
    [~,iFCen(2)] = min(abs(pertF2 - fCen(2)));
    pertScaleFact = 1;
    for iF1 = 1:fieldDim
        for iF2 = 1:fieldDim
            dF1 = pertF1(iFCen(1))-pertF1(iF1);
            dF2 = pertF2(iFCen(2))-pertF2(iF2);
            pertAmp(iF2,iF1) = sqrt(dF2.^2+dF1.^2).*pertScaleFact;
            pertPhi(iF2,iF1) = atan(dF2/abs(dF1));
            if dF1<0
                pertPhi(iF2,iF1) = pi - pertPhi(iF2,iF1);
            end
        end
    end
    pertPhi(isnan(pertPhi)) = 0;
    plotInd = 1:10:257;
    pertAmp2Plot = pertAmp;
    pertAmp2Plot(pertAmp > 400) = 0; % for display only
    [u,v] = pol2cart(pertPhi, pertAmp2Plot);
    quiver(xPertField(plotInd, plotInd), yPertField(plotInd, plotInd), u(plotInd, plotInd), v(plotInd, plotInd), 'Color', 'r');
    plot(pertF1(iFCen(1)), pertF2(iFCen(2)), '+k');

    axis(common_lims);
    pbaspect([1 1 1]); pbaspect manual;
    set(gca,'XTick', common_lims(1):common_spacing:common_lims(2));
    set(gca,'YTick', common_lims(3):common_spacing:common_lims(4));
    xlabel('F1 (mels)');
    ylabel('F2 (mels)');
    text(445, 1735, arpabet2ipa_vsaSentence('iy'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(820, 1485, arpabet2ipa_vsaSentence('ae'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(880, 1190, arpabet2ipa_vsaSentence('aa'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(480, 1290, arpabet2ipa_vsaSentence('uw'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    title('perturbation field');
    set(gca, 'FontSize', fontSize);

    % Empty space
    nexttile(4, [1 6]); hold on;
    plot([0 4.5 5.5 11.5 11.5 12.5 14.5], [0 0 50 50 NaN 0 0], 'Color', 'w', 'LineWidth', 2);
    text(0, 0, 'He wrote down a long list of items ... The lake sparkled in the red hot sun ...', 'FontAngle', 'italic', 'FontSize', stimSize);
    text(0.75, -1500, 'bid ... bead ... bod ... bad ... bode ... bed ... bayed ... booed ... bud ... hood ... ', ...
        'FontAngle', 'italic', 'FontSize', stimSize, 'BackgroundColor', shadeColor, 'Margin', 1);
    axis off;
    set(gca, 'FontSize', fontSize);

    % B: Trial timeline
    nexttile(13, [2 6]); hold on;

    plot([0 4.5 5.5 11.5 11.5 11.5 14.5], [0 0 50 50 NaN 0 0], 'Color', adaptColor, 'LineWidth', 2);
    controlLine = hline(0, controlColor);
    controlLine.LineWidth = 2;
    uistack(controlLine, 'bottom');
    text(8, 39, 'adapt', 'Color', adaptColor, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center')
    text(8, 12, 'control', 'Color', controlColor, 'FontSize', labelSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center')
    ylims = [-15 65];
    axlim = [0.5 14.5 ylims(1) ylims(2)]; 
    axis(axlim);
    set(gca, 'XTick', [1 2 3 4 5 8 11 12 13 14]);
    set(gca, 'XTickLabel', {'familiarization', 'familiarization', 'baseline', 'baseline', 'ramp', 'hold', 'adaptation', 'transfer', 'washout', 'retention'});
    xtickangle(30);
    set(gca, 'YTick', [0 50]);
    set(gca, 'YTickLabel', {'0' '50%'});
    h_lines = hline(0,'k','--');
    for hl = 1:length(h_lines); h_lines(hl).HandleVisibility = 'off'; end
    h_fill = fill([1.5 2.5 2.5 1.5], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor, 'EdgeColor', 'none');
    h_fill(end+1) = fill([3.5 4.5 4.5 3.5], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor, 'EdgeColor', 'none');
    h_fill(end+1) = fill([11.5 12.5 12.5 11.5], [ylims(1) ylims(1) ylims(2) ylims(2)], shadeColor, 'EdgeColor' ,'none');
    set(gca, 'Layer', 'top');
    uistack(h_fill(:),'bottom');
    ylabel('perturbation');
    set(gca, 'FontSize', fontSize);

    % C: AVS
    nexttile(28, [3 3]); hold on;

    for i = 1:length(vowels_sentence)
        others = setdiff(1:length(vowels_sentence), i);
        for j = 1:length(others)
            plot([F1.(lower(vowels_sentence{i})) F1.(lower(vowels_sentence{j}))], [F2.(lower(vowels_sentence{i})) F2.(lower(vowels_sentence{j}))], 'Color', shadeColor./1.5);
        end
    end

    axis(common_lims);
    pbaspect([1 1 1]); pbaspect manual;
    set(gca, 'XTick', common_lims(1):common_spacing:common_lims(2));
    set(gca, 'YTick', common_lims(3):common_spacing:common_lims(4));
    xlabel('F1 (mels)');
    ylabel('F2 (mels)');
    text(445, 1735, arpabet2ipa_vsaSentence('iy'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(820, 1485, arpabet2ipa_vsaSentence('ae'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(880, 1190, arpabet2ipa_vsaSentence('aa'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(480, 1290, arpabet2ipa_vsaSentence('uw'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(580, 1710, arpabet2ipa_vsaSentence('ey'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(640, 1069, arpabet2ipa_vsaSentence('ow'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(790, 1075, arpabet2ipa_vsaSentence('ao'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(850, 1430, arpabet2ipa_vsaSentence('ay'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(570, 1495, arpabet2ipa_vsaSentence('ih'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(790, 1383, arpabet2ipa_vsaSentence('eh'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(825, 1230, arpabet2ipa_vsaSentence('aw'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(650, 1350, arpabet2ipa_vsaSentence('ah'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(640, 1250, arpabet2ipa_vsaSentence('uh'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(615, 1295, arpabet2ipa_vsaSentence('er'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    title('average vowel spacing (AVS)');
    set(gca, 'FontSize', fontSize);

    % D: VSA
    hax = nexttile(31, [3 3]); hold on;
    
    fill([F1.iy F1.ae F1.aa F1.uw], [F2.iy F2.ae F2.aa F2.uw], shadeColor./1.5, 'EdgeColor', 'none');

    axis(common_lims);
    pbaspect([1 1 1]); pbaspect manual;
    set(gca, 'XTick', common_lims(1):common_spacing:common_lims(2));
    set(gca, 'YTick', common_lims(3):common_spacing:common_lims(4));
    xlabel('F1 (mels)');
    ylabel('F2 (mels)');
    %axis normal;
    text(445, 1735, arpabet2ipa_vsaSentence('iy'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(820, 1485, arpabet2ipa_vsaSentence('ae'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(880, 1190, arpabet2ipa_vsaSentence('aa'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(480, 1290, arpabet2ipa_vsaSentence('uw'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    title('vowel space area (VSA)');
    set(gca, 'FontSize', fontSize);
    
    % E: AAVS
    hax = nexttile(34, [3 3]); hold on;

    axis(common_lims);
    pbaspect([1 1 1]); pbaspect manual;
    set(gca, 'XTick', common_lims(1):common_spacing:common_lims(2));
    set(gca, 'YTick', common_lims(3):common_spacing:common_lims(4));

    [N,C] = hist3(hax, fmtMatrix, 'ctrs', {218:32:1082 968:32:1832}); % N per bin; C = bin centers
    wx = C{1}(:);
    wy = C{2}(:);
    H = pcolor(wx, wy, N');
    shading interp; 
    set(H,'edgecolor','none'); 
    colormap(flipud(gray(256)));
    xlabel('F1 (mels)'); 
    ylabel('F2 (mels)'); 
    text(445, 1735, arpabet2ipa_vsaSentence('iy'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(820, 1485, arpabet2ipa_vsaSentence('ae'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(880, 1190, arpabet2ipa_vsaSentence('aa'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    text(480, 1290, arpabet2ipa_vsaSentence('uw'), 'HorizontalAlignment', 'center', 'FontSize', stimSize, 'FontWeight', 'bold', 'Color', 'k');
    title('articulatory-acoustic vowel space (AAVS)');
    set(gca, 'FontSize', fontSize);
  
    mu = mean(fmtMatrix);
    S = cov(fmtMatrix);
    [V,D] = eig(S); % principal components
    base = [mu;mu]; % base points for arrows

    [eigen_vector, eigen_values] = eig(S);
    d = sqrt(diag(eigen_values));
    quiver(base(1,1), base(1,2), eigen_vector(1,2), eigen_vector(2,2), d(2), 'Color', brighten(mean([adaptColor; controlColor]), 0.5), 'LineWidth', lineWidth*2);
    quiver(base(1,1), base(1,2), eigen_vector(1,1), eigen_vector(2,1), d(1), 'Color', brighten(mean([adaptColor; controlColor]), 0.5), 'LineWidth', lineWidth*2);
    set(gca(), 'Layer', 'top');

    % point to sentence and transfer in experimental design
    annotation('arrow', [0.405 0.405], [0.90 0.75], 'HeadLength', 5, 'HeadWidth', 5);
    annotation('arrow', [0.445 0.445], [0.82 0.75], 'HeadLength', 5, 'HeadWidth', 5);

end


%% Fig 2: AVS (and supplementary figures for VSA and AAVS)

[bPlot,~] = ismember(2,figs2plot);
if bPlot

    load(fullfile(exptPath, 'avs_vsa_41.mat'), 'AVS_VSA');
    load(fullfile(exptPath, 'aavs_41.mat'), 'AAVS');
    plotNorm = 1;
    bPaired = 1;

    data2plot  = gen_data2plot(AVS_VSA, 'avsNormWithinSession');
    data2plot2 = gen_data2plot(AVS_VSA, 'avsNormFirstSession');
    plot_sessions_layout([], plotNorm, 'AVS', bPaired, data2plot, data2plot2);

    data2plot  = gen_data2plot(AVS_VSA, 'vsa4NormWithinSession');
    data2plot2 = gen_data2plot(AVS_VSA, 'vsa4NormFirstSession');
    plot_sessions_layout([], plotNorm, 'VSA4', bPaired, data2plot, data2plot2);

    data2plot  = gen_data2plot(AAVS, 'aavsNormWithinSession');
    data2plot2 = gen_data2plot(AAVS, 'aavsNormFirstSession');
    plot_sessions_layout([], plotNorm, 'AAVS', bPaired, data2plot, data2plot2);

    allFigs = findobj(0, 'type', 'figure'); 
    delete(setdiff(allFigs, [1 6 11]));

end


%% Fig 3: Vowel-specific

[bPlot,~] = ismember(3,figs2plot);
if bPlot

    vowels_sentence_acoustic   = {'IY','IH','EY','EH','AE','AA','AH','UH','OW','UW','ER','AO','AW','AY'};
    vowels_transfer_acoustic   = {'IY','IH','EY','EH','AE','AA','AH','UH','OW','UW'};
    %vowels_transfer_perceptual = {'IY','IH','EY','EH','AE','AA','AH','OW','UW'};
    ColorSet = varycolor(length(vowels_sentence_acoustic)+1);
    for v=1:length(vowels_sentence_acoustic)
        vowel = vowels_sentence_acoustic{v};
        vowColors.(vowel) = ColorSet(v,:);
    end
    plotParams.vowColors = vowColors;
    plotParams.hlineColor = [.25 .25 .25];
    plotParams.bMeansOnly = 1;
    plotParams.baselineColor = baselineColor;
    fontsize = 9;
    labelsize = 11;
    
    h = figure('Units', 'centimeters', 'Position', [1 1 fullPageWidth fullPageWidth/2]); set(gcf, 'Color', 'w');
    tiledlayout(4, 6, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    sp      = 'sp336';
    sp_cond = 'adapt';
    load(fullfile(exptPath, 'acousticdata', sp, sp_cond, 'expt.mat'), 'expt');
    fCen = expt.audapterParams.fCen;

    nexttile(1, [2 2]); hold on;
    load(sentenceVowFile, 'sentenceVow');
    sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    sData = sV(strcmp(sV.speaker, sp),:);
    cData = sData(strcmp(sData.cond, sp_cond),:);    
    for v = 1:length(vowels_sentence)
        vow = vowels_sentence{v};
        vData = cData(strcmp(cData.vow, vow),:); 

        sp_phase = 'baseline2'; 
        pData = vData(strcmp(vData.phase, sp_phase),:);
        f1.(vow) = pData(strcmp(pData.vow, vow),:).mean_f1;
        f2.(vow) = pData(strcmp(pData.vow, vow),:).mean_f2;
        plot([f1.(vow) fCen(1)], [f2.(vow) fCen(2)], '-', 'Color', plotParams.baselineColor)
        text(f1.(vow), f2.(vow), arpabet2ipa_vsaSentence(vow), 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'normal', 'Color', plotParams.baselineColor);    
        
        sp_phase = 'hold6';
        pData = vData(strcmp(vData.phase, sp_phase),:);
        f1.(vow) = pData(strcmp(pData.vow, vow),:).mean_f1;
        f2.(vow) = pData(strcmp(pData.vow, vow),:).mean_f2;
        plot([f1.(vow) fCen(1)], [f2.(vow) fCen(2)], '-', 'Color', plotParams.vowColors.(vow))
        text(f1.(vow), f2.(vow), arpabet2ipa_vsaSentence(vow), 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold', 'Color', plotParams.vowColors.(vow));
    end
    axis([425 825 1000 1800]);
    pbaspect([1 1 1]); pbaspect manual;
    set(gca, 'FontSize', fontsize);
    set(gca, 'XTick', 425:200:825);
    set(gca, 'YTick', 1000:400:1800);
    xlabel('F1 (mels)');
    ylabel('F2 (mels)');
    title('adaptation');

    colors = {'IY','IH','EH','AA','AH','UH','OW','ER','AW','AY'}; % 10 (a subset)
    spacing = 25;
    str = 'adaptation';
    for i = 1:length(colors)    
        if i==3;      text(650+i*spacing-spacing+2, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i})); %#ok<*ALIGN> 
        elseif i==4;  text(650+i*spacing-spacing+2, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        elseif i==5;  text(650+i*spacing-spacing+7, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        elseif i==6;  text(650+i*spacing-spacing-3, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        elseif i==7;  text(650+i*spacing-spacing-3, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        elseif i==8;  text(650+i*spacing-spacing-8, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        elseif i==9;  text(650+i*spacing-spacing-21, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        elseif i==10; text(650+i*spacing-spacing-18, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i}));
        else;         text(650+i*spacing-spacing, 1750, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(colors{i})); end
    end
    text(650, 1650, 'baseline', 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', baselineColor);

    hax = nexttile(3, [2 4]);
    pData = sV(strcmp(sV.phase, 'hold6'),:); % select phases of interest
    isTransfer = 0;
    rfx = tab2struct_pairedData_1axVowel(pData, isTransfer, 'mean_centdistdiff');
    plotParams.vowels = vowels_sentence_acoustic;
    plotParams.xlim = [0 29];
    plotParams.ylim = [-20 30];
    plotParams.analysis = 'mean_centdistdiff';
    plotParams.ylab = {'\Delta dist. to center (mels)'};
    plot_pairedData_1axVowel(hax, rfx, plotParams); % note _1ax has conds on the x-axis
    set(gca, 'XTick', 1.5:2:27.5, 'XTickLabels', arpabet2ipa_vsaSentence(lower(vowels_sentence_acoustic)));
    set(gca, 'FontSize', fontsize);
    title('adaptation');
    text(1.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % IY
    text(3.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % IH
    text(5.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % EY
    text(23.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % AO
    text(9.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', shadeColor./1.5); % AE
    text(13.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', shadeColor./1.5); % AH
    text(15.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', shadeColor./1.5); % UH
    text(25.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', shadeColor./1.5); % AW 

    nexttile(13, [2 2]); hold on;
    load(transferVowFile, 'transferVow');
    tV = groupsummary(transferVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean"); % mean acoustics over trials, preserving groupings
    sData = tV(strcmp(tV.speaker, sp),:);
    cData = sData(strcmp(sData.cond, sp_cond),:);    
    for v = 1:length(vowels_transfer)
        vow = vowels_transfer{v};
        vData = cData(strcmp(cData.vow, vow),:);   

        sp_phase = 'transfer2'; 
        pData = vData(strcmp(vData.phase, sp_phase),:);
        f1.(vow) = pData(strcmp(pData.vow, vow),:).mean_f1;
        f2.(vow) = pData(strcmp(pData.vow, vow),:).mean_f2;
        plot([f1.(vow) fCen(1)], [f2.(vow) fCen(2)], '-', 'Color', plotParams.baselineColor)
        text(f1.(vow), f2.(vow), arpabet2ipa_vsaSentence(vow), 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'normal', 'Color', plotParams.baselineColor);    
        
        sp_phase = 'transfer3';
        pData = vData(strcmp(vData.phase, sp_phase),:);
        f1.(vow) = pData(strcmp(pData.vow, vow),:).mean_f1;
        f2.(vow) = pData(strcmp(pData.vow, vow),:).mean_f2;         
        plot([f1.(vow) fCen(1)], [f2.(vow) fCen(2)], '-', 'Color', plotParams.vowColors.(vow))
        text(f1.(vow), f2.(vow), arpabet2ipa_vsaSentence(vow), 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold', 'Color', plotParams.vowColors.(vow));
    end
    axis([400 1000 1050 1850]);
    pbaspect([1 1 1]); pbaspect manual;
    set(gca, 'FontSize', fontsize);
    set(gca, 'XTick', 400:300:1000);
    set(gca, 'YTick', 1050:400:1850);
    xlabel('F1 (mels)');
    ylabel('F2 (mels)');
    title('transfer');
    
    hax = nexttile(15, [2 3]);
    pData = tV(strcmp(tV.phase, 'transfer3'),:); % select phases of interest
    isTransfer = 1;
    rfx = tab2struct_pairedData_1axVowel(pData, isTransfer, 'mean_centdistdiff');
    plotParams.vowels = vowels_transfer_acoustic;
    plotParams.xlim = [0 29];
    plotParams.ylim = [-20 30];
    plotParams.analysis = 'mean_centdistdiff';
    plotParams.ylab = {'\Delta dist. to center (mels)'};
    plot_pairedData_1axVowel(hax, rfx, plotParams);
    set(gca, 'XTick', 1.5:2:19.5, 'XTickLabels', arpabet2ipa_vsaSentence(lower(vowels_transfer_acoustic)));
    set(gca, 'FontSize', fontsize);
    title('transfer');
    text(1.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % IY
    text(3.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % IH
    text(5.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % EY
    text(11.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', 'k'); % AA
    text(7.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', shadeColor./1.5); % EH
    text(13.5, 27.5, '*', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Color', shadeColor./1.5); % AH
    a_colors = {'IY','EH','AH','UW','AW'};
    c_colors = {'IH','EH','AA','UH','UW','AO','AY'};
    spacing = 0.6;
    str = 'adapt';
    for i = 1:length(a_colors)
        text(16.5+i*spacing, 28, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', vowColors.(a_colors{i}));
    end
    str = 'control';
    for i = 1:length(c_colors)
        if i==5;     text(16.5+i*spacing-0.2, 22, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', get_desatcolor(get_darkcolor(vowColors.(c_colors{i}))));
        elseif i==6; text(16.5+i*spacing-0.45, 22, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', get_desatcolor(get_darkcolor(vowColors.(c_colors{i}))));
        elseif i==7; text(16.5+i*spacing-0.45, 22, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', get_desatcolor(get_darkcolor(vowColors.(c_colors{i}))));
        else;        text(16.5+i*spacing, 22, str(i), 'FontSize', labelsize, 'FontWeight', 'bold', 'Color', get_desatcolor(get_darkcolor(vowColors.(c_colors{i})))); end
    end
    set(gca, 'XLim', [0 21]); % leaves room for panel E
    
    nexttile(18, [2 1]);
    load(sentenceVowFile, 'sentenceVow');
    sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    sen = sV(strcmp(sV.cond, 'adapt'),:); % adapt only
    sen = sen(strcmp(sen.phase, 'hold6'),:); % select phases of interest
    sen.mean_pertsize = sen.mean_centdist/2; % perturbation size is 50% of distance to center
    sen.vow = nominal(sen.vow);
    sen.subj = nominal(sen.subj);

    lme = fitlme(sen, 'mean_centdistdiff ~ mean_pertsize + (1+mean_pertsize|subj) + (1+mean_pertsize|vow)');  
    anova(lme, 'DFMethod', 'Satterthwaite');

    tblnew = table(); % new data for prediction
    tblnew.mean_pertsize = linspace(0,250,100)';
    tblnew.subj = repmat(70,100,1);
    tblnew.vow = repmat(70,100,1);
    tblnew.vow = nominal(tblnew.vow);
    tblnew.subj = nominal(tblnew.subj);
    [ypred, yCI, ~] = predict(lme, tblnew, 'Conditional', true, 'DFMethod', 'Satterthwaite');

    h1 = line(tblnew.mean_pertsize, ypred);
    h1.Color = 'k'; h1.LineWidth = 2;
    inBetween = [yCI(:,2)', fliplr(yCI(:,1)')];
    x3 = [linspace(0,250,100), fliplr(linspace(0,250,100))];
    patch(x3, inBetween, 1, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none');
    alpha(0.3);
    xlabel('perturbation (mels)'); ylabel('\Delta dist. from center (mels)'); 
    xticks([0 250]);
    r2 = round(lme.Rsquared.Ordinary, 2);
    text(30, -35, ['R^{2} = ' num2str(r2)], 'FontSize', labelsize);
    set(gca, 'FontSize', fontsize);
    title('adaptation');

end


%% Fig 4: Duration (and supplementary figures for intensityMax, f0Max, and f0Range)

[bPlot,~] = ismember(4,figs2plot);
if bPlot

    plotNorm = 1;
    bPaired = 0;

    data2plot  = gen_data2plot_suppData(exptPath, 'durations', 'normWithinSession');
    data2plot2 = gen_data2plot_suppData(exptPath, 'durations', 'normFirstSession');
    plot_sessions_layout([], plotNorm, 'duration', bPaired, data2plot, data2plot2);

    data2plot  = gen_data2plot_suppData(exptPath, 'intensityMax', 'normWithinSession');
    data2plot2 = gen_data2plot_suppData(exptPath, 'intensityMax', 'normFirstSession');
    plot_sessions_layout([], plotNorm, 'intensityMax', bPaired, data2plot, data2plot2);

    data2plot  = gen_data2plot_suppData(exptPath, 'f0Max', 'normWithinSession');
    data2plot2 = gen_data2plot_suppData(exptPath, 'f0Max', 'normFirstSession');
    plot_sessions_layout([], plotNorm, 'f0Max', bPaired, data2plot, data2plot2);

    data2plot  = gen_data2plot_suppData(exptPath, 'f0Range', 'normWithinSession');
    data2plot2 = gen_data2plot_suppData(exptPath, 'f0Range', 'normFirstSession');
    plot_sessions_layout([], plotNorm, 'f0Range', bPaired, data2plot, data2plot2);  

    % Add this panel to Figure 4:
    load(fullfile(exptPath, 'segmentDuration_sentence_41.mat'), 'sen');

    plotParams.hlineColor = [.25 .25 .25];
    plotParams.bMeansOnly = 1;
    plotParams.capsize = 5;
    fontsize = 9;
    labelsize = 11;
    vs = {'IY','IH','EH','AE','AA','AH','OW','UW','EY','UH','ER','AO','AW','AY'};
    stops = {'B','D','G','P','T','K'};

    figure('Units', 'centimeters', 'Position', [1 1 fullPageWidth fullPageWidth/2]); set(gcf, 'Color', 'w');
    outer    = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    topRight = tiledlayout(outer, 'flow', 'TileSpacing', 'loose', 'Padding', 'loose');
    topRight.Layout.Tile = 2;
    hax = nexttile(topRight); 
    conds = {'adapt','null'};
    vowels = [vs stops];
    analysis = 'durNormWithinSession';
    for v = 1:length(vowels)
        vowel = vowels{v};
        vData = sen(strcmp(sen.vow, vowel),:);
        for c = 1:length(conds)
            cond = conds{c};
            cData = vData(strcmp(vData.cond, cond),:);
            rfx.(analysis).(vowel).(cond) = 1000*cData.(analysis)';
        end
    end
    plotParams.vowels = vowels;
    for i = 1:length(vowels)
        vo = vowels{i};
        vowColors.(vo) = [0 0 0];
    end
    plotParams.vowColors = vowColors;
    plotParams.xlim = [0 41];
    plotParams.ylim = [-20 10];
    plotParams.analysis = analysis;
    plotParams.ylab = {'\Delta duration (ms)'};
    plot_pairedData_1axVowel(hax, rfx, plotParams);
    set(gca, 'XTick', 1.5:2:39.5, 'XTickLabels', arpabet2ipa_vsaSentence(vowels));
    set(gca, 'FontSize', fontsize);
    title('adaptation');
    text(35, 9, 'adapt', 'FontSize', labelsize, 'FontWeight', 'bold');
    textborder(35, 6, 'control', 'white', 'black', 'FontSize', labelsize);

end


%% Fig 5: Intelligibility

[bPlot,~] = ismember(5,figs2plot);
if bPlot

    fontsize = 9;
    labelsize = 11;

    h = figure('Units', 'centimeters', 'Position', [1 1 fullPageWidth fullPageWidth/2]); set(gcf, 'Color', 'w');
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    load(fullfile(exptPath, 'speakerData.mat'), 'speakerData');
    T = speakerData;

    bothColor = [(controlLightColor(1)+adaptDarkColor(1))/2 (controlLightColor(2)+adaptDarkColor(2))/2 (controlLightColor(3)+adaptDarkColor(3))/2];

    nexttile(1); hold on;
    xlim([180 340]); ylim([20 100]);
    % select second sessions (where we have perceptual data)
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            x_all(s) = T.avs_adapt_baseline2(s);
            y_all(s) = T.sentenceAcc_adapt_MWord_baseline2(s);
        else                                               % use null data
            x_all(s) = T.avs_null_baseline2(s);
            y_all(s) = T.sentenceAcc_null_MWord_baseline2(s);
        end
    end
    scatter(x_all, y_all, 'Marker', '.', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w'); % force line for all subjs
    [r,p] = corr(x_all', y_all', 'type', 'Pearson');
    text(276, 30.67, ['{\itr} = ' num2str(round(r,2)) ', {\itp} = ' num2str(round(p,2))], 'FontSize', labelsize, 'Color', bothColor);
    hl = lsline; set(hl, 'Color', bothColor, 'LineWidth', lineWidth);
    
    for s = 1:height(T)
        if T.adaptFirst(s) == 1                            % use null data
            x = T.avs_null_baseline2(s);
            y = T.sentenceAcc_null_MWord_baseline2(s);
            plot(x, y, 's', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end
    end
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            x = T.avs_adapt_baseline2(s);
            y = T.sentenceAcc_adapt_MWord_baseline2(s);
            plot(x, y, 'd', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end
    end

    xlabel('baseline AVS (mels)'); ylabel('sentence intelligibility (%)');
    axis square;
    xticks(180:40:340);
    set(gca, 'FontSize', fontsize);
    title('baseline intelligibility');
    
    nexttile(2); hold on;
    xlim([0.8 1.2]); ylim([-20 10]);
    % select second sessions (where we have perceptual data)
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            x_all(s) = T.avsNormWithinSession_adapt_hold6(s);
            y_all(s) = T.sentenceAcc_adapt_MWord_gain(s);
        else                                               % use null data
            x_all(s) = T.avsNormWithinSession_null_hold6(s);
            y_all(s) = T.sentenceAcc_null_MWord_gain(s);
        end
    end
    scatter(x_all, y_all, 'Marker', '.', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w'); % force line for all subjs
    [r,p] = corr(x_all', y_all', 'type', 'Pearson'); 
    text(1.04, -16, ['{\itr} = ' num2str(round(r,2)) ', {\itp} = ' num2str(round(p,2))], 'FontSize', labelsize, 'Color', bothColor);
    %hl = lsline; set(hl, 'Color', bothColor, 'LineWidth', lineWidth);

    % lsline for adapt-second only 
    clear x y r p;
    count = 1;
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            x(count) = T.avsNormWithinSession_adapt_hold6(s);
            y(count) = T.sentenceAcc_adapt_MWord_gain(s);
            count = count + 1;
        end
    end
    scatter(x, y, 'Marker', '.', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w');
    [r,p] = corr(x', y', 'type', 'Pearson'); 
    text(1.04, -18, ['{\itr} = ' num2str(round(r,2)) ', {\itp} = ' num2str(round(p,2))], 'FontSize', labelsize, 'Color', adaptDarkColor);
    hl = lsline; set(hl(1), 'Color', adaptDarkColor, 'LineWidth', lineWidth); set(hl(2), 'Color', bothColor, 'LineWidth', lineWidth);

    for s = 1:height(T)
        if T.adaptFirst(s) == 1                            % use null data
            x = T.avsNormWithinSession_null_hold6(s);
            y = T.sentenceAcc_null_MWord_gain(s);
            plot(x, y, 's', 'Color', controlLightColor, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', controlLightColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end
    end
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            x = T.avsNormWithinSession_adapt_hold6(s);
            y = T.sentenceAcc_adapt_MWord_gain(s);
            plot(x, y, 'd', 'Color', adaptDarkColor, 'MarkerFaceColor', adaptDarkColor, 'MarkerEdgeColor', adaptDarkColor, 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end
    end

    xlabel('\Delta AVS (proportion of baseline AVS)'); ylabel('\Delta sentence intelligibility (% points)');
    axis square;
    hh(1) = hline(0, 'k', '--');
    hh(2) = vline(1, 'k', '--');
    set(gca, 'Layer', 'top');
    uistack(hh(:),'bottom'); 
    set(gca, 'FontSize', fontsize);
    title('change in intelligibility');

end

end % of function

% -------------------------------------------------------------------------

function [rfx] = tab2struct_pairedData_1axVowel(T,isTransfer,analysis)
% Makes a strucure for plot_pairedData_1axVowel

if nargin < 2, isTransfer = 0; end
if nargin < 3, analysis = 'perc'; end

condition = categorical(T.cond);
if ismember('phase', T.Properties.VariableNames)
    phase = categorical(T.phase);
end
vow = categorical(T.vow);
speaker = categorical(T.speaker);
speaker_cat = categories(speaker);

conds = unique(T.cond);
vowels = unique(T.vow);

if isTransfer
    phases = {'transfer2','transfer3'};
else
    if any(contains(T.phase, 'hold6'))
        phases = {'baseline2','hold6'};
    else
        phases = {'baseline2','hold'};
    end
end

if strcmp(analysis, 'mean_centdistdiff')
    
    for v = 1:length(vowels)
        vowel = vowels{v};
        vData = T(strcmp(T.vow, vowel),:);
        for c = 1:length(conds)
            cond = conds{c};
            cData = vData(strcmp(vData.cond, cond),:);
            rfx.(analysis).(vowel).(cond) = cData.(analysis)';
        end       
    end

elseif strcmp(analysis, 'mean_gain')

    for v = 1:length(vowels)
        vowel = vowels{v};
        vData = T(strcmp(T.vow, vowel),:);
        for c = 1:length(conds)
            cond = conds{c};
            cData = vData(strcmp(vData.cond, cond),:);
            rfx.(analysis).(vowel).(cond) = cData.(analysis)';
        end       
    end

else    

    for s = 1:length(speaker_cat)
        subject = char(speaker_cat(s));
        for c = 1:length(conds)
            cond = conds{c};
            for p = 1:length(phases)
                phas = phases{p};
                for v = 1:length(vowels)
                    vowel = vowels{v};
                    anl = find(string(T.Properties.VariableNames) == analysis);
                    if strcmp(analysis, 'perc')                  
                        meanBySubject = mean(table2array(T(speaker==subject & phase==phas & vow==vowel & condition==cond, anl))); % avg perc over listeners
                        rfx.(cond).(analysis).(vowel).(phas)(s) = meanBySubject;
                    elseif strcmp(analysis, 'gain')
                        meanBySubject = mean(table2array(T(speaker==subject & vow==vowel & condition==cond, anl))); % avg gain over listeners
                        rfx.(analysis).(vowel).(cond)(s) = meanBySubject;             
                    end
                end
            end
        end
    end
end
end

% -------------------------------------------------------------------------

function [ipa] = arpabet2ipa_vsaSentence(arpabet,brackets)
%ARPABET2IPA  Convert ARPABET text string to IPA equivalent.

if nargin < 2, brackets = []; end

if iscellstr(arpabet), arpacell = arpabet; %#ok<ISCLSTR>
elseif ischar(arpabet), arpacell = {arpabet}; % if string, convert to cell array
else, error('Input must be a text string or cell array of strings.')
end

ipa = cell(1,length(arpacell));
for a = 1:length(arpacell)
    switch lower(arpacell{a})
        case 'aa'
            ipa{a} = char(593);
        case 'ae'
            ipa{a} = char(230);
        case 'ah'
            ipa{a} = char(652);
        case 'ao'
            ipa{a} = char(596);
        case 'aw'
            ipa{a} = sprintf('a%s',char(650));
        case 'ax'
            ipa{a} = char(601);
        case 'axr'
            ipa{a} = char(602);
        case 'ay'
            ipa{a} = sprintf('a%s',char(618));
        case 'ey'
            ipa{a} = sprintf('e%s',char(618));
        case 'eh'
            ipa{a} = char(603);
        case 'ih'
            ipa{a} = char(618);
        case 'iy'
            ipa{a} = 'i';
        case 'ow'
            ipa{a} = sprintf('o%s',char(650));
        case 'uw'
            ipa{a} = 'u';
        case 'er'
            ipa{a} = char(605);
        case 'uh'
            ipa{a} = char(650);
        case 'b'
            ipa{a} = 'b';
        case 'd'
            ipa{a} = 'd';
        case 'g'
            ipa{a} = 'g';
        case 'p'
            ipa{a} = 'p';
        case 't'
            ipa{a} = 't';
        case 'k'
            ipa{a} = 'k';
        otherwise
            warning('Input ''%s'' not found in ARPABET list.',arpacell{a});
            ipa{a} = '';
    end

    if brackets
        switch brackets
            case '/'
                ipa{a} = sprintf('/%s/',ipa{a});
            case {'[',']'}
                ipa{a} = sprintf('[%s]',ipa{a});
        end
    end

end

if ischar(arpabet), ipa = ipa{1}; end % if input was string, convert back
end

% -------------------------------------------------------------------------

function textborder(x, y, string, text_color, border_color, varargin)
%TEXTBORDER Display text with border.
%   TEXTBORDER(X, Y, STRING)
%   Creates text on the current figure with a one-pixel border around it.
%   The default colors are white text on a black border, which provides
%   high contrast in most situations.
%   
%   TEXTBORDER(X, Y, STRING, TEXT_COLOR, BORDER_COLOR)
%   Optional TEXT_COLOR and BORDER_COLOR specify the colors to be used.
%   
%   Optional properties for the native TEXT function (such as 'FontSize')
%   can be supplied after all the other parameters.
%   Since usually the units of the parent axes are not pixels, resizing it
%   may subtly change the border of the text out of position. Either set
%   the right size for the figure before calling TEXTBORDER, or always
%   redraw the figure after resizing it.
%   
%   Author: Jo�o F. Henriques, April 2010
	if isempty(string), return; end
	if nargin < 5, border_color = 'k'; end  %default: black border
	if nargin < 4, text_color = 'w'; end  %default: white text
	%border around the text, composed of 4 text objects
	offsets = [0 -1; -1 0; 0 1; 1 0];
	for k = 1:4
		h = text(x, y, string, 'Color',border_color, varargin{:});
		%add offset in pixels
		set(h, 'Units','pixels')
		pos = get(h, 'Position');
		set(h, 'Position', [pos(1:2) + offsets(k,:), 0])
		set(h, 'Units','data')
    end
	%the actual text inside the border
	h = text(x, y, string, 'Color',text_color, varargin{:});
	%same process as above but with 0 offset; corrects small roundoff errors
	set(h, 'Units','pixels')
	pos = get(h, 'Position');
	set(h, 'Position', [pos(1:2), 0])
	set(h, 'Units','data')
end

% -------------------------------------------------------------------------
