function [AVS_VSA] = gen_AVS_VSA(sentenceVow, transferVow)
% Average vowel spacing and vowel space area for vsaSentence

outPath = get_exptLoadPath('vsaSentence');

AVS_VSA = get_AVS_VSA(sentenceVow, transferVow);

AVS_VSA_sentence = AVS_VSA(~contains(AVS_VSA.phase, 'transfer'),:); 
AVS_VSA_transfer = AVS_VSA(contains(AVS_VSA.phase, 'transfer'),:);

% --- normalize sentence to within-session baseline2 ---
T = AVS_VSA_sentence;
subjs = unique(T.subj);
conds = unique(T.cond);
phases = unique(T.phase);
avsNormWithinSession  = nan(height(T),1);
vsa4NormWithinSession = nan(height(T),1);
vsa3NormWithinSession = nan(height(T),1); 
for s = 1:length(subjs)
    subj = subjs(s);
    for c = 1:length(conds)
        cond = conds{c};
        avsBase  = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, 'baseline2')),:).avs;  % denominator
        vsa4Base = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, 'baseline2')),:).vsa4; % denominator
        vsa3Base = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, 'baseline2')),:).vsa3; % denominator
        for p = 1:length(phases)
            phase = phases{p};
            avsVal  = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).avs;  % numerator
            vsa4Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa4; % numerator
            vsa3Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa3; % numerator
            avsNormWithinSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)))  = avsVal  / avsBase;
            vsa4NormWithinSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa4Val / vsa4Base;
            vsa3NormWithinSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa3Val / vsa3Base;
        end
    end
end
T = addvars(T, avsNormWithinSession, vsa4NormWithinSession, vsa3NormWithinSession);
AVS_VSA_sentence = T;

% --- normalize transfer to within-session transfer2 ---
T = AVS_VSA_transfer;
subjs = unique(T.subj);
conds = unique(T.cond);
phases = unique(T.phase);
avsNormWithinSession  = nan(height(T),1);
vsa4NormWithinSession = nan(height(T),1);
vsa3NormWithinSession = nan(height(T),1); 
for s = 1:length(subjs)
    subj = subjs(s);
    for c = 1:length(conds)
        cond = conds{c};
        avsBase  = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, 'transfer2')),:).avs;  % denominator
        vsa4Base = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, 'transfer2')),:).vsa4; % denominator
        vsa3Base = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, 'transfer2')),:).vsa3; % denominator
        for p = 1:length(phases)
            phase = phases{p};
            avsVal  = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).avs;  % numerator
            vsa4Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa4; % numerator
            vsa3Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa3; % numerator
            avsNormWithinSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)))  = avsVal  / avsBase;
            vsa4NormWithinSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa4Val / vsa4Base;
            vsa3NormWithinSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa3Val / vsa3Base;
        end
    end
end
T = addvars(T, avsNormWithinSession, vsa4NormWithinSession, vsa3NormWithinSession);
AVS_VSA_transfer = T;

% --- normalize sentence to first-session baseline2 ---
T = AVS_VSA_sentence;
subjs = unique(T.subj);
conds = unique(T.cond);
phases = unique(T.phase);
avsNormFirstSession  = nan(height(T),1);
vsa4NormFirstSession = nan(height(T),1);
vsa3NormFirstSession = nan(height(T),1);
for s = 1:length(subjs)
    subj = subjs(s);
    if T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'baseline2')),:).adaptFirst == 1
        avsBase  = T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'baseline2')),:).avs;  % denominator
        vsa4Base = T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'baseline2')),:).vsa4; % denominator
        vsa3Base = T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'baseline2')),:).vsa3; % denominator
    else
        avsBase  = T((T.subj==subj) & (strcmp(T.cond, 'null')) & (strcmp(T.phase, 'baseline2')),:).avs;  % denominator
        vsa4Base = T((T.subj==subj) & (strcmp(T.cond, 'null')) & (strcmp(T.phase, 'baseline2')),:).vsa4; % denominator
        vsa3Base = T((T.subj==subj) & (strcmp(T.cond, 'null')) & (strcmp(T.phase, 'baseline2')),:).vsa3; % denominator
    end
    for c = 1:length(conds)
        cond = conds{c};
        for p = 1:length(phases)
            phase = phases{p};
            avsVal  = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).avs;  % numerator
            vsa4Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa4; % numerator
            vsa3Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa3; % numerator
            avsNormFirstSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)))  = avsVal  / avsBase;
            vsa4NormFirstSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa4Val / vsa4Base;
            vsa3NormFirstSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa3Val / vsa3Base;
        end
    end
end
T = addvars(T, avsNormFirstSession, vsa4NormFirstSession, vsa3NormFirstSession);
AVS_VSA_sentence = T;

% --- normalize transfer to first-session transfer2 ---
T = AVS_VSA_transfer;
subjs = unique(T.subj);
conds = unique(T.cond);
phases = unique(T.phase);
avsNormFirstSession  = nan(height(T),1);
vsa4NormFirstSession = nan(height(T),1);
vsa3NormFirstSession = nan(height(T),1);
for s = 1:length(subjs)
    subj = subjs(s);
    if T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'transfer2')),:).adaptFirst == 1
        avsBase  = T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'transfer2')),:).avs;  % denominator
        vsa4Base = T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'transfer2')),:).vsa4; % denominator
        vsa3Base = T((T.subj==subj) & (strcmp(T.cond, 'adapt')) & (strcmp(T.phase, 'transfer2')),:).vsa3; % denominator
    else
        avsBase  = T((T.subj==subj) & (strcmp(T.cond, 'null')) & (strcmp(T.phase, 'transfer2')),:).avs;  % denominator
        vsa4Base = T((T.subj==subj) & (strcmp(T.cond, 'null')) & (strcmp(T.phase, 'transfer2')),:).vsa4; % denominator
        vsa3Base = T((T.subj==subj) & (strcmp(T.cond, 'null')) & (strcmp(T.phase, 'transfer2')),:).vsa3; % denominator
    end
    for c = 1:length(conds)
        cond = conds{c};
        for p = 1:length(phases)
            phase = phases{p};
            avsVal  = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).avs;  % numerator
            vsa4Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa4; % numerator
            vsa3Val = T((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)),:).vsa3; % numerator
            avsNormFirstSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase)))  = avsVal  / avsBase;
            vsa4NormFirstSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa4Val / vsa4Base;
            vsa3NormFirstSession((T.subj==subj) & (strcmp(T.cond, cond)) & (strcmp(T.phase, phase))) = vsa3Val / vsa3Base;
        end
    end
end
T = addvars(T, avsNormFirstSession, vsa4NormFirstSession, vsa3NormFirstSession);
AVS_VSA_transfer = T;

AVS_VSA = [AVS_VSA_sentence; AVS_VSA_transfer];

saveFile = fullfile(outPath, sprintf('avs_vsa_%d.mat', s));
save(saveFile, 'AVS_VSA');
fprintf('Saved %s\n', saveFile);

end
