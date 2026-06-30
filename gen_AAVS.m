function [AAVS] = gen_AAVS(dataPaths)
% Articulatory-acoustic vowel space for vsaSentence.

% --- check for existing output file before saving ---
saveName = strcat('aavs_', num2str(length(dataPaths)), '.mat');
outPath = get_exptLoadPath('vsaSentence');
saveFile = fullfile(outPath, saveName);
bSave = savecheck(saveFile);
if ~bSave, return; end

conds  = {'adapt', 'null'};
phases = {'baseline1', 'baseline2', 'ramp', 'hold1', 'hold2', 'hold3', 'hold4', 'hold5', 'hold6', 'washout', 'retention'};

AAVS = get_AAVS(dataPaths, conds, phases);

% --- add session order ---
load(fullfile(outPath, 'speakerData.mat'), 'speakerData');
adaptFirst = nan(height(AAVS),1);
for s = 1:length(dataPaths)
    [~, speaker] = fileparts(dataPaths{s});
    a = speakerData(strcmp(speakerData.speaker, speaker),:).adaptFirst;
    for t = 1:height(AAVS)
        if AAVS.subj(t) == s
            adaptFirst(t) = a;
        end
    end
end
AAVS = addvars(AAVS, adaptFirst);

% --- normalize AAVS to its within-session baseline2 ---
aavsNormWithinSession = nan(height(AAVS),1);
for s = 1:length(dataPaths)
    for c = 1:length(conds)
        cond = conds{c};
        myBase = AAVS((AAVS.subj==s) & (strcmp(AAVS.cond, cond)) & (strcmp(AAVS.phase, 'baseline2')),:).aavs; % denominator
        for p = 1:length(phases)
            phase = phases{p};
            myVal = AAVS((AAVS.subj==s) & (strcmp(AAVS.cond, cond)) & (strcmp(AAVS.phase, phase)),:).aavs; % numerator
            aavsNormWithinSession((AAVS.subj==s) & (strcmp(AAVS.cond, cond)) & (strcmp(AAVS.phase, phase))) = myVal / myBase;
        end
    end
end
AAVS = addvars(AAVS, aavsNormWithinSession);

% --- normalize AAVS to the first session's baseline2 ---
aavsNormFirstSession = nan(height(AAVS),1); 
for s = 1:length(dataPaths)
    if AAVS((AAVS.subj==s) & (strcmp(AAVS.cond, 'adapt')) & (strcmp(AAVS.phase, 'baseline2')),:).adaptFirst == 1
        myBase = AAVS((AAVS.subj==s) & (strcmp(AAVS.cond, 'adapt')) & (strcmp(AAVS.phase, 'baseline2')),:).aavs; % denominator
    else
        myBase = AAVS((AAVS.subj==s) & (strcmp(AAVS.cond, 'null')) & (strcmp(AAVS.phase, 'baseline2')),:).aavs; % denominator
    end
    for c = 1:length(conds)
        cond = conds{c};
        for p = 1:length(phases)
            phase = phases{p};
            myVal = AAVS((AAVS.subj==s) & (strcmp(AAVS.cond, cond)) & (strcmp(AAVS.phase, phase)),:).aavs; % numerator
            aavsNormFirstSession((AAVS.subj==s) & (strcmp(AAVS.cond, cond)) & (strcmp(AAVS.phase, phase))) = myVal / myBase;
        end
    end
end
AAVS = addvars(AAVS, aavsNormFirstSession);

AAVS = movevars(AAVS, 'aavs', 'Before', 'aavsNormWithinSession');

save(saveFile, 'AAVS');
fprintf('Saved %s\n', saveFile);

end
