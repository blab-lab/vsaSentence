function [data2plot] = gen_data2plot(T, analysis, exptName)
% Takes formant data (e.g., aavs_41 or avs_vsa_41) in long table form.
% Returns subj x phase split by session and session order.
% Sara Beach 3-2024

if nargin < 3 || isempty(exptName)
    exptName = 'vsaSentence';
end

if ~any(strcmp('adaptFirst', T.Properties.VariableNames))
    error('Input table must contain the adaptFirst variable.')
else
    nSubj_adaptFirst  = (sum(T.adaptFirst) / length(unique(T.cond))) / length(unique(T.phase));
    nSubj_adaptSecond = length(unique(T.subj)) - nSubj_adaptFirst;
end

if ~ismember(analysis, T.Properties.VariableNames)
    error('Input table does not contain the analysis variable.')
end

% experimental design
switch exptName
    case 'vsaSentence'
        sentenceBlocks   = [1 3 5 6 7 8 9 10 11 13 14];
        transferBlocks   = [2 4 12];
        nBlocks          = length(sentenceBlocks) + length(transferBlocks);
        sentenceBaseline = 3;
        sentenceAdapted  = 11;
        transferBaseline = 4;
        transferAdapted  = 12;
        sentencePhases   = {'baseline1', 'baseline2', 'ramp', 'hold1', 'hold2', 'hold3', 'hold4', 'hold5', 'hold6', 'washout', 'retention'};
        transferPhases   = {'transfer1', 'transfer2', 'transfer3'};
    case 'vsaPD'
        sentenceBlocks   = get_vsaPD_info('sentence phases indices'); % doesn't include Voice of America sentence blocks (9, 11, 12, 13)
        transferBlocks   = get_vsaPD_info('transfer phases indices');
        nBlocks          = 18; % the total number of blocks in the experiment, even if we're not analyzing all of them
        sentenceBaseline = 7;   %expt.conds = 'baselinePassage'
        sentenceAdapted  = 15;  %expt.conds = 'adaptPassage'
        transferBaseline = 8;   %expt.conds = 'baselineTransfer'
        transferAdapted  = 16;  %expt.conds = 'transfer'
        sentencePhases   = get_vsaPD_info('sentence phases names'); % condition name, from expt.conds
        transferPhases   = get_vsaPD_info('transfer phases names');
    case 'vsaSponSpeechPilot'
        sentenceBlocks   = get_vsaSponSpeechPilot_info('sentence phases indices');
        transferBlocks   = get_vsaSponSpeechPilot_info('transfer phases indices');
%         nBlocks          = length(sentenceBlocks) + length(transferBlocks);
        nBlocks          = 11; % the total number of blocks in the experiment, even if we're not analyzing all of them
        sentenceBaseline = 6;   %expt.conds = 'baselinePassage'
%         sentenceAdapted  = [];  % doesn't exist for spon speech
        transferBaseline = 7;   %expt.conds = 'baselineTransfer'
        transferAdapted  = 9;  %expt.conds = 'transfer'
        sentencePhases   = get_vsaSponSpeechPilot_info('sentence phases names'); % condition name, from expt.conds
        transferPhases   = get_vsaSponSpeechPilot_info('transfer phases names');
    case 'vsaCP'
        sentenceBlocks   = get_vsaCP_info('sentence phases indices'); % doesn't include IEEE sentence blocks (9, 11, 12, 13)
        transferBlocks   = get_vsaCP_info('transfer phases indices');
        nBlocks          = 16; % the total number of blocks in the experiment, even if we're not analyzing all of them
%         nBlocks          = length(sentenceBlocks) + length(transferBlocks);
        sentenceBaseline = 6;   %expt.conds = 'baselinePassage'
        sentenceAdapted  = 13;  %expt.conds = 'adaptPassage'
        transferBaseline = 7;   %expt.conds = 'baselineTransfer'
        transferAdapted  = 14;  %expt.conds = 'transfer'
        sentencePhases   = get_vsaCP_info('sentence phases names'); % condition name, from expt.conds
        transferPhases   = get_vsaCP_info('transfer phases names');
end
sentenceVowels   = {'IY','IH','EH','AE','AA','AH','OW','UW','EY','UH','ER','AO','AW','AY'};
transferVowels   = {'IY','IH','EH','AE','AA','AH','OW','UW','EY','UH'};


% preallocate
data2plot.adaptFirst    = nan(nSubj_adaptFirst, nBlocks);
data2plot.controlFirst  = nan(nSubj_adaptSecond, nBlocks);
data2plot.adaptSecond   = nan(nSubj_adaptSecond, nBlocks);
data2plot.controlSecond = nan(nSubj_adaptFirst, nBlocks);

% subset
T_adaptFirst    = T(T.adaptFirst==1 & strcmp(T.cond, 'adapt'),:);
T_controlFirst  = T(T.adaptFirst==0 & strcmp(T.cond, 'null'),:);
T_adaptSecond   = T(T.adaptFirst==0 & strcmp(T.cond, 'adapt'),:);
T_controlSecond = T(T.adaptFirst==1 & strcmp(T.cond, 'null'),:);

% keep track of subjects
origSubj_adaptFirst  = unique(T_adaptFirst.subj);
origSubj_adaptSecond = unique(T_adaptSecond.subj);

% populate adaptFirst and controlSecond
for s = 1:nSubj_adaptFirst
    % adapt
    sData = T_adaptFirst(T_adaptFirst.subj==origSubj_adaptFirst(s),:);
    phases = sData.phase;
    for p = 1:length(phases)
        phase = phases{p};
        if any(contains(sentencePhases, phase))
            b = sentenceBlocks(strcmp(phase, sentencePhases));
        elseif any(contains(transferPhases, phase))
            b = transferBlocks(strcmp(phase, transferPhases));
        else
            error('Phase names do not match.');
        end
        data2plot.adaptFirst(s,b) = sData(strcmp(sData.phase, phase),:).(analysis);
    end
    % control
    sData = T_controlSecond(T_controlSecond.subj==origSubj_adaptFirst(s),:);
    phases = sData.phase;
    for p = 1:length(phases)
        phase = phases{p};
        if any(contains(sentencePhases, phase))
            b = sentenceBlocks(strcmp(phase, sentencePhases));
        elseif any(contains(transferPhases, phase))
            b = transferBlocks(strcmp(phase, transferPhases));
        else
            error('Phase names do not match.');
        end
        data2plot.controlSecond(s,b) = sData(strcmp(sData.phase, phase),:).(analysis); 
    end
end

% populate controlFirst and adaptSecond
for s = 1:nSubj_adaptSecond
    % control
    sData = T_controlFirst(T_controlFirst.subj==origSubj_adaptSecond(s),:);
    phases = sData.phase;
    for p = 1:length(phases)
        phase = phases{p};
        if any(contains(sentencePhases, phase))
            b = sentenceBlocks(strcmp(phase, sentencePhases));
        elseif any(contains(transferPhases, phase))
            b = transferBlocks(strcmp(phase, transferPhases));
        else
            error('Phase names do not match.');
        end
        data2plot.controlFirst(s,b) = sData(strcmp(sData.phase, phase),:).(analysis);
    end
    % adapt
    sData = T_adaptSecond(T_adaptSecond.subj==origSubj_adaptSecond(s),:);
    phases = sData.phase;
    for p = 1:length(phases)
        phase = phases{p};
        if any(contains(sentencePhases, phase))
            b = sentenceBlocks(strcmp(phase, sentencePhases));
        elseif any(contains(transferPhases, phase))
            b = transferBlocks(strcmp(phase, transferPhases));
        else
            error('Phase names do not match.');
        end
        data2plot.adaptSecond(s,b) = sData(strcmp(sData.phase, phase),:).(analysis);
    end
end

end % of function
