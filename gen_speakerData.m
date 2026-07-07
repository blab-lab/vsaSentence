function [speakerData] = gen_speakerData(dataPaths, sentenceDownloadName, transferDownloadName)
% Builds a giant table with one row per speaker from vsaSentence.
% sentenceDownloadName and transferDownloadName are perceptual data from Prolific.

% --- Check for existing output file before saving ---
saveName = 'speakerData';
outPath = get_exptLoadPath('vsaSentence');
saveFile = fullfile(outPath, saveName);
bSave = savecheck(saveFile);
if ~bSave, return; end

% --- Get the basics ---

for s = 1:length(dataPaths)
    dataPath = dataPaths{s};
    [~, speaker{s}] = fileparts(dataPath); %#ok<*AGROW> 
    load(fullfile(dataPath, 'adapt', 'expt.mat'), 'expt');
    dateAdapt{s} = expt.date;
    load(fullfile(dataPath, 'null', 'expt.mat'), 'expt');
    dateNull{s} = expt.date;
    daysBtwSessions(s) = daysact(dateAdapt{s}, dateNull{s});
    %if daysBtwSessions(s) > 0; adaptFirst(s) = 1; % chronological order of adapt and null sessions
    %else; adaptFirst(s) = 0; end
    if strcmp(expt.gender, 'female'); male(s) = 0;
    elseif strcmp(expt.gender, 'male'); male(s) = 1;
    else; male(s) = 2; end
end
if s == 41; age = [20 20 20 52 20 61 26 64 55 20 18 20 20 34 41 52 33 19 23 20 18 19 41 39 31 63 40 36 61 63 50 34 71 60 68 52 70 66 72 70 76]; end % from Data Analysis Tracking

basics = table(speaker', male', age', dateAdapt', dateNull', daysBtwSessions', ...
    'VariableNames', ["speaker", "male", "age", "dateAdapt", "dateNull", "daysBtwSessions"]);

% --- Get AVS and VSA (raw, norm; all phases/conds) ---

load(fullfile(outPath, 'avs_vsa_41.mat'), 'AVS_VSA');
ivs = {'subj','cond','phase','adaptFirst'};
dvs = AVS_VSA.Properties.VariableNames;
dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
temp = unstack(AVS_VSA, dvs, 'cond');
ivs = {'subj','phase','adaptFirst'};
dvs = temp.Properties.VariableNames;
dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
avs_vsa_wide = unstack(temp, dvs, 'phase');

% --- Get AAVS (raw, norm; all phases/conds) ---

load(fullfile(outPath, 'aavs_41.mat'), 'AAVS');
ivs = {'subj','cond','phase','adaptFirst'};
dvs = AAVS.Properties.VariableNames;
dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
temp = unstack(AAVS, dvs, 'cond');
ivs = {'subj','phase','adaptFirst'};
dvs = temp.Properties.VariableNames;
dvs = setdiff(dvs, ivs, 'stable'); % remove ivs and preserve order
aavs_wide = unstack(temp, dvs, 'phase');

vs = join(avs_vsa_wide, aavs_wide);
speakerData = [basics vs];

% --- Get clear speech ---

analyses         = {'durations', 'intensityMax', 'intensityMean', 'f0Max', 'f0Mean', 'f0Range'};
nSubj            = 41;
nBlocks          = 14;
sentenceBlocks   = [1 3 5 6 7 8 9 10 11 13 14];
transferBlocks   = [2 4 12];
sentenceBaseline = 3;
transferBaseline = 4;
sentenceTrials   = [1:40; 41:80; 81:120; 121:160; 161:200; 201:240; 241:280; 281:320; 321:360; 361:400; 401:440];
transferTrials   = [1:50; 51:100; 101:150];
sentencePhases   = {'baseline1', 'baseline2', 'ramp', 'hold1', 'hold2', 'hold3', 'hold4', 'hold5', 'hold6', 'washout', 'retention'};
transferPhases   = {'transfer1', 'transfer2', 'transfer3'};

for i = 1:length(analyses)
    analysis = analyses{i};
    sen = load(fullfile(outPath, 'supplementaryData_sentence_41.mat'), analysis);
    for b = 1:length(sentenceBlocks)
        phase = sentencePhases{b};
        adapt = nanmean(sen.(analysis).adapt(:,sentenceTrials(b,:)),2);
        null  = nanmean(sen.(analysis).control(:,sentenceTrials(b,:)),2);
        adaptVarName = [analysis '_adapt_' phase];
        nullVarName  = [analysis '_null_' phase];
        speakerData = addvars(speakerData, adapt, null, 'NewVariableNames', {adaptVarName, nullVarName}); % raw
    end

    tra = load(fullfile(outPath, 'supplementaryData_transfer_41.mat'), analysis);
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

% --- Get perceptual accuracy for second sessions ---

listeners_adapt = [439:442 455:458 479:482 487:494 499:502 507:510 515:518 527:546 555:562 579:590 595:598 603:606 611:614]; % listeners_adapt2nd
listeners_null  = [427:430 435:438 451:454 467:470 475:478 495:498 503:506 511:514 519:526 547:554 563:578 591:594 599:602 607:610 615:618]; % listeners_null2nd
%listeners_adapt = [423:426 431:434 447:450 463:466 471:474]; % listeners_adapt1st
%listeners_null  = [443:446 459:462 483:486]; % listeners_null1st

[sen_adapt, ~, ~] = gen_sentenceAcc(sentenceDownloadName, listeners_adapt);
[sen_null, ~, ~]  = gen_sentenceAcc(sentenceDownloadName, listeners_null);
[tra_adapt, ~, ~] = gen_transferAcc(transferDownloadName, listeners_adapt);
[tra_null, ~, ~]  = gen_transferAcc(transferDownloadName, listeners_null);

clear speaker;
sa = fieldnames(sen_adapt);
for s = 1:length(sa)
    speaker{s}                                = sa{s};
    sentenceAcc_adapt_MWord_baseline2(s)      = mean(sen_adapt.(sa{s}).MWord.base);
    sentenceAcc_adapt_MWord_hold6(s)          = mean(sen_adapt.(sa{s}).MWord.hold);
    sentenceAcc_adapt_MWord_gain(s)           = mean(sen_adapt.(sa{s}).MWord.gain);
    sentenceAcc_adapt_MVwl_baseline2(s)       = mean(sen_adapt.(sa{s}).MVwl.base);
    sentenceAcc_adapt_MVwl_hold6(s)           = mean(sen_adapt.(sa{s}).MVwl.hold);
    sentenceAcc_adapt_MVwl_gain(s)            = mean(sen_adapt.(sa{s}).MVwl.gain);
    sentenceAcc_adapt_MVwl_schwa_baseline2(s) = mean(sen_adapt.(sa{s}).MVwl_schwa.base);
    sentenceAcc_adapt_MVwl_schwa_hold6(s)     = mean(sen_adapt.(sa{s}).MVwl_schwa.hold);
    sentenceAcc_adapt_MVwl_schwa_gain(s)      = mean(sen_adapt.(sa{s}).MVwl_schwa.gain);
    transferAcc_adapt_transfer2(s)            = mean(tra_adapt.(sa{s}).base);
    transferAcc_adapt_transfer3(s)            = mean(tra_adapt.(sa{s}).hold);
    transferAcc_adapt_gain(s)                 = mean(tra_adapt.(sa{s}).gain);  
end
adapts = table(speaker', sentenceAcc_adapt_MWord_baseline2', sentenceAcc_adapt_MWord_hold6', sentenceAcc_adapt_MWord_gain', ...
    sentenceAcc_adapt_MVwl_baseline2', sentenceAcc_adapt_MVwl_hold6', sentenceAcc_adapt_MVwl_gain', ...
    sentenceAcc_adapt_MVwl_schwa_baseline2', sentenceAcc_adapt_MVwl_schwa_hold6', sentenceAcc_adapt_MVwl_schwa_gain', ...
    transferAcc_adapt_transfer2', transferAcc_adapt_transfer3', transferAcc_adapt_gain', ...
    'VariableNames', ["speaker", "sentenceAcc_adapt_MWord_baseline2", "sentenceAcc_adapt_MWord_hold6", "sentenceAcc_adapt_MWord_gain", ...
    "sentenceAcc_adapt_MVwl_baseline2", "sentenceAcc_adapt_MVwl_hold6", "sentenceAcc_adapt_MVwl_gain", ...
    "sentenceAcc_adapt_MVwl_schwa_baseline2", "sentenceAcc_adapt_MVwl_schwa_hold6", "sentenceAcc_adapt_MVwl_schwa_gain", ...
    "transferAcc_adapt_transfer2", "transferAcc_adapt_transfer3", "transferAcc_adapt_gain"]);

clear speaker;
sn = fieldnames(sen_null);
for s = 1:length(sn)
    speaker{s}                               = sn{s};
    sentenceAcc_null_MWord_baseline2(s)      = mean(sen_null.(sn{s}).MWord.base);
    sentenceAcc_null_MWord_hold6(s)          = mean(sen_null.(sn{s}).MWord.hold);
    sentenceAcc_null_MWord_gain(s)           = mean(sen_null.(sn{s}).MWord.gain);
    sentenceAcc_null_MVwl_baseline2(s)       = mean(sen_null.(sn{s}).MVwl.base);
    sentenceAcc_null_MVwl_hold6(s)           = mean(sen_null.(sn{s}).MVwl.hold);
    sentenceAcc_null_MVwl_gain(s)            = mean(sen_null.(sn{s}).MVwl.gain);
    sentenceAcc_null_MVwl_schwa_baseline2(s) = mean(sen_null.(sn{s}).MVwl_schwa.base);
    sentenceAcc_null_MVwl_schwa_hold6(s)     = mean(sen_null.(sn{s}).MVwl_schwa.hold);
    sentenceAcc_null_MVwl_schwa_gain(s)      = mean(sen_null.(sn{s}).MVwl_schwa.gain);
    transferAcc_null_transfer2(s)            = mean(tra_null.(sn{s}).base);
    transferAcc_null_transfer3(s)            = mean(tra_null.(sn{s}).hold);
    transferAcc_null_gain(s)                 = mean(tra_null.(sn{s}).gain);
end
nulls = table(speaker', sentenceAcc_null_MWord_baseline2', sentenceAcc_null_MWord_hold6', sentenceAcc_null_MWord_gain', ...
    sentenceAcc_null_MVwl_baseline2', sentenceAcc_null_MVwl_hold6', sentenceAcc_null_MVwl_gain', ...
    sentenceAcc_null_MVwl_schwa_baseline2', sentenceAcc_null_MVwl_schwa_hold6', sentenceAcc_null_MVwl_schwa_gain', ...
    transferAcc_null_transfer2', transferAcc_null_transfer3', transferAcc_null_gain', ...
    'VariableNames', ["speaker", "sentenceAcc_null_MWord_baseline2", "sentenceAcc_null_MWord_hold6", "sentenceAcc_null_MWord_gain", ...
    "sentenceAcc_null_MVwl_baseline2", "sentenceAcc_null_MVwl_hold6", "sentenceAcc_null_MVwl_gain", ...
    "sentenceAcc_null_MVwl_schwa_baseline2", "sentenceAcc_null_MVwl_schwa_hold6", "sentenceAcc_null_MVwl_schwa_gain", ...
    "transferAcc_null_transfer2", "transferAcc_null_transfer3", "transferAcc_null_gain"]);

speakerData = outerjoin(speakerData, adapts, 'Keys', 'speaker');
speakerData = removevars(speakerData, 'speaker_adapts');
speakerData = renamevars(speakerData, 'speaker_speakerData', 'speaker');
speakerData = outerjoin(speakerData, nulls, 'Keys', 'speaker');
speakerData = removevars(speakerData, 'speaker_nulls');
speakerData = renamevars(speakerData, 'speaker_speakerData', 'speaker');

save(saveFile, 'speakerData');
fprintf('Saved %s\n', saveFile);

end % of function
