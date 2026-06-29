function [] = plot_pairedData_1axVowel(hax,rfx,plotParams)
% X-tick labels are different vowels.
% SDB 4-2024

axes(hax);
hold on;

vowels = plotParams.vowels;
vowColors = plotParams.vowColors;
count = 0;

for v=1:length(vowels)
    vow = vowels{v};

    dataMeansByCond.adapt = rfx.(plotParams.analysis).(vow).adapt;
    dataMeansByCond.control = rfx.(plotParams.analysis).(vow).null;

    colorSpec(1,:) = vowColors.(vow);
    colorSpec(2,:) = get_desatcolor(get_darkcolor(vowColors.(vow)));
    
    defaultParams.Marker = '.';
    defaultParams.MarkerSize = 25;
    defaultParams.MarkerAlpha = .25;
    defaultParams.avgMarker = 'o';
    defaultParams.avgMarkerSize = 12;
    defaultParams.avgMarkerColor = colorSpec;
    defaultParams.LineColor = [.7 .7 .7];
    defaultParams.LineWidth = 1;
    if size(colorSpec,1)==1
        defaultParams.avgLineColor = colorSpec;
    else
        defaultParams.avgLineColor = [0 0 0];
    end
    defaultParams.avgLineWidth = 3;
    defaultParams.jitterFrac = 0.25;
    defaultParams.bCI = 0;
    defaultParams.capsize = 10;
    defaultParams.bPaired = 1;
    defaultParams.bMeansOnly = 0;
    p = set_missingFields(plotParams,defaultParams,0);
    defaultParams.avgErrorColor = p.avgMarkerColor;
    p = set_missingFields(p,defaultParams,0);
    
    conds = fieldnames(dataMeansByCond); % plot as a pair
    nConds = length(conds);

    for c = 1:nConds
        lengths(c) = length(dataMeansByCond.(conds{c}));
        maxLength = max(lengths); % in case one cond has more data
    end
    cond_means = zeros(maxLength, length(conds)); % end new
    cond_se = zeros(length(dataMeansByCond),length(conds));
    cond_ci = zeros(length(dataMeansByCond),length(conds));
    for c=1:nConds
        cond = conds{c};
        temp = dataMeansByCond.(cond); % in case one cond has more data
        if length(temp) < maxLength
            temp = padarray(temp, [0, maxLength - length(temp)], NaN, 'post');
        end
        cond_means(:,c) = temp;
    end
    plot(count+(1:nConds),nanmean(cond_means,1),'-','Color',p.avgLineColor,'LineWidth',p.avgLineWidth);
    
    for c = 1:nConds
        cond = conds{c};
        cond_data = dataMeansByCond.(cond);
        cond_se(c) = nanstd(cond_data,0) / sqrt(length(cond_data));
        %cond_ci(c) = calcci(cond_data);
        errorbar(count+c,nanmean(cond_data), cond_se(c),'Color',p.avgErrorColor(c,:),'LineWidth',p.avgLineWidth,'CapSize',p.capsize)
        if c==1
            plot(count+c,nanmean(cond_data),p.avgMarker,'Color',p.avgMarkerColor(c,:),'MarkerFace',p.avgMarkerColor(c,:),'MarkerSize',p.avgMarkerSize)
        else
            plot(count+c,nanmean(cond_data),p.avgMarker,'Color',p.avgMarkerColor(c,:),'MarkerEdge',p.avgMarkerColor(c,:),'MarkerFace','w','MarkerSize',p.avgMarkerSize)
        end
        
    end
    %set(gca,'XTick',count+(1:nConds),'XTickLabel',conds)
    %text(count+1.5, p.ylim(2)-2, arpabet2ipa_vsaSentence2(vow,'/'), 'HorizontalAlignment', 'center', 'FontSize', 10);
    %text(count+1.5, p.ylim(2)-2, arpabet2ipa_vsaSentence2(vow), 'HorizontalAlignment', 'center', 'FontSize', 10);
    
    count = count + nConds;
    clear colorSpec;
    clear defaultParams;
end

set(gca, 'FontSize', 9);
set(gca,'XLim',plotParams.xlim)
set(gca,'YLim',plotParams.ylim)
%set(gca,'XTickLabelRotation',30)
ylabel(plotParams.ylab)
hl = hline(0,plotParams.hlineColor,'--');
uistack(hl,'bottom');

end
