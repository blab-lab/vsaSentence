function expt = run_vsaSentence_expt(expt,bTestMode)
%RUN_VSASENTENCE_EXPT  Run VSA pilot adaptation experiment.
%   RUN_VSASENTENCE_EXPT(EXPT,BTESTMODE)

if nargin < 1, expt = []; end
if nargin < 2 || isempty(bTestMode), bTestMode = 0; end

%% establish folder and group
expt.name = 'vsaSentence';
expt.bTestMode = bTestMode;
expt.trackingFileLoc = 'experiment_helpers'; % Where the OST/PCF files are kept (for audapter_viewer)
expt.trackingFileName = 'measureFormants'; % What the files are called
if ~isfield(expt,'snum'), expt.snum = get_snum; end
if ~isfield(expt,'gender'), expt.gender = get_gender; end

% assign participant to group
subjPath = get_acoustSavePath(expt.name,expt.snum);
groups = {'adapt','null'};
if ~isfield(expt,'group')
    %[expt.group,expt.groupnum] = get_sgroup(subjPath,groups);
    unusedGroups = get_unusedDirs(subjPath,groups);
    if isempty(unusedGroups)
        group = input('All groups already exist as folders for this subject! Please enter a group name: ', 's');
        expt.group = check_sgroup(group, groups); % check that group is valid
        expt.groupnum = find(strcmp(expt.group,groups));
    elseif length(unusedGroups) == 1
        expt.group = unusedGroups{1};
        expt.groupnum = find(strcmp(expt.group,groups));
    else

        % NOTE: This method of counterbalancing is no longer recommended.
        % Search the KB for "counterbalancing" or go to https://kb.wisc.edu/smng/148239
        permsPath = '\\wcs-cifs\wc\smng\experiments\vsaSentence\';     
        if exist(permsPath,'dir')
            [permIx,groupsInOrder] = get_cbPermutation(expt.name, permsPath); % get the words and their index
            if ~bTestMode && ~any(strfind(expt.snum, 'pilot')) && ~any(strfind(expt.snum,'test')) % if "test" or "pilot" in pp name, not a real pp
                set_cbPermutation(expt.name, permIx, permsPath);
            end
        else % If the server is down for some reason
            permIx = randi(2);
            % Then use a local copy of the permutations (counts do not have to be up to date, you just want the
            % just need order of conditions) 
            localPermsPath = 'C:\Users\Public\Documents\software\current-studies\vowel_space\vsaSentence';
            [~,groupsInOrder] = get_cbPermutation(expt.name, localPermsPath, [], permIx); 
            fprintf(fid,'Server did not respond. Random permIx generated: %d', permIx); 
        end
    expt.group = groupsInOrder{1};
    expt.groupnum = find(strcmp(expt.group,groups));
    expt.permIx = permIx;
    end
end
expt.dataPath = fullfile(subjPath,expt.group);

%% stimuli
exptpre = expt;
expt.conds = {'baseline1' 'transfer1' 'baseline2' 'transfer2' 'ramp' 'hold' 'transfer3' 'washout' 'retention'};
expt.stimulusText = readcell('\\wcs-cifs\wc\smng\experiments\vsaSentence\hsList.xlsx');
expt.words = [setSentence('sentence',40),setSentence('word',10)];
expt.bIgnoreVowels = 1;

%% Randomization and Concatenation of Stimuli
blocks = 1;
expt.allWords = [];
while blocks < 10
    %this is a random order of sentences
    if blocks == 6
        expt.nblocks = 6;
    else
        expt.nblocks = 1;
    end
    allWords = [];
    expt.ntrials_per_block = 40;
    expt.ntrials = expt.nblocks*expt.ntrials_per_block;
    nwords = length(expt.words(:,1:40));
    for i = 1:ceil(expt.ntrials/nwords)
        indStart = (i-1)*nwords+1;
        indEnd = min(i*nwords,expt.ntrials);
        rp = randperm(nwords);
        allWords(indStart:indEnd) = rp(1:length(indStart:indEnd));
    end
    if blocks == 6
        expt.allWords((length(expt.allWords))+1:(length(expt.allWords))+240) = allWords;
    else
        expt.allWords((length(expt.allWords))+1:(length(expt.allWords))+40) = allWords;
    end
    blocks = blocks + 1;
    if blocks == 2 || blocks == 4 || blocks == 7
        % This is a random order of transfer words
        expt.nblocksTrns = 1;
        expt.ntrials_per_blockTrns = 50;
        expt.ntrialsTrns = expt.nblocksTrns*expt.ntrials_per_blockTrns;
        nwordsTrns = length(expt.words(:,41:50));
        for i = 1:ceil(expt.ntrialsTrns/nwordsTrns)
            indStart = (i-1)*nwordsTrns+1;
            indEnd = min(i*nwordsTrns,expt.ntrialsTrns);
            rp = randperm(nwordsTrns);
            allTransfer(indStart:indEnd) = rp(1:length(indStart:indEnd));
        end
        allTransfer = allTransfer+40;
        if bTestMode
            expt.allTransfer = allTransfer;
            expt.listTransfer = expt.stimulusText(expt.allTransfer);
        end
        expt.allWords((length(expt.allWords))+1:(length(expt.allWords))+50) = allTransfer;
        blocks = blocks + 1;
    end
end
expt.listWords = expt.stimulusText(expt.allWords);

%% Back to stimuli setup
% timing
expt.timing.stimdur = 4.5;         % time stim is on screen, in seconds
expt.timing.stimdurTrns = 1.5;         % time transfer stim on screen
expt.timing.interstimdur = .75;    % minimum time between stims, in seconds
expt.timing.interstimjitter = .75; % maximum extra time between stims (jitter)

%set instructions
expt.instruct = get_defaultInstructions;
expt.instruct.wordTxt = {'Read each word out loud as it appears.' '' 'Press the space bar to continue when ready.'};
expt.instruct.sentenceTxt = {'Read each sentence out loud as it appears.' '' 'Press the space bar to continue when ready.'};

%set conds
nwords = length(expt.words(:,1:40));
nwordsTrns = length(expt.words(:,41:50));
if bTestMode
    nBaseline1 = 4;
    nTransfer1 = 5;
    nBaseline2 = 4;
    nTransfer2 = 5;
    nRamp = 4;
    nHold = 4;
    nTransfer3 = 5;
    nWashout = 4;
    nRetention = 4;
    delayMin = .01;
    expt.breakFrequency = 40;
else
    nBaseline1 = nwords;
    nTransfer1 = 5*nwordsTrns;
    nBaseline2 = nwords;
    nTransfer2 = 5*nwordsTrns;
    nRamp = nwords;
    nHold = 6*nwords;
    nTransfer3 = 5*nwordsTrns;
    nWashout = nwords;
    nRetention = nwords;
    delayMin = 10;
    blocklengths = [(nBaseline1./2) (nBaseline1./2) (nTransfer1./2)...
        (nTransfer1./2) (nBaseline2./2) (nBaseline2./2) (nTransfer2./2)...
        (nTransfer2./2) (nRamp./2) (nRamp./2) (nHold./12) (nHold./12)...
        (nHold./12) (nHold./12) (nHold./12) (nHold./12) (nHold./12)...
        (nHold./12) (nHold./12) (nHold./12) (nHold./12) (nHold./12)...
        (nTransfer3./2) (nTransfer3./2) (nWashout./2) (nWashout./2)...
        (nRetention./2)];
    expt.breakTrials = cumsum(blocklengths);
end
delaySecs = delayMin * 60;

%set noise
expt.noise = {'none' 'mask' 'speech+noise' 'speechshaped'};
expt.allNoise = [3.*ones(1,nBaseline1) 2.*ones(1,nTransfer1) 3.*ones(1,nBaseline2) 2.*ones(1,nTransfer2) 3.*ones(1,(nRamp+nHold)) 2.*ones(1,nTransfer3) 3.*ones(1,nWashout) 3.*ones(1, nRetention)];
%4 for speech-shaped noise, 3 for speech + noise, 2 for just masking noise, according to uhdapter
expt.listNoise = expt.noise(expt.allNoise);

%% set up calibration phase
exptpre.dataPath = fullfile(expt.dataPath,'pre');
mkdir(exptpre.dataPath);
exptpre.words = {'bead' 'bid' 'bed' 'bad' 'bod' 'bud' 'bode' 'booed' 'bayed' 'hood'}; 
nwords = length(exptpre.words);

if bTestMode
    nreps = 1;
else
    nreps = 10;
end

exptpre.ntrials = nreps*nwords;
exptpre.breakFrequency = exptpre.ntrials/2;
exptpre.breakTrials = exptpre.breakFrequency:exptpre.breakFrequency:exptpre.ntrials;

% timing
exptpre.timing.stimdur = 1.5;         % time stim is on screen, in seconds
exptpre.timing.interstimdur = .75;    % minimum time between stims, in seconds
exptpre.timing.interstimjitter = .75; % maximum extra time between stims (jitter)

if ~exist(expt.dataPath,'dir')
    mkdir(expt.dataPath)
end

% get default LPC order if previously defined
if exist(subjPath,'dir')        % if subject folder exists
    ngroups = length(groups);   % look for 'pre' folder in other group
    for g = 1:ngroups-1
         othergroupnum = mod(expt.groupnum+1,ngroups);
        if ~othergroupnum, othergroupnum = ngroups; end
        predir = fullfile(subjPath,groups{othergroupnum},'pre');
        if exist(predir,'dir')          % if 'pre' folder exists
            fprintf('Previous calibration directory found... ');
            nlpcfile = fullfile(predir,'nlpc.mat');
            if exist(nlpcfile,'file')   % if nlpc.mat file exists
                load(nlpcfile,'nlpc');
                fprintf('setting default LPC order to %d.\n',nlpc);
                exptpre.audapterParams.nLPC = nlpc;
            else
                fprintf('but no nlpc data found. Using default LPC order.\n');
            end
        end
    end
end

%% set up main experiment
% ntrials
expt.ntrials = nBaseline1 + nTransfer1 + nBaseline2 + nTransfer2 + nRamp + nHold + nTransfer3 + nWashout + nRetention;

% conds
expt.allConds = [1*ones(1,nBaseline1) 2*ones(1,nTransfer1) 3*ones(1,nBaseline2) 4*ones(1,nTransfer2) 5*ones(1,nRamp) 6*ones(1,nHold) 7*ones(1,nTransfer3) 8*ones(1,nWashout) 9*ones(1,nRetention)];

% shifts
fieldDim = 257;
p.F1Min = 200;
p.F1Max = 1500;
p.F2Min = 500;
p.F2Max = 3500;
p.pertF1 = floor(p.F1Min:(p.F1Max-p.F1Min)/(fieldDim-1):p.F1Max);
p.pertF2 = floor(p.F2Min:(p.F2Max-p.F2Min)/(fieldDim-1):p.F2Max);
p.pertAmp2D = zeros(fieldDim,fieldDim); % define dummy pert field
p.pertPhi2D = zeros(fieldDim,fieldDim); % define dummy pert field
p.bShift2D = 1; %flag for 2D experiment
expt.audapterParams = p;
exptpre.audapterParams = p;

if strcmp(expt.group,'adapt')
    maxScaleFact = .5;
elseif strcmp(expt.group,'null')
    maxScaleFact = 0;
end
% shiftScaleFact is a scalar between 0 and maxScaleFact that is used to scale shiftMag matrix
expt.shiftScaleFact = [zeros(1,nBaseline1+nTransfer1+nBaseline2+nTransfer2) linspace(0,maxScaleFact,nRamp) maxScaleFact*ones(1,nHold) zeros(1,nTransfer3+nWashout+nRetention)];

%% save expt
if ~exist(expt.dataPath,'dir')
    mkdir(expt.dataPath)
end
exptfile = fullfile(expt.dataPath,'expt.mat');
bSave = savecheck(exptfile);
if bSave
    save(exptfile, 'expt')
    fprintf('Saved expt file: %s.\n',exptfile);
end

pertFieldOK = 'no';

%% measure vowel space
while strcmp(pertFieldOK, 'no')
    exptpre = run_measureFormants_audapter(exptpre);
    
    %check LPC order
    check_audapterLPC(exptpre.dataPath)
    hGui = findobj('Tag','check_LPC');
    waitfor(hGui);
    
    load(fullfile(exptpre.dataPath,'nlpc'),'nlpc')
    
    %% calibrate 2D pert field
    fmtMeans = calc_vowelMeans(exptpre.dataPath);
    [p,h_pertField] = calc_pertField('in',fmtMeans,1);
    pertFieldOK = askNChoiceQuestion('Is the perturbation field OK?', {'yes', 'no'});
    try % close the plot_perturbations figure if it's still open
        close(h_pertField)
    catch
    end
    
    %set lpc order
    p.nLPC = nlpc;
end
expt.audapterParams = add2struct(expt.audapterParams,p);

% resave expt
save(exptfile, 'expt');
fprintf('Saved pertfield to expt file: %s.\n',exptfile);

%% run adaptation experiment

conds2run = {'baseline1'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'transfer1'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'baseline2'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'transfer2'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'ramp'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'hold'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'transfer3'};
expt = run_vsaSentence_audapter(expt,conds2run);

conds2run = {'washout'};
expt = run_vsaSentence_audapter(expt,conds2run);

%% run retention
time = clock;
starthr = time(4);
startmin = time(5) + delayMin;
if startmin > 59
    startmin = mod(startmin,60);
    starthr = starthr + 1;
    while starthr > 12
        starthr = starthr - 12;
    end
end

%TODO: This looks a little strange at the moment
fprintf('Pausing for %d minutes. Experiment will resume at %d:%02d.\n',delayMin,starthr,startmin);
pause(delaySecs);
fprintf('Starting retention phase.\n');
conds2run = {'retention'};
expt = run_vsaSentence_audapter(expt,conds2run);


end

function setSentence = setSentence(titleSentence, numSentence)
% function takes a string, 'titleSentence', and a number
% returns a cell array that concatenates the two
for i = 1:numSentence
    setSentence(1,i) = {strcat(titleSentence,num2str(i))};
end
end