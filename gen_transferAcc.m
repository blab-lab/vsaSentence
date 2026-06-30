function [transferDataTable] = gen_transferAcc(transferDownload, ids, bExclListener)
% Generate percent accuracy for transfer-word identififcation;
% also generate percent accuracy and gain in accuracy by vowel.

T = readtable(transferDownload);

if nargin < 2 || isempty(ids); ids = unique(T.Listener_id); end
if nargin < 3 || isempty(bExclListener), bExclListener = 0; end % exclude listeners who failed Huggins/Binaural/Catch trials

% --- Data to analyze can be selected by speakers' or listeners' ids ---
if iscell(ids)
    rows = contains(T.Speaker, ids);
    T = T(rows,:);
else
    rows = ismember(T.Listener_id, ids);
    T = T(rows,:);
end
nSpeakers = length(unique(T.Speaker));

% --- Check for existing output file before saving ---
saveName = strcat('transferAcc_', num2str(nSpeakers), '.mat');
outPath = get_exptLoadPath('vsaSentence');
saveFile = fullfile(outPath, saveName);
bSave = savecheck(saveFile);
if ~bSave, return; end

% --- Get speakers' session orders ---
speakerFile = fullfile(outPath, 'speakerData.mat');
if ~isfile(speakerFile)
    fprintf('speakerData.mat is missing; you must run gen_speakerData first. \n');
    return;
end
load(speakerFile, 'speakerData');

% --- Clean up the data table ---
listeners2Analyze = unique(T.Listener_id);

for i = 1:length(listeners2Analyze)

    listenerData = T(T.Listener_id == listeners2Analyze(i),:);

    nCorrectHuggins = 0;
    nCorrectBinaural = 0;
    nCorrectCatch = 0;

    for t = 1:6
        thisStimHuggins = ['H_correct_response_' num2str(t)];
        thisRespHuggins = ['H_response_' num2str(t)];
        thisStimBinaural = ['B_correct_response_' num2str(t)];
        thisRespBinaural = ['B_response_' num2str(t)];
        if listenerData.(thisStimHuggins)(1) == listenerData.(thisRespHuggins)(1)
            nCorrectHuggins = nCorrectHuggins + 1;
        end
        if listenerData.(thisStimBinaural)(1) == listenerData.(thisRespBinaural)(1)
            nCorrectBinaural = nCorrectBinaural + 1;
        end
    end

    for t = 1:height(listenerData)
        if contains(listenerData.SNR(t), '-10') || contains(listenerData.SNR(t), '-7')
            if listenerData.Correct_location(t) == listenerData.Response_location(t)
                nCorrectCatch = nCorrectCatch + 1;
            end
        end
    end

    longestRunLength = max(diff(find([1,diff(listenerData.Response_location'),1])));
    fprintf('Listener %d had a run of %d of the same button press in a row.\n', listeners2Analyze(i), longestRunLength);

    if nCorrectHuggins < 5
        fprintf('Listener %d only got %d out of 6 Huggins trials correct.\n', listeners2Analyze(i), nCorrectHuggins);
        if bExclListener
            continue;
        end
    end
    if nCorrectBinaural < 5
        fprintf('Listener %d only got %d out of 6 Binaural trials correct.\n', listeners2Analyze(i), nCorrectBinaural);
        if bExclListener
            continue;
        end
    end
    if nCorrectCatch < 9
        fprintf('Listener %d only got %d out of 10 Catch trials correct.\n', listeners2Analyze(i), nCorrectCatch);
        if bExclListener
            continue;
        end
    end

    listenerData = listenerData(:,[1:5 30:end]); % remove the Huggins and Binaural data (6:29)
    rows = ~contains(listenerData.SNR, '-10');
    listenerData = listenerData(rows,:); % remove the Catch trials
    rows = ~contains(listenerData.SNR, '-7');
    listenerData = listenerData(rows,:); % remove the Catch trials

    for t = 1:height(listenerData)
        if listenerData.Correct_location(t) == listenerData.Response_location(t)
            listenerData.Correct(t) = 1; % keep track of trialwise accuracy
        else
            listenerData.Correct(t) = 0;
        end
        if strcmp(listenerData.Condition(t), 'transfer3')
            listenerData.Adapted(t) = 1;
        else
            listenerData.Adapted(t) = 0;
        end

        listenerData.Speaker{t} = listenerData.Speaker{t}(1:5); % strip '-null'

        if speakerData(strcmp(speakerData.speaker, listenerData.Speaker{t}),:).adaptFirst == 1
            if strcmp(listenerData.Session(t), 'adapt')
                listenerData.FirstSession(t) = 1; % keep track of session order
            else
                listenerData.FirstSession(t) = 0;
            end
        else
            if strcmp(listenerData.Session(t), 'adapt')
                listenerData.FirstSession(t) = 0;
            else
                listenerData.FirstSession(t) = 1;
            end
        end
    end

    allData{i} = listenerData;

end
clear speakerData listenerData;

transferDataTable = vertcat(allData{:});
transferDataTable = movevars(transferDataTable, "FirstSession", 'After', "Session");

% ----------------------------------------------------
% Calculate overall accuracy by listeners and speakers
% ----------------------------------------------------

sessions2Analyze = unique(transferDataTable.Session);

for a = 1:length(sessions2Analyze)

    session = sessions2Analyze{a};
    sessionData = transferDataTable(strcmp(transferDataTable.Session, session),:);
    speakers2Analyze = unique(sessionData.Speaker);

    for s = 1:length(speakers2Analyze)
    
        speaker = speakers2Analyze{s};
        speakerData = sessionData(strcmp(sessionData.Speaker, speaker),:);
        listeners2Analyze = unique(speakerData.Listener_id);
    
        for i = 1:length(listeners2Analyze)
    
            listenerData = speakerData(speakerData.Listener_id == listeners2Analyze(i),:);
            listenerName = ['listener' num2str(listenerData.Listener_id(1))];
    
            nBase = 0;
            nHold = 0;
            nBaseCorrect = 0;
            nHoldCorrect = 0;
    
            for t = 1:height(listenerData)
                if listenerData.Adapted(t) == 0
                    nBase = nBase + 1;
                    if listenerData.Correct(t) == 1
                        nBaseCorrect = nBaseCorrect + 1;
                    end
                else
                    nHold = nHold + 1;
                    if listenerData.Correct(t) == 1
                        nHoldCorrect = nHoldCorrect + 1;
                    end
                end
            end
    
            traPercAcc_bySpeaker.(speaker).(session).base(i) = 100*(nBaseCorrect / nBase); % percent correct
            traPercAcc_bySpeaker.(speaker).(session).hold(i) = 100*(nHoldCorrect / nHold); % percent correct
            traPercAcc_bySpeaker.(speaker).(session).gain(i) = 100*(nHoldCorrect / nHold) - 100*(nBaseCorrect / nBase); % percentage-point gain from baseline to adapted
    
            traPercAcc_byListener.(listenerName).(session).base = 100*(nBaseCorrect / nBase);
            traPercAcc_byListener.(listenerName).(session).hold = 100*(nHoldCorrect / nHold);
            traPercAcc_byListener.(listenerName).(session).gain = 100*(nHoldCorrect / nHold) - 100*(nBaseCorrect / nBase);
    
        end
    end
end

% ----------------------------------------------------
% Calculate percent accuracy by vowel (includes phase)
% ----------------------------------------------------

count = 1;

speakers2Analyze = unique(transferDataTable.Speaker);

for s = 1:length(speakers2Analyze) % for each speaker

    speaker = speakers2Analyze{s};
    speakerData = transferDataTable(strcmp(transferDataTable.Speaker, speaker),:);
    listeners2Analyze = unique(speakerData.Listener_id);

    for i = 1:length(listeners2Analyze) % for each listener of that speaker

        listener = listeners2Analyze(i);
        listenerData = speakerData(speakerData.Listener_id == listener,:);
        vowels2Analyze = unique(listenerData.Correct_response); % 9 words

        for v = 1:length(vowels2Analyze) % for each vowel

            vowel = vowels2Analyze{v};
            vowelData = listenerData(strcmp(listenerData.Correct_response, vowel),:);
            conds2Analyze = unique(vowelData.Session); % adapt/null

            for c = 1:length(conds2Analyze) % for each cond/session

                cond = conds2Analyze{c};
                condData = vowelData(strcmp(vowelData.Session, cond),:);
                phases2Analyze = unique(condData.Condition); % transfer2/transfer3

                for p = 1:length(phases2Analyze) % for each phase

                    phase = phases2Analyze{p};
                    phaseData = condData(strcmp(condData.Condition, phase),:);

                    nTrials = height(phaseData);
                    nCorrect = sum(phaseData.Correct);

                    speakers{count}      = speaker;
                    listeners(count)     = listener;
                    vowels{count}        = vowel;
                    conds{count}         = cond;
                    phases{count}        = phase;
                    firstSessions(count) = phaseData.FirstSession(1);
                    percs(count)         = nCorrect / nTrials; % percent correct

                    count = count + 1;
                    clear nTrials nCorrect;
                end
            end
        end
    end
end
clear phaseData;

vowels = replace(vowels, 'bid', 'IH');
vowels = replace(vowels, 'bayed', 'EY');
vowels = replace(vowels, 'bed', 'EH');
vowels = replace(vowels, 'bode', 'OW'); % do before bod
vowels = replace(vowels, 'bud', 'AH');
vowels = replace(vowels, 'bead', 'IY');
vowels = replace(vowels, 'bad', 'AE');
vowels = replace(vowels, 'booed', 'UW');
vowels = replace(vowels, 'bod', 'AA'); % do after bode

traPercAcc_byVowel = table(speakers', listeners', vowels', conds', phases', firstSessions', percs', ...
    'VariableNames', ["speaker", "listener", "vow", "cond", "phase", "firstSession", "perc"]);

clear speakers listeners conds phases vowels firstSessions;

% -----------------------------------------------------------
% Calculate gain in accuracy by vowel (doesn't include phase)
% -----------------------------------------------------------

count = 1;

speakers2Analyze = unique(traPercAcc_byVowel.speaker);

for s = 1:length(speakers2Analyze) % for each speaker

    speaker = speakers2Analyze{s};
    speakerData = traPercAcc_byVowel(strcmp(traPercAcc_byVowel.speaker, speaker),:);
    listeners2Analyze = unique(speakerData.listener);

    for i = 1:length(listeners2Analyze) % for each listener of that speaker

        listener = listeners2Analyze(i);
        listenerData = speakerData(speakerData.listener == listener,:);
        vowels2Analyze = unique(listenerData.vow); % 9 words

        for v = 1:length(vowels2Analyze) % for each vowel

            vowel = vowels2Analyze{v};
            vowelData = listenerData(strcmp(listenerData.vow, vowel),:);
            conds2Analyze = unique(vowelData.cond); % adapt/null

            for c = 1:length(conds2Analyze) % for each cond/session

                cond = conds2Analyze{c};
                condData = vowelData(strcmp(vowelData.cond, cond),:);
                phases2Analyze = unique(condData.phase); % transfer2/transfer3 (in this sorted order)

                for p = 1:length(phases2Analyze) % for each phase

                    phase = phases2Analyze{p};
                    phaseData(p) = condData(strcmp(condData.phase, phase),:).perc;
                end

                speakers{count}      = speaker;
                listeners(count)     = listener;
                vows{count}          = vowel;
                conds{count}         = cond;
                firstSessions(count) = condData.firstSession(1);
                gains(count)         = phaseData(2) - phaseData(1); % percentage-point gain from baseline to adpated

                count = count + 1;
                clear phaseData;
            end
        end
    end
end

traGain_byVowel = table(speakers', listeners', vows', conds', firstSessions', gains', ...
    'VariableNames', ["speaker", "listener", "vow", "cond", "firstSession", "gain"]);

save(saveFile, 'traPercAcc_bySpeaker', 'traPercAcc_byListener', 'traPercAcc_byVowel', 'traGain_byVowel');
fprintf('Saved %s\n', saveFile);

end
