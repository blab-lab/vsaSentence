function [AAVS] = get_AAVS(dataPaths, conds, phases)
% Calculates AAVS over _all_ phases of vsaSentence.

% experimental design
nSentences = 40;

fprintf('Adding data from folder');
count = 1;
for s = 1:length(dataPaths)
    fprintf(' %d', s);

    for c = 1:length(conds)
        cond = conds{c};
        
        dataPath = fullfile(dataPaths{s}, cond);        
        load(fullfile(dataPath, 'expt.mat'), 'expt');
        if isfile(fullfile(dataPath, 'dataVals_sentences.mat'))
            load(fullfile(dataPath, 'dataVals_sentences.mat'), 'dataVals');
            disp(' used dataVals_sentences');
        else
            load(fullfile(dataPath, 'dataVals.mat'), 'dataVals');
        end  

        for p = 1:length(phases)
            phase = phases{p};

            if strcmp(phase, 'hold1')
                startTrial = nSentences*(1-1)+1;
                endTrial = nSentences*1;
                inds = expt.inds.conds.hold(startTrial:endTrial); 
            elseif strcmp(phase, 'hold2')
                startTrial = nSentences*(2-1)+1;
                endTrial = nSentences*2;
                inds = expt.inds.conds.hold(startTrial:endTrial);
            elseif strcmp(phase, 'hold3')
                startTrial = nSentences*(3-1)+1;
                endTrial = nSentences*3;
                inds = expt.inds.conds.hold(startTrial:endTrial);
            elseif strcmp(phase, 'hold4')
                startTrial = nSentences*(4-1)+1;
                endTrial = nSentences*4;
                inds = expt.inds.conds.hold(startTrial:endTrial);
            elseif strcmp(phase, 'hold5')
                startTrial = nSentences*(5-1)+1;
                endTrial = nSentences*5;
                inds = expt.inds.conds.hold(startTrial:endTrial);
            elseif strcmp(phase, 'hold6')
                startTrial = nSentences*(6-1)+1;
                endTrial = nSentences*6;
                inds = expt.inds.conds.hold(startTrial:endTrial);
            else
                inds = expt.inds.conds.(phase);
            end
    
            fmtMatrix = gen_concatenated_formants(dataVals, inds);
            fmtMatrix = rmoutliers(fmtMatrix);
            aavs = calc_AAVS(fmtMatrix);

            subj_(count)  = s;
            cond_{count}  = cond;
            phase_{count} = phase;
            aavs_(count)  = aavs;
            count = count + 1;
        end
    end
end

AAVS = table(subj_', cond_', phase_', aavs_', 'VariableNames', {'subj', 'cond', 'phase', 'aavs'});

end


        