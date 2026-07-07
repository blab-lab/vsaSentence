function [T] = gen_segmentDuration_dataTable(dataPaths, isTransfer)
% Go through trials in adapt and null sessions, grab all segment durations, 
% and make a dataTable. Does _all_ phases of the vsaSentence experiment.

if nargin < 1 || isempty(dataPaths), dataPaths = get_dataPaths_vsaSentence; end
if nargin < 2 || isempty(isTransfer), isTransfer = 1; end

% check for existing output file before saving
if isTransfer
    saveName = strcat('segmentDuration_transfer_', num2str(length(dataPaths)), '.mat');
else
    saveName = strcat('segmentDuration_sentence', num2str(length(dataPaths)), '.mat');
end
outPath = get_exptLoadPath('vsaSentence');
saveFile = fullfile(outPath, saveName);
bSave = savecheck(saveFile);
if ~bSave, return; end
fprintf('Output path: %s\n', outPath);

% check for existing speakerData file (to get speakers' session orders)
loadFile = fullfile(outPath, 'speakerData.mat');
if ~isfile(loadFile)
    fprintf('speakerData.mat is missing; you must run gen_speakerData before this function. \n');
    return;
end
load(loadFile, 'speakerData');

nSubs = length(dataPaths);
conds = {'adapt','null'};
nConds = length(conds);

%%concatenate matrices
fprintf('Adding data from folder');
stab = cell(1,nSubs);
for s=1:nSubs %for each subject
   fprintf(' %d\n',s);
   dataPath = dataPaths{s};
   ctab = cell(1,nConds);
   for c=1:nConds %for each session
        cond = conds{c};
        %get data
        dataPath_session = fullfile(dataPath,cond);
        load(fullfile(dataPath_session,'expt.mat'),'expt');
        % define trial indices for each phase for averaging
        if isTransfer
            phaseInds.transfer2 = expt.inds.conds.transfer2; % baseline
            phaseInds.transfer3 = expt.inds.conds.transfer3; % adapted
        else
            % NOTE: This set of phases (expt.conds values) is also set in
            % get_speakerData_vsaPD, get_AVS_VSA_PD, gen_AAVS_vsaPD, gen_vowelSegment_dataTable_vsaPD
            phaseInds.baseline2 = expt.inds.conds.baseline2; % baseline
            phaseInds.ramp      = expt.inds.conds.ramp;
            phaseInds.hold1     = expt.inds.conds.hold(1:40);
            phaseInds.hold2     = expt.inds.conds.hold(41:80);
            phaseInds.hold3     = expt.inds.conds.hold(81:120);
            phaseInds.hold4     = expt.inds.conds.hold(121:160);
            phaseInds.hold5     = expt.inds.conds.hold(161:200);
            phaseInds.hold6     = expt.inds.conds.hold(end-39:end); % adapted      
            phaseInds.washout   = expt.inds.conds.washout;
            phaseInds.retention = expt.inds.conds.retention;
            phaseInds.baseline1 = expt.inds.conds.baseline1;
        end
        phases = fieldnames(phaseInds);
        nPhases = length(phases);       
        ptab = cell(1,nPhases);

        for p=1:nPhases %for each phase
            phase = phases{p};
            dataBySegment = get_dataBySegment(dataPath_session, [], [phaseInds.(phase)], isTransfer);
            vowels = fieldnames(dataBySegment);
            vtab = cell(1,length(vowels));
            for v=1:length(vowels)
                vow = vowels{v};
                analyses = fieldnames(dataBySegment.(vow));
                for a=1:length(analyses)
                    anl = analyses{a};
                    dat.(anl) = [dataBySegment.(vow).(anl)]';
                end
                                           
                fact.subj = s;
                fact.cond = cond;
                fact.phase = phase;
                fact.vow = vow;

                [~, sp] = fileparts(dataPath);
                fact.speaker = sp;
                if speakerData(strcmp(speakerData.speaker, sp),:).adaptFirst == 1
                    fact.adaptFirst = 1;
                else
                    fact.adaptFirst = 0;
                end
              
                vtab{v} = get_datatable(dat,fact);
                clear dat;
            end
            ptab{p} = vertcat(vtab{:});
        end
        ctab{c} = vertcat(ptab{:});
   end
   stab{s} = vertcat(ctab{:});
end
T = vertcat(stab{:});

% normalize

if isTransfer

    T = T(strcmp(T.phase, 'transfer2') | strcmp(T.phase, 'transfer3'),:);
    T = groupsummary(T, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    
    speakers = unique(T.speaker);
    vowels = unique(T.vow);
    conds = unique(T.cond);
    
    % --- normalize sentence to within-session baseline2 ---
    T.durNormWithinSession = T.mean_dur;
    for s = 1:length(speakers)
        speaker = speakers{s};
        for v = 1:length(vowels)
            vowel = vowels{v};
            for c = 1:length(conds)
                cond = conds{c};
                base = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'transfer2'),:).mean_dur;
                val = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'transfer3'),:).mean_dur;
                T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'transfer3'),:).durNormWithinSession = val - base;
            end
        end
    end
    
    % --- normalize sentence to first-session baseline2 ---
    T.durNormFirstSession = T.mean_dur;
    for s = 1:length(speakers)
        speaker = speakers{s};
        for v = 1:length(vowels)
            vowel = vowels{v};
            for c = 1:length(conds)
                cond = conds{c};
                if T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'transfer2'),:).adaptFirst == 1
                    base = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, 'adapt') & strcmp(T.phase, 'transfer2'),:).mean_dur;
                else
                    base = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, 'null') & strcmp(T.phase, 'transfer2'),:).mean_dur;
                end
                val = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'transfer3'),:).mean_dur;
                T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'transfer3'),:).durNormFirstSession = val - base;
            end
        end
    end
    T(strcmp(T.phase, 'transfer2'),:) = [];
    tra = T;
    save('\\wcs-cifs\wc\smng\experiments\vsaSentence\segmentDuration_transfer_41.mat', 'tra'); % Don't have consonants because it wasn't done w MFA.

else

    T = T(strcmp(T.phase, 'baseline2') | strcmp(T.phase, 'hold6'),:);
    T = groupsummary(T, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    
    speakers = unique(T.speaker);
    vowels = unique(T.vow);
    conds = unique(T.cond);
    
    % --- normalize sentence to within-session baseline2 ---
    T.durNormWithinSession = T.mean_dur;
    for s = 1:length(speakers)
        speaker = speakers{s};
        for v = 1:length(vowels)
            vowel = vowels{v};
            for c = 1:length(conds)
                cond = conds{c};
                base = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'baseline2'),:).mean_dur;
                val = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'hold6'),:).mean_dur;
                T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'hold6'),:).durNormWithinSession = val - base;
            end
        end
    end
    
    % --- normalize sentence to first-session baseline2 ---
    T.durNormFirstSession = T.mean_dur;
    for s = 1:length(speakers)
        speaker = speakers{s};
        for v = 1:length(vowels)
            vowel = vowels{v};
            for c = 1:length(conds)
                cond = conds{c};
                if T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'baseline2'),:).adaptFirst == 1
                    base = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, 'adapt') & strcmp(T.phase, 'baseline2'),:).mean_dur;
                else
                    base = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, 'null') & strcmp(T.phase, 'baseline2'),:).mean_dur;
                end
                val = T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'hold6'),:).mean_dur;
                T(strcmp(T.speaker, speaker) & strcmp(T.vow, vowel) & strcmp(T.cond, cond) & strcmp(T.phase, 'hold6'),:).durNormFirstSession = val - base;
            end
        end
    end
    T(strcmp(T.phase, 'baseline2'),:) = [];
    sen = T;
    save('\\wcs-cifs\wc\smng\experiments\vsaSentence\segmentDuration_sentence_41.mat', 'sen');

end
end

% -------------------------------------------------------------------------

function [dataBySegment] = get_dataBySegment(dataPath,dataValsStr,trials,isTransfer)

if nargin < 2 || isempty(dataValsStr), dataValsStr = 'dataVals.mat'; end
if nargin < 3 || isempty(trials), trials = []; end
if nargin < 4 || isempty(isTransfer), isTransfer = 0; end

if isfile(fullfile(dataPath,'dataVals_sentences.mat')) && isTransfer==0
    load(fullfile(dataPath,'dataVals_sentences.mat'),'dataVals')
elseif isTransfer
    load(fullfile(dataPath,'dataVals_transfer.mat'),'dataVals')
else
    load(fullfile(dataPath,dataValsStr),'dataVals')
end
vowel_lookup = {'IY','IH','EH','AE','AA','AH','OW','UW','EY','UH','ER','AO','AW','AY','OY', ...
    'B', 'CH', 'D', 'DH', 'DX', 'EL', 'EM', 'EN', 'F', 'G', 'HH', 'JH', 'K', 'L', ...
    'M', 'N', 'NG', 'NX', 'P', 'Q', 'R', 'S', 'SH', 'T', 'TH', 'V', 'W', 'WH', 'Y', 'Z', 'ZH'};
% buy, China, die, thy, butter, bottle, rhythm, button, fight, guy, high, jive, kite, lie,
% my, nigh, sing, winter, pie, uh-oh, rye, sigh, shy, tie, thigh, vie, wise, why, yacht, zoo, pleasure
dataBySegment = struct();
token = [dataVals.token];
for t=1:length(trials)
    trial=trials(t);
    lookup = find(token == trial);
    if ~isempty(lookup)
        for s=1:length(dataVals(lookup).segment) %look at number of segments
            for v=1:length(vowel_lookup) %go through list of vowels
                vow = vowel_lookup{v};
                if strcmp(vow, dataVals(lookup).segment{s})==1
                    if isfield(dataBySegment, vow)
                        line = length(dataBySegment.(vow))+1;
                    else
                        line = 1;
                    end
                    if isTransfer
                        if isnan(dataVals(lookup).dur); break; end
                        dataBySegment.(vow)(line).dur = dataVals(lookup).dur;
                    else
                        if isnan(dataVals(lookup).dur{s}); break; end
                        dataBySegment.(vow)(line).dur = dataVals(lookup).dur{s};
                    end
                end
            end
        end
    end
end
end
