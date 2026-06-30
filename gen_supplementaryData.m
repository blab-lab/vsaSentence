function gen_supplementaryData(dataPaths)
% For vsaSentence; based on calc_avsStats for Fig S2 in J Neurophys 2021.

if isempty(dataPaths); dataPaths = get_dataPaths_vsaSentence; end

nSubj = length(dataPaths);

% --- check for existing output files before saving ---
saveNameSen = strcat('supplementaryData_sentence_', num2str(nSubj), '.mat');
saveNameTra = strcat('supplementaryData_transfer_', num2str(nSubj), '.mat');
outPath = get_exptLoadPath('vsaSentence');
saveFileSen = fullfile(outPath, saveNameSen);
saveFileTra = fullfile(outPath, saveNameTra);
bSave = savecheck(saveFileSen);
if ~bSave, return; end
bSave = savecheck(saveFileTra);
if ~bSave, return; end

% --- Sentence ---
n = 440; % trials

durations.adapt       = nan(nSubj,n);
durations.control     = nan(nSubj,n);
intensityMax.adapt    = nan(nSubj,n);
intensityMax.control  = nan(nSubj,n);
intensityMean.adapt   = nan(nSubj,n);
intensityMean.control = nan(nSubj,n);
f0Max.adapt           = nan(nSubj,n);
f0Max.control         = nan(nSubj,n);
f0Mean.adapt          = nan(nSubj,n);
f0Mean.control        = nan(nSubj,n);
f0Range.adapt         = nan(nSubj,n);
f0Range.control       = nan(nSubj,n);

condFileNames = {'adapt','null'};
condNames = {'adapt','control'};
nConds = length(condNames);

for dP = 1:length(dataPaths)
    fprintf('processing participant %d\n',dP)
    for c = 1:nConds
        condName = condNames{c};
        fprintf('\tprocessing condition %s\n',condName)
        condFileName = condFileNames{c};
        dataPath = fullfile(dataPaths{dP},condFileName);
        load(fullfile(dataPath,'dataVals_sentences.mat'))
        %add Nans for excluded trials
        bExcl = find([dataVals(:).bExcl]);
        for t = bExcl
            dataVals(t).dur = NaN;
            dataVals(t).int = NaN;
            dataVals(t).f0  = NaN;
        end
        tempIntMax  = [];
        tempIntMean = [];
        tempf0Max   = [];
        tempf0Mean  = [];
        tempf0Range = [];
        tempDur     = [];
        for t = 1:length(dataVals)
            % from get_duration: if multi-segment    
            a = ~strcmp(dataVals(t).segment, 'sil'); 
            b = ~strcmp(dataVals(t).segment, 'sp');
            onsetSegment = find((a+b)==2, 1); % the first phone that's not SILENCE or SHORT PAUSE
            offsetSegment = find((a+b)==2, 1, 'last'); % the last phone that's not SILENCE or SHORT PAUSE
            if ~isempty(dataVals(t).ampl_taxis)
                while isempty(dataVals(t).ampl_taxis{onsetSegment}); onsetSegment = onsetSegment + 1; end % go forward in time to where there's data (weirdness in s1)
                while isempty(dataVals(t).ampl_taxis{offsetSegment}); offsetSegment = offsetSegment - 1; end % go back in time to where there's data   
                onset_time = dataVals(t).ampl_taxis{onsetSegment}(1);
                offset_time = dataVals(t).ampl_taxis{offsetSegment}(end);            
                duration = offset_time - onset_time;
                intensity = [];
                f0 = [];
                for i = onsetSegment:offsetSegment
                    intensity = [intensity dataVals(t).int{i}'];
                    f0        = [f0 dataVals(t).f0{i}'];
                end
            else
                duration = NaN;
                intensity = NaN;
                f0 = NaN;
            end
            tempDur(t)     = duration;
            tempIntMax(t)  = max(intensity);
            tempIntMean(t) = nanmean(intensity);
            tempf0Max(t)   = max(f0);
            tempf0Mean(t)  = mean(f0);
            tempf0Range(t) = range(f0);
        end
        durations.(condName)(dP,1:n)     = tempDur;
        intensityMax.(condName)(dP,1:n)  = tempIntMax;
        intensityMean.(condName)(dP,1:n) = tempIntMean;
        f0Max.(condName)(dP,1:n)         = tempf0Max;
        f0Mean.(condName)(dP,1:n)        = tempf0Mean;
        f0Range.(condName)(dP,1:n)       = tempf0Range;
    end
end

save(saveFileSen, 'durations', 'intensityMax', 'intensityMean', 'f0Max', 'f0Mean', 'f0Range');
fprintf('Saved %s\n', saveFileSen);

% --- Transfer ---
n = 150; % trials

durations.adapt       = nan(nSubj,n);
durations.control     = nan(nSubj,n);
intensityMax.adapt    = nan(nSubj,n);
intensityMax.control  = nan(nSubj,n);
intensityMean.adapt   = nan(nSubj,n);
intensityMean.control = nan(nSubj,n);
f0Max.adapt           = nan(nSubj,n);
f0Max.control         = nan(nSubj,n);
f0Mean.adapt          = nan(nSubj,n);
f0Mean.control        = nan(nSubj,n);
f0Range.adapt         = nan(nSubj,n);
f0Range.control       = nan(nSubj,n);

condFileNames = {'adapt','null'};
condNames = {'adapt','control'};
nConds = length(condNames);
for dP = 1:length(dataPaths)
    fprintf('processing participant %d\n',dP)
    for c = 1:nConds
        condName = condNames{c};
        fprintf('\tprocessing condition %s\n',condName)
        condFileName = condFileNames{c};
        dataPath = fullfile(dataPaths{dP},condFileName);
        load(fullfile(dataPath,'dataVals_transfer.mat'))
        %iTri = [dataVals(:).token];
        iTri = 1:n; % Sara
        if dP==25 && c==1; dataVals(1:3) = []; end % remove extra trials
        %add Nans for excluded trials
        bExcl = find([dataVals(:).bExcl]);
        for t = bExcl
            dataVals(t).dur = NaN;
            dataVals(t).int = NaN;
            dataVals(t).f0 = NaN;
        end
        % deal with weird trial(s)
        weird = find([dataVals(:).dur] < 0);
        for t = weird
            dataVals(t).dur = NaN;
            dataVals(t).int = NaN;
            dataVals(t).f0 = NaN;
        end
        %get durations
        durations.(condName)(dP,iTri) = [dataVals(:).dur];
        %calculate max intensity for each trial
        tempIntMax = [];
        tempIntMean = [];
        tempf0Max = [];
        tempf0Mean = [];
        tempf0Range = [];
        for t = 1:length(dataVals)
            tempIntMax(t)  = max(dataVals(t).int);
            tempIntMean(t) = nanmean(dataVals(t).int);
            tempf0Max(t)   = max(dataVals(t).f0);
            tempf0Mean(t)  = mean(dataVals(t).f0);
            tempf0Range(t) = range(dataVals(t).f0);
        end
        intensityMax.(condName)(dP,iTri) = tempIntMax;
        intensityMean.(condName)(dP,iTri) = tempIntMean;
        f0Max.(condName)(dP,iTri) = tempf0Max;
        f0Mean.(condName)(dP,iTri) = tempf0Mean;
        f0Range.(condName)(dP,iTri) = tempf0Range;
    end
end

save(saveFileTra, 'durations', 'intensityMax', 'intensityMean', 'f0Max', 'f0Mean', 'f0Range');
fprintf('Saved %s\n', saveFileTra);

end
