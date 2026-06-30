function [sentenceDataTable] = gen_sentenceAcc(sentenceDownload, ids)
% Generate percent accuracy for sentence transcription by three metrics:
% words correct, vowels correct, and vowels correct excluding schwa;
% also generate percent accuracy and gain in accuracy by vowel.

T = readtable(sentenceDownload);

if nargin < 2 || isempty(ids); ids = unique(T.Listener_id); end

% --- Overall accuracy statistics (words, vowels, vowels excluding schwa) ---
stats_stim = {'SWord', 'SVwl', 'SVwl_schwa'}; % present in the stimulus
stats_match = {'MWord', 'MVwl', 'MVwl_schwa'}; % of those in the response, those that matched the stimulus

% --- Vowels in the corpus ---
vowels2Analyze = {'i','I','eI','E','ae','^','3^','4','4^','@','oU','c','u','U','@I','@U'}; % PEPPERbet (there's no 'cI' in our corpus)
vowel_fieldnames = {'IY','IH','EY','EH','AE','AH','ER','AX','AXR','AA','OW','AO','UW','UH','AY','AW'}; % ARPAbet can be field names

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
saveName = strcat('sentenceAcc_', num2str(nSpeakers), '.mat');
outPath = get_exptLoadPath('vsaSentence');
saveFile = fullfile(outPath, saveName);
bSave = savecheck(saveFile);
if ~bSave, return; end

% --- Get speakers' session orders ----
speakerFile = fullfile(outPath, 'speakerData.mat');
if ~isfile(speakerFile)
    fprintf('speakerData.mat is missing; you must run gen_speakerData first. \n');
    return;
end
load(speakerFile, 'speakerData');

% --- Clean up the data table ---
for t = 1:height(T)

    T.Speaker{t} = T.Speaker{t}(1:5); % strip '-null'
    if speakerData(strcmp(speakerData.speaker, T.Speaker{t}),:).adaptFirst == 1
        if strcmp(T.Session(t), 'adapt')
            T.FirstSession(t) = 1; % keep track of session order
        else
            T.FirstSession(t) = 0;
        end
    else
        if strcmp(T.Session(t), 'adapt')
            T.FirstSession(t) = 0;
        else
            T.FirstSession(t) = 1;
        end
    end

end
clear speakerData;

sentenceDataTable = T;
sentenceDataTable = movevars(sentenceDataTable, "FirstSession", 'After', "Session");

% ----------------------------------------------------
% Calculate overall accuracy by listeners and speakers
% ----------------------------------------------------

sessions2Analyze = unique(T.Session);

for a = 1:length(sessions2Analyze)

    session = sessions2Analyze{a};
    sessionData = T(strcmp(T.Session, session),:);
    speakers2Analyze = unique(sessionData.Speaker);

    for c = 1:length(stats_match)

        stat_match = stats_match{c};
        stat_stim = stats_stim{c};

        for s = 1:length(speakers2Analyze)

            speaker = speakers2Analyze{s};
            speakerData = sessionData(strcmp(sessionData.Speaker, speaker),:);
            listeners2Analyze = unique(speakerData.Listener_id);

            for i = 1:length(listeners2Analyze)

                listenerData = T(T.Listener_id == listeners2Analyze(i),:);
                listenerName = ['listener' num2str(listenerData.Listener_id(1))];

                nBase = 0;
                nHold = 0;
                nBaseCorrect = 0;
                nHoldCorrect = 0;

                for t = 1:height(listenerData)
                    if strcmp(listenerData.Condition(t), 'baseline2')
                        nBase = nBase + listenerData.(stat_stim)(t);
                        nBaseCorrect = nBaseCorrect + listenerData.(stat_match)(t);
                    else
                        nHold = nHold + listenerData.(stat_stim)(t);
                        nHoldCorrect = nHoldCorrect + listenerData.(stat_match)(t);
                    end
                end

                senPercAcc_bySpeaker.(speaker).(session).(stat_match).base(i) = 100*(nBaseCorrect / nBase); % percent correct
                senPercAcc_bySpeaker.(speaker).(session).(stat_match).hold(i) = 100*(nHoldCorrect / nHold); % percent correct
                senPercAcc_bySpeaker.(speaker).(session).(stat_match).gain(i) = 100*(nHoldCorrect / nHold) - 100*(nBaseCorrect / nBase); % percentage-point gain from baseline to adapted

                senPercAcc_byListener.(listenerName).(session).(stat_match).base = 100*(nBaseCorrect / nBase);
                senPercAcc_byListener.(listenerName).(session).(stat_match).hold = 100*(nHoldCorrect / nHold);
                senPercAcc_byListener.(listenerName).(session).(stat_match).gain = 100*(nHoldCorrect / nHold) - 100*(nBaseCorrect / nBase);

            end
        end
    end
end

% ----------------------------------------------------
% Calculate percent accuracy by vowel (includes phase)
% ----------------------------------------------------

count = 1;

speakers2Analyze = unique(T.Speaker);

for s = 1:length(speakers2Analyze) % for each speaker

    speaker = speakers2Analyze{s};
    speakerData = T(strcmp(T.Speaker, speaker),:);
    listeners2Analyze = unique(speakerData.Listener_id);

    for i = 1:length(listeners2Analyze) % for each listener of that speaker

        listener = listeners2Analyze(i);
        listenerData = speakerData(speakerData.Listener_id == listener,:);
        conds2Analyze = unique(listenerData.Session); % adapt/null

        for c = 1:length(conds2Analyze) % for each cond/session

            cond = conds2Analyze{c};
            condData = listenerData(strcmp(listenerData.Session, cond),:);
            phases2Analyze = unique(condData.Condition); % baseline2/hold

            for p = 1:length(phases2Analyze) % for each phase

                phase = phases2Analyze{p};
                phaseData = condData(strcmp(condData.Condition, phase),:);

                for v = 1:length(vowels2Analyze) % for each vowel

                    vowel = vowels2Analyze{v};
                    match = 0;
                    nonmatch = 0;

                    for t = 1:height(phaseData) % for each sentence

                        matches = strsplit(phaseData.MVwl_ph{t}); % matches split by whitespace
                        nonmatches = strsplit(phaseData.NMVwl_ph{t}); % nonmatches split by whitespace
                        if ~isempty(matches{1})
                            for m = 1:length(matches)
                                if strcmp(vowel, matches{1,m})
                                    match = match + 1;
                                end
                            end
                        end
                        if ~isempty(nonmatches{1})
                            for n = 1:length(nonmatches)
                                if strcmp(vowel, nonmatches{1,n})
                                    nonmatch = nonmatch + 1;
                                end
                            end
                        end
                        clear matches nonmatches;
                    end

                    speakers{count}      = speaker;
                    listeners(count)     = listener;
                    conds{count}         = cond;
                    if strcmp(phase, 'baseline2')
                        phases{count}    = 'baseline2';
                    else
                        phases{count}    = 'hold6'; % for precision (later)
                    end
                    vowels{count}        = vowel_fieldnames{v};
                    firstSessions(count) = phaseData.FirstSession(1);
                    nMatches(count)      = match;
                    nNonmatches(count)   = nonmatch;
                    percs(count)         = match / (match + nonmatch); % percent matches

                    count = count + 1;
                end
            end
        end
    end
end
clear phaseData;

senPercAcc_byVowel = table(speakers', listeners', conds', phases', vowels', firstSessions', nMatches', nNonmatches', percs', ...
    'VariableNames', ["speaker", "listener", "cond", "phase", "vow", "firstSession", "nMatch", "nNonmatch", "perc"]);

clear speakers listeners conds phases vowels firstSessions;

% -----------------------------------------------------------
% Calculate gain in accuracy by vowel (doesn't include phase)
% -----------------------------------------------------------

count = 1;

speakers2Analyze = unique(senPercAcc_byVowel.speaker);

for s = 1:length(speakers2Analyze) % for each speaker

    speaker = speakers2Analyze{s};
    speakerData = senPercAcc_byVowel(strcmp(senPercAcc_byVowel.speaker, speaker),:);
    listeners2Analyze = unique(speakerData.listener);

    for i = 1:length(listeners2Analyze) % for each listener of that speaker

        listener = listeners2Analyze(i);
        listenerData = speakerData(speakerData.listener == listener,:);
        conds2Analyze = unique(listenerData.cond); % adapt/null

        for c = 1:length(conds2Analyze) % for each cond/session

            cond = conds2Analyze{c};
            condData = listenerData(strcmp(listenerData.cond, cond),:);
            vowels2Analyze = unique(condData.vow); % ARPAbet

            for v = 1:length(vowels2Analyze) % for each vowel

                vowel = vowels2Analyze{v};
                vowelData = condData(strcmp(condData.vow, vowel),:);
                phases2Analyze = unique(vowelData.phase); % baseline2/hold

                for p = 1:length(phases2Analyze) % for each phase

                    phase = phases2Analyze{p};
                    phaseData(p) = vowelData(strcmp(vowelData.phase, phase),:).perc;
                end

                speakers{count}      = speaker;
                listeners(count)     = listener;
                conds{count}         = cond;
                vows{count}          = vowel;
                firstSessions(count) = condData.firstSession(1);
                gains(count)         = phaseData(2) - phaseData(1); % percentage-point gain from baseline to adpated

                count = count + 1;
                clear phaseData;
            end
        end
    end
end

senGain_byVowel = table(speakers', listeners', conds', vows', firstSessions', gains', ...
    'VariableNames', ["speaker", "listener", "cond", "vow", "firstSession", "gain"]);

save(saveFile, 'senPercAcc_bySpeaker', 'senPercAcc_byListener', 'senPercAcc_byVowel', 'senGain_byVowel');
fprintf('Saved %s\n', saveFile);

end
