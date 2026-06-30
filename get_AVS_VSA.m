function [AVS_VSA] = get_AVS_VSA(sentenceVow, transferVow)
% Calculates global vowel-space measures from trialwise formants (in mels).

% experimental design
sentencePhases = {'baseline1', 'baseline2', 'ramp', 'hold1', 'hold2', 'hold3', 'hold4', 'hold5', 'hold6', 'washout', 'retention'};
transferPhases = {'transfer1', 'transfer2', 'transfer3'};
sentenceVowels = {'IY','IH','EH','AE','AA','AH','OW','UW','EY','UH','ER','AO','AW','AY'}; % n = 14
transferVowels = {'IY','IH','EH','AE','AA','AH','OW','UW','EY','UH'}; % n = 10
conds          = {'adapt', 'null'};

% calculate mean over trials, preserving groupings
sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
tV = groupsummary(transferVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");

count = 1;

for p = 1:length(sentencePhases)
    phase = sentencePhases{p};
    pData = sV(strcmp(sV.phase, phase),:);
    for s = 1:length(unique(sV.subj))
        sData = pData(pData.subj == s,:);
        for c = 1:length(conds)
            cond = conds{c};
            cData = sData(strcmp(sData.cond, cond),:);
            for v = 1:length(sentenceVowels)
                vow = sentenceVowels{v};
                vData = cData(strcmp(cData.vow, vow),:);
                vD.f1.(lower(vow)) = vData.mean_f1; % input to calc_AVS and calc_VSA
                vD.f2.(lower(vow)) = vData.mean_f2;
            end
            subj_(count)                 = s;
            cond_{count}                 = cond;
            phase_{count}                = phase;
            adaptFirst_(count)           = sData.adaptFirst(1);
            avs_(count)                  = calc_AVS(vD); % currently only works on mean over trials
            [vsa4_(count), vsa3_(count)] = calc_VSA(vD); % currently only works on mean over trials
            count = count + 1;
        end
    end
end

for p = 1:length(transferPhases)
    phase = transferPhases{p};
    pData = tV(strcmp(tV.phase, phase),:);
    for s = 1:length(unique(tV.subj))
        sData = pData(pData.subj == s,:);
        for c = 1:length(conds)
            cond = conds{c};
            cData = sData(strcmp(sData.cond, cond),:);
            for v = 1:length(transferVowels)
                vow = transferVowels{v};
                vData = cData(strcmp(cData.vow, vow),:);
                vD.f1.(lower(vow)) = vData.mean_f1; % input to calc_AVS and calc_VSA
                vD.f2.(lower(vow)) = vData.mean_f2;
            end
            subj_(count)                 = s;
            cond_{count}                 = cond;
            phase_{count}                = phase;
            adaptFirst_(count)           = sData.adaptFirst(1);
            avs_(count)                  = calc_AVS(vD); % currently only works on mean over trials
            [vsa4_(count), vsa3_(count)] = calc_VSA(vD); % currently only works on mean over trials
            count = count + 1;
        end
    end
end
 
AVS_VSA = table(subj_', cond_', phase_', adaptFirst_', avs_', vsa4_', vsa3_', 'VariableNames', {'subj', 'cond', 'phase', 'adaptFirst', 'avs', 'vsa4', 'vsa3'});

end
