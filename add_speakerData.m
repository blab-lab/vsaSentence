function [speakerData] = add_speakerData
% Adds data to speakerData (one row per speaker) for vsaSentence.
% Skips adding if the source data file is missing.
% Skips adding if the source data is already present in speakerData.

% check for existing base file
outPath = get_exptLoadPath('vsaSentence');
saveFile = fullfile(outPath, 'speakerData.mat');
if ~isfile(saveFile)
    fprintf('speakerData.mat is missing; you must run gen_speakerData before add_speakerData. \n');
    return;
end
fprintf('Loading existing speakerData from %s... ', outPath)
load(saveFile, 'speakerData');
nSubj = height(speakerData);

% --- get AVS and VSA (raw, norm; all phases/conds) ---

avsvsaFile = fullfile(outpath, ['avs_vsa_' num2str(nSubj) '.mat']);
if ~isfile(avsvsaFile)
    fprintf('AVS_VSA source data are missing; skipping these data. \n');
else
    if ismember('avs_adapt_baseline1', speakerData.Properties.VariableNames)
        fprintf('AVS_VSA data are already included; skipping these data. \n');
    else
        fprintf('Loading existing AVS_VSA from %s... ', outPath)
        load(avsvsaFile, 'AVS_VSA');

        ivs = {'subj','cond','phase','adaptFirst'};
        dvs = AVS_VSA.Properties.VariableNames;
        dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
        temp = unstack(AVS_VSA, dvs, 'cond');
        ivs = {'subj','phase','adaptFirst'};
        dvs = temp.Properties.VariableNames;
        dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
        avs_vsa_wide = unstack(temp, dvs, 'phase');
    end
end

% --- get AAVS (raw, norm; all phases/conds) ---

aavsFile = fullfile(outpath, ['aavs_' num2str(nSubj) '.mat']);
if ~isfile(aavsFile)
    fprintf('AAVS source data are missing; skipping these data. \n');
else
    if ismember('aavs_adapt_baseline1', speakerData.Properties.VariableNames)
        fprintf('AAVS data are already included; skipping these data. \n');
    else
        fprintf('Loading existing AAVS from %s... ', outPath)
        load(aavsFile, 'AAVS');

        ivs = {'subj','cond','phase','adaptFirst'};
        dvs = AAVS.Properties.VariableNames;
        dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
        temp = unstack(AAVS, dvs, 'cond');
        ivs = {'subj','phase','adaptFirst'};
        dvs = temp.Properties.VariableNames;
        dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
        aavs_wide = unstack(temp, dvs, 'phase');
    end
end

if exist('avs_vsa_wide', 'var') && exist('aavs_wide', 'var')
    vs = join(avs_vsa_wide, aavs_wide);
    speakerData = [speakerData(:,1:6) vs];
elseif exist('avs_vsa_wide', 'var') && ~exist('aavs_wide', 'var')
    vs = avs_vsa_wide;
    speakerData = [speakerData(:,1:6) vs];
elseif ~exist('avs_vsa_wide', 'var') && exist('aavs_wide', 'var')
    vs = aavs_wide;
    speakerData = [speakerData(:,1:6) vs];
end

% --- get clear-speech metrics ("supplementary data") ---

suppSenFile = fullfile(outpath, ['supplementaryData_sentence_' num2str(nSubj) '.mat']);
suppTraFile = fullfile(outpath, ['supplementaryData_transfer_' num2str(nSubj) '.mat']);
if any(~isfile(suppSenFile, suppTraFile))
    fprintf('Supplementary source data are missing; skipping these data. \n');
else
    if ismember('durations_adapt_baseline1', speakerData.Properties.VariableNames)
        fprintf('Supplementary data are already included; skipping these data. \n');
    else
        fprintf('Loading existing supplementary data from %s... ', outPath)

        analyses       = {'durations', 'intensityMax', 'intensityMean', 'f0Max', 'f0Mean', 'f0Range'};
        sentenceBlocks = [1 3 5 6 7 8 9 10 11 13 14];
        transferBlocks = [2 4 12];
        sentenceTrials = [1:40; 41:80; 81:120; 121:160; 161:200; 201:240; 241:280; 281:320; 321:360; 361:400; 401:440];
        transferTrials = [1:50; 51:100; 101:150];
        sentencePhases = {'baseline1', 'baseline2', 'ramp', 'hold1', 'hold2', 'hold3', 'hold4', 'hold5', 'hold6', 'washout', 'retention'};
        transferPhases = {'transfer1', 'transfer2', 'transfer3'};

        for i = 1:length(analyses)
            analysis = analyses{i};

            sen = load(suppSenFile, analysis);
            for b = 1:length(sentenceBlocks)
                phase = sentencePhases{b};
                adapt = nanmean(sen.(analysis).adapt(:,sentenceTrials(b,:)),2);
                null  = nanmean(sen.(analysis).control(:,sentenceTrials(b,:)),2);
                adaptVarName = [analysis '_adapt_' phase];
                nullVarName  = [analysis '_null_' phase];
                speakerData = addvars(speakerData, adapt, null, 'NewVariableNames', {adaptVarName, nullVarName}); % raw
            end

            tra = load(suppTraFile, analysis);
            for b = 1:length(transferBlocks)
                phase = transferPhases{b};
                adapt = nanmean(tra.(analysis).adapt(:,transferTrials(b,:)),2);
                null  = nanmean(tra.(analysis).control(:,transferTrials(b,:)),2);
                adaptVarName = [analysis '_adapt_' phase];
                nullVarName  = [analysis '_null_' phase];
                speakerData = addvars(speakerData, adapt, null, 'NewVariableNames', {adaptVarName, nullVarName}); % raw
            end

            for p = 1:length(sentencePhases)
                phase = sentencePhases{p};
                adaptVarName  = [analysis '_adapt_' phase];
                nullVarName   = [analysis '_null_' phase];
                adaptBaseName = [analysis '_adapt_baseline2'];
                nullBaseName  = [analysis '_null_baseline2'];
                adapt = speakerData.(adaptVarName) - speakerData.(adaptBaseName);
                null  = speakerData.(nullVarName) - speakerData.(nullBaseName);
                adaptVarName = strrep(adaptVarName, analysis, [analysis 'NormWithinSession']);
                nullVarName  = strrep(nullVarName, analysis, [analysis 'NormWithinSession']);
                speakerData = addvars(speakerData, adapt, null, 'NewVariableNames', {adaptVarName, nullVarName}); % norm w/r/t within-session baseline
            end

            for p = 1:length(transferPhases)
                phase = transferPhases{p};
                adaptVarName = [analysis '_adapt_' phase];
                nullVarName  = [analysis '_null_' phase];
                adaptBaseName = [analysis '_adapt_transfer2'];
                nullBaseName  = [analysis '_null_transfer2'];
                adapt = speakerData.(adaptVarName) - speakerData.(adaptBaseName);
                null  = speakerData.(nullVarName) - speakerData.(nullBaseName);
                adaptVarName = strrep(adaptVarName, analysis, [analysis 'NormWithinSession']);
                nullVarName  = strrep(nullVarName, analysis, [analysis 'NormWithinSession']);
                speakerData = addvars(speakerData, adapt, null, 'NewVariableNames', {adaptVarName, nullVarName}); % norm w/r/t within-session baseline
            end

            for s = 1:height(speakerData)
                if speakerData.adaptFirst(s) == 1
                    for p = 1:length(sentencePhases)
                        phase = sentencePhases{p};
                        adaptVarName = [analysis '_adapt_' phase];
                        nullVarName  = [analysis '_null_' phase];
                        adaptBaseName = [analysis '_adapt_baseline2'];
                        nullBaseName  = [analysis '_adapt_baseline2'];
                        adapt = speakerData.(adaptVarName)(s) - speakerData.(adaptBaseName)(s);
                        null  = speakerData.(nullVarName)(s) - speakerData.(nullBaseName)(s);
                        adaptVarName = strrep(adaptVarName, analysis, [analysis 'NormFirstSession']);
                        nullVarName  = strrep(nullVarName, analysis, [analysis 'NormFirstSession']);
                        speakerData.(adaptVarName)(s) = adapt;
                        speakerData.(nullVarName)(s) = null; % norm w/r/t first-session baseline
                    end
                    for p = 1:length(transferPhases)
                        phase = transferPhases{p};
                        adaptVarName = [analysis '_adapt_' phase];
                        nullVarName  = [analysis '_null_' phase];
                        adaptBaseName = [analysis '_adapt_transfer2'];
                        nullBaseName  = [analysis '_adapt_transfer2'];
                        adapt = speakerData.(adaptVarName)(s) - speakerData.(adaptBaseName)(s);
                        null  = speakerData.(nullVarName)(s) - speakerData.(nullBaseName)(s);
                        adaptVarName = strrep(adaptVarName, analysis, [analysis 'NormFirstSession']);
                        nullVarName  = strrep(nullVarName, analysis, [analysis 'NormFirstSession']);
                        speakerData.(adaptVarName)(s) = adapt;
                        speakerData.(nullVarName)(s) = null; % norm w/r/t first-session baseline
                    end
                else
                    for p = 1:length(sentencePhases)
                        phase = sentencePhases{p};
                        adaptVarName = [analysis '_adapt_' phase];
                        nullVarName  = [analysis '_null_' phase];
                        adaptBaseName = [analysis '_null_baseline2'];
                        nullBaseName  = [analysis '_null_baseline2'];
                        adapt = speakerData.(adaptVarName)(s) - speakerData.(adaptBaseName)(s);
                        null  = speakerData.(nullVarName)(s) - speakerData.(nullBaseName)(s);
                        adaptVarName = strrep(adaptVarName, analysis, [analysis 'NormFirstSession']);
                        nullVarName  = strrep(nullVarName, analysis, [analysis 'NormFirstSession']);
                        speakerData.(adaptVarName)(s) = adapt;
                        speakerData.(nullVarName)(s) = null; % norm w/r/t first-session baseline
                    end
                    for p = 1:length(transferPhases)
                        phase = transferPhases{p};
                        adaptVarName = [analysis '_adapt_' phase];
                        nullVarName  = [analysis '_null_' phase];
                        adaptBaseName = [analysis '_null_transfer2'];
                        nullBaseName  = [analysis '_null_transfer2'];
                        adapt = speakerData.(adaptVarName)(s) - speakerData.(adaptBaseName)(s);
                        null  = speakerData.(nullVarName)(s) - speakerData.(nullBaseName)(s);
                        adaptVarName = strrep(adaptVarName, analysis, [analysis 'NormFirstSession']);
                        nullVarName  = strrep(nullVarName, analysis, [analysis 'NormFirstSession']);
                        speakerData.(adaptVarName)(s) = adapt;
                        speakerData.(nullVarName)(s) = null; % norm w/r/t first-session baseline
                    end
                end
            end
        end
    end
end

% --- get overall perceptual accuracy for second sessions ---

accSenFile = fullfile(outpath, 'sentenceAcc.mat');
accTraFile = fullfile(outpath, 'transferAcc.mat');
if any(~isfile(accSenFile, accTraFile))
    fprintf('Overall perceptual accuracy source data are missing; skipping these data. \n');
else
    if ismember('sentenceAcc_adapt_MWord_baseline2', speakerData.Properties.VariableNames)
        fprintf('Overall perceptual accuracy data are already included; skipping these data. \n');
    else
        fprintf('Loading existing overall perceptual accuracy data from %s... ', outPath)

        load(accSenFile, 'senPercAcc_bySpeaker');
        load(accTraFile, 'traPercAcc_bySpeaker');

        clear speaker;
        sp = fieldnames(senPercAcc_bySpeaker);
        for s = 1:length(sp)
            speaker{s}                                = sp{s}; %#ok<*AGROW> 
            sentenceAcc_adapt_MWord_baseline2(s)      = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MWord.base);
            sentenceAcc_adapt_MWord_hold6(s)          = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MWord.hold);
            sentenceAcc_adapt_MWord_gain(s)           = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MWord.gain);
            sentenceAcc_adapt_MVwl_baseline2(s)       = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MVwl.base);
            sentenceAcc_adapt_MVwl_hold6(s)           = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MVwl.hold);
            sentenceAcc_adapt_MVwl_gain(s)            = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MVwl.gain);
            sentenceAcc_adapt_MVwl_schwa_baseline2(s) = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MVwl_schwa.base);
            sentenceAcc_adapt_MVwl_schwa_hold6(s)     = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MVwl_schwa.hold);
            sentenceAcc_adapt_MVwl_schwa_gain(s)      = mean(senPercAcc_bySpeaker.(sp{s}).adapt.MVwl_schwa.gain);

            sentenceAcc_null_MWord_baseline2(s)       = mean(senPercAcc_bySpeaker.(sp{s}).null.MWord.base);
            sentenceAcc_null_MWord_hold6(s)           = mean(senPercAcc_bySpeaker.(sp{s}).null.MWord.hold);
            sentenceAcc_null_MWord_gain(s)            = mean(senPercAcc_bySpeaker.(sp{s}).null.MWord.gain);
            sentenceAcc_null_MVwl_baseline2(s)        = mean(senPercAcc_bySpeaker.(sp{s}).null.MVwl.base);
            sentenceAcc_null_MVwl_hold6(s)            = mean(senPercAcc_bySpeaker.(sp{s}).null.MVwl.hold);
            sentenceAcc_null_MVwl_gain(s)             = mean(senPercAcc_bySpeaker.(sp{s}).null.MVwl.gain);
            sentenceAcc_null_MVwl_schwa_baseline2(s)  = mean(senPercAcc_bySpeaker.(sp{s}).null.MVwl_schwa.base);
            sentenceAcc_null_MVwl_schwa_hold6(s)      = mean(senPercAcc_bySpeaker.(sp{s}).null.MVwl_schwa.hold);
            sentenceAcc_null_MVwl_schwa_gain(s)       = mean(senPercAcc_bySpeaker.(sp{s}).null.MVwl_schwa.gain);
        end

        sens = table(speaker', sentenceAcc_adapt_MWord_baseline2', sentenceAcc_adapt_MWord_hold6', sentenceAcc_adapt_MWord_gain', ...
            sentenceAcc_adapt_MVwl_baseline2', sentenceAcc_adapt_MVwl_hold6', sentenceAcc_adapt_MVwl_gain', ...
            sentenceAcc_adapt_MVwl_schwa_baseline2', sentenceAcc_adapt_MVwl_schwa_hold6', sentenceAcc_adapt_MVwl_schwa_gain', ...
            sentenceAcc_null_MWord_baseline2', sentenceAcc_null_MWord_hold6', sentenceAcc_null_MWord_gain', ...
            sentenceAcc_null_MVwl_baseline2', sentenceAcc_null_MVwl_hold6', sentenceAcc_null_MVwl_gain', ...
            sentenceAcc_null_MVwl_schwa_baseline2', sentenceAcc_null_MVwl_schwa_hold6', sentenceAcc_null_MVwl_schwa_gain', ...
            'VariableNames', ["speaker", "sentenceAcc_adapt_MWord_baseline2", "sentenceAcc_adapt_MWord_hold6", "sentenceAcc_adapt_MWord_gain", ...
            "sentenceAcc_adapt_MVwl_baseline2", "sentenceAcc_adapt_MVwl_hold6", "sentenceAcc_adapt_MVwl_gain", ...
            "sentenceAcc_adapt_MVwl_schwa_baseline2", "sentenceAcc_adapt_MVwl_schwa_hold6", "sentenceAcc_adapt_MVwl_schwa_gain", ...
            "sentenceAcc_null_MWord_baseline2", "sentenceAcc_null_MWord_hold6", "sentenceAcc_null_MWord_gain", ...
            "sentenceAcc_null_MVwl_baseline2", "sentenceAcc_null_MVwl_hold6", "sentenceAcc_null_MVwl_gain", ...
            "sentenceAcc_null_MVwl_schwa_baseline2", "sentenceAcc_null_MVwl_schwa_hold6", "sentenceAcc_null_MVwl_schwa_gain"]);

        speakerData = outerjoin(speakerData, sens, 'Keys', 'speaker');
        speakerData = removevars(speakerData, 'speaker_sens');
        speakerData = renamevars(speakerData, 'speaker_speakerData', 'speaker');

        clear speaker;
        sp = fieldnames(traPercAcc_bySpeaker);
        for s = 1:length(sp)
            speaker{s}                                = sp{s};
            transferAcc_adapt_transfer2(s)            = mean(traPercAcc_bySpeaker.(sp{s}).adapt.base);
            transferAcc_adapt_transfer3(s)            = mean(traPercAcc_bySpeaker.(sp{s}).adapt.hold);
            transferAcc_adapt_gain(s)                 = mean(traPercAcc_bySpeaker.(sp{s}).adapt.gain);

            transferAcc_null_transfer2(s)             = mean(traPercAcc_bySpeaker.(sp{s}).null.base);
            transferAcc_null_transfer3(s)             = mean(traPercAcc_bySpeaker.(sp{s}).null.hold);
            transferAcc_null_gain(s)                  = mean(traPercAcc_bySpeaker.(sp{s}).null.gain);
        end

        tras = table(speaker', transferAcc_adapt_transfer2', transferAcc_adapt_transfer3', transferAcc_adapt_gain', ...
            transferAcc_null_transfer2', transferAcc_null_transfer3', transferAcc_null_gain', ...
            'VariableNames', ["speaker", "transferAcc_adapt_transfer2", "transferAcc_adapt_transfer3", "transferAcc_adapt_gain", ...
            "transferAcc_null_transfer2", "transferAcc_null_transfer3", "transferAcc_null_gain"]);

        speakerData = outerjoin(speakerData, tras, 'Keys', 'speaker');
        speakerData = removevars(speakerData, 'speaker_tras');
        speakerData = renamevars(speakerData, 'speaker_speakerData', 'speaker');

    end
end

save(saveFile, 'speakerData');

end
