function [data2plot] = gen_data2plot_suppData(dataPath, analysis, plotNorm)

if isempty(analysis); analysis = 'durations'; end        % options: 'durations', 'f0Max', 'f0Mean', 'f0Range', 'intensityMax', 'intensityMean'
if isempty(plotNorm); plotNorm = 'normFirstSession'; end % options: 'raw', 'normWithinSession', 'normFirstSession'

% experimental design
nSubj            = 41;
nBlocks          = 14;
sentenceBlocks   = [1 3 5 6 7 8 9 10 11 13 14];
transferBlocks   = [2 4 12];
sentenceBaseline = 3;
transferBaseline = 4;
for i = 1:11
    sentenceTrials{i} = 1+(40*(i-1)) : 40+(40*(i-1)); %#ok<*AGROW> % 1:40, then 41:80, etc.
end
for i = 1:3
    transferTrials{i} = 1+(50*(i-1)) : 50+(50*(i-1)); % 1:50, then 51:100, etc.
end

% preallocate
data2plot.adapt   = nan(nSubj,nBlocks);
data2plot.control = nan(nSubj,nBlocks);

% sentence
sen = load(fullfile(dataPath, 'supplementaryData_sentence_41.mat'), analysis);
for b = 1:length(sentenceBlocks)
    block = sentenceBlocks(b);
    data2plot.adapt(:,block)   = mean(sen.(analysis).adapt(:,sentenceTrials{b}),2, 'omitnan');
    data2plot.control(:,block) = mean(sen.(analysis).control(:,sentenceTrials{b}),2, 'omitnan');
end

% transfer
tra = load(fullfile(dataPath, 'supplementaryData_transfer_41.mat'), analysis);
for b = 1:length(transferBlocks)
    block = transferBlocks(b);
    data2plot.adapt(:,block)   = mean(tra.(analysis).adapt(:,transferTrials{b}),2, 'omitnan');
    data2plot.control(:,block) = mean(tra.(analysis).control(:,transferTrials{b}),2, 'omitnan');
end

% split by session order
load(fullfile(dataPath, 'speakerData.mat'), 'speakerData');

data2plot.adaptFirst    = data2plot.adapt(speakerData.adaptFirst==1,:);
data2plot.controlFirst  = data2plot.control(speakerData.adaptFirst==0,:);
data2plot.adaptSecond   = data2plot.adapt(speakerData.adaptFirst==0,:);
data2plot.controlSecond = data2plot.control(speakerData.adaptFirst==1,:);

if strcmp(plotNorm, 'normWithinSession') % normalize data w/r/t within-session baseline

    data2plot.adaptFirst(:,sentenceBlocks)    = data2plot.adaptFirst(:,sentenceBlocks) - data2plot.adaptFirst(:,sentenceBaseline);
    data2plot.adaptFirst(:,transferBlocks)    = data2plot.adaptFirst(:,transferBlocks) - data2plot.adaptFirst(:,transferBaseline);

    data2plot.controlSecond(:,sentenceBlocks) = data2plot.controlSecond(:,sentenceBlocks) - data2plot.controlSecond(:,sentenceBaseline);
    data2plot.controlSecond(:,transferBlocks) = data2plot.controlSecond(:,transferBlocks) - data2plot.controlSecond(:,transferBaseline);

    data2plot.adaptSecond(:,sentenceBlocks)   = data2plot.adaptSecond(:,sentenceBlocks) - data2plot.adaptSecond(:,sentenceBaseline);
    data2plot.adaptSecond(:,transferBlocks)   = data2plot.adaptSecond(:,transferBlocks) - data2plot.adaptSecond(:,transferBaseline);

    data2plot.controlFirst(:,sentenceBlocks)  = data2plot.controlFirst(:,sentenceBlocks) - data2plot.controlFirst(:,sentenceBaseline);
    data2plot.controlFirst(:,transferBlocks)  = data2plot.controlFirst(:,transferBlocks) - data2plot.controlFirst(:,transferBaseline);

elseif strcmp(plotNorm, 'normFirstSession') % normalize data w/r/t first-session baseline

    data2plot.adaptSecond(:,sentenceBlocks) = data2plot.adaptSecond(:,sentenceBlocks) - data2plot.controlFirst(:,sentenceBaseline); % compute first
    data2plot.adaptSecond(:,transferBlocks) = data2plot.adaptSecond(:,transferBlocks) - data2plot.controlFirst(:,transferBaseline);

    data2plot.controlSecond(:,sentenceBlocks) = data2plot.controlSecond(:,sentenceBlocks) - data2plot.adaptFirst(:,sentenceBaseline); % compute first
    data2plot.controlSecond(:,transferBlocks) = data2plot.controlSecond(:,transferBlocks) - data2plot.adaptFirst(:,transferBaseline);

    data2plot.adaptFirst(:,sentenceBlocks) = data2plot.adaptFirst(:,sentenceBlocks) - data2plot.adaptFirst(:,sentenceBaseline);
    data2plot.adaptFirst(:,transferBlocks) = data2plot.adaptFirst(:,transferBlocks) - data2plot.adaptFirst(:,transferBaseline);

    data2plot.controlFirst(:,sentenceBlocks) = data2plot.controlFirst(:,sentenceBlocks) - data2plot.controlFirst(:,sentenceBaseline);
    data2plot.controlFirst(:,transferBlocks) = data2plot.controlFirst(:,transferBlocks) - data2plot.controlFirst(:,transferBaseline);   

end

end % of function
